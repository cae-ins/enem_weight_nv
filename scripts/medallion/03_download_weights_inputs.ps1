# Downloads every input of the weighting pipeline for a quarter from MinIO into data/
# (list and locations: ENE_MEDALLION_ORCHESTRATION/ene_medallion_io/weights_contract.py).
param(
    [string]$Quarter = $(if ($env:ENE_QUARTER) { $env:ENE_QUARTER } else { "T1_2026" }),
    [string]$OrchestrationRoot = $(if ($env:ENE_ORCHESTRATION_ROOT) { $env:ENE_ORCHESTRATION_ROOT } else { Join-Path $PSScriptRoot "..\..\..\ENE_MEDALLION_ORCHESTRATION" }),
    [switch]$DryRun,
    [switch]$Overwrite
)

$ErrorActionPreference = "Stop"
$ProjectRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path
. (Join-Path $PSScriptRoot "_minio_env.ps1")
Initialize-MinioEnvironment -ProjectRoot $ProjectRoot -OrchestrationRoot $OrchestrationRoot

$ArgsList = @((Join-Path $OrchestrationRoot "ene_medallion_io\03_download_weights_inputs.py"),
              "--quarter", $Quarter, "--base-dir", $ProjectRoot)
if ($DryRun) { $ArgsList += "--dry-run" }
if ($Overwrite) { $ArgsList += "--overwrite" }

& python @ArgsList
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
