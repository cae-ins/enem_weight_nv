<#
.SYNOPSIS
  Upload data and Excel files from a folder to a MinIO bucket (S3-compatible).

.DESCRIPTION
  Recursive uploader that finds files by extension (.dta, .csv, .xlsx, .xls, .sav, .rds)
  and uploads them to a MinIO endpoint. Uses AWS CLI if available (recommended),
  or the MinIO client `mc` as fallback. Can run as dry-run.

.PARAMETER SourceDir
  Local folder to scan (default: repository root `.`).

.PARAMETER Bucket
  Target bucket name (can also be set via env var MINIO_BUCKET).

.PARAMETER Prefix
  Optional key prefix inside the bucket (default: empty).

.PARAMETER Endpoint
  MinIO endpoint URL, e.g. https://minio.example.org:9000 (env var MINIO_ENDPOINT).

.PARAMETER AccessKey
  MinIO access key (env var MINIO_ACCESS_KEY).

.PARAMETER SecretKey
  MinIO secret key (env var MINIO_SECRET_KEY).

.PARAMETER DryRun
  If set, do not upload, only print planned uploads.

Example:
  $env:MINIO_ENDPOINT='https://minio.example.org:9000'
  $env:MINIO_ACCESS_KEY='AK'
  $env:MINIO_SECRET_KEY='SK'
  .\upload_to_minio.ps1 -SourceDir data -Bucket my-bucket -Prefix repo_backup -DryRun
#>

param(
    [string]$SourceDir = ".",
    [string]$Bucket = $env:MINIO_BUCKET,
    [string]$Prefix = "",
    [string]$Endpoint = $env:MINIO_ENDPOINT,
    [string]$AccessKey = $env:MINIO_ACCESS_KEY,
    [string]$SecretKey = $env:MINIO_SECRET_KEY,
    [switch]$DryRun
)

Set-StrictMode -Version Latest

if (-not (Test-Path -Path $SourceDir)) {
    Write-Error "SourceDir '$SourceDir' n'existe pas."; exit 1
}

if (-not $Bucket) {
    Write-Error "Nom du bucket non fourni. Passez -Bucket ou définissez MINIO_BUCKET."; exit 1
}

if (-not $Endpoint) {
    Write-Error "Endpoint MinIO non fourni. Passez -Endpoint ou définissez MINIO_ENDPOINT."; exit 1
}

# default extensions to consider for 'data' files
$exts = @('*.dta','*.csv','*.xlsx','*.xls','*.sav','*.rds')

Write-Host "Source: $SourceDir"
Write-Host "Bucket: $Bucket"
if ($Prefix -ne "") { Write-Host "Prefix: $Prefix" }
Write-Host "Endpoint: $Endpoint"
if ($DryRun) { Write-Host "DRY RUN: aucun fichier ne sera uploadé" }

# find files
$files = Get-ChildItem -Path $SourceDir -Recurse -File | Where-Object {
    foreach ($p in $exts) { if ($_.Name -like $p) { return $true } }
    return $false
}

if ($files.Count -eq 0) {
    Write-Host "Aucun fichier trouvé pour les extensions: $($exts -join ', ')"; exit 0
}

# prefer aws cli
$aws = Get-Command aws -ErrorAction SilentlyContinue
if ($aws) {
    Write-Host "aws CLI trouvé. Utilisation de aws s3 --endpoint-url ..."
    # we will use aws with --endpoint-url
    foreach ($f in $files) {
        $rel = Resolve-Path -Path $f.FullName | ForEach-Object { $_.Path.Substring((Resolve-Path -Path $SourceDir).Path.Length).TrimStart('\') }
        $key = if ($Prefix -ne "") { "$Prefix/$rel" } else { $rel }
        $dest = "s3://$Bucket/$key"
        if ($DryRun) {
            Write-Host "DRY -> aws --endpoint-url $Endpoint s3 cp `"$($f.FullName)`" `"$dest`""
        } else {
            Write-Host "Uploading $rel -> $dest"
            # pass credentials via env if provided
            $env:AWS_ACCESS_KEY_ID = $AccessKey
            $env:AWS_SECRET_ACCESS_KEY = $SecretKey
            $cmd = @( 'aws', '--endpoint-url', $Endpoint, 's3', 'cp', $f.FullName, $dest )
            $proc = Start-Process -FilePath $cmd[0] -ArgumentList $cmd[1..($cmd.Length-1)] -NoNewWindow -Wait -PassThru -ErrorAction Stop
            if ($proc.ExitCode -ne 0) { Write-Warning "Upload échoué pour $rel (exit $($proc.ExitCode))" }
        }
    }
    Write-Host "Terminé (aws)."
    exit 0
}

# fallback: minio client 'mc'
$mc = Get-Command mc -ErrorAction SilentlyContinue
if ($mc) {
    Write-Host "MinIO client 'mc' trouvé. Création d'un alias temporaire 'tmpminio'."
    $alias = "tmpminio"
    # set alias
    & mc alias set $alias $Endpoint $AccessKey $SecretKey --api S3v4
    foreach ($f in $files) {
        $rel = Resolve-Path -Path $f.FullName | ForEach-Object { $_.Path.Substring((Resolve-Path -Path $SourceDir).Path.Length).TrimStart('\') }
        $dest = "$alias/$Bucket/$Prefix/$rel" -replace '//','/'
        if ($DryRun) { Write-Host "DRY -> mc cp `"$($f.FullName)`" `"$dest`"" }
        else { Write-Host "Uploading $rel -> $dest"; & mc cp --recursive --preserve $f.FullName $dest }
    }
    Write-Host "Terminé (mc)."
    exit 0
}

Write-Error "Ni 'aws' ni 'mc' n'ont été trouvés sur le système. Installez aws-cli ou mc (minio client)."
exit 2
