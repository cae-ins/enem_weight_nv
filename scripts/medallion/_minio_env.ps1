# Shared by the MinIO wrappers (dot-sourced): loads the .env files of the current
# folder, of this repository and of the orchestration repository (never overriding a
# variable already set), then adds the MinIO host to NO_PROXY. No credential is
# written in the code: they come from .env or from the secrets file of the
# orchestration module.
function Initialize-MinioEnvironment {
    param([string]$ProjectRoot, [string]$OrchestrationRoot)

    $EnvFiles = @(
        (Join-Path (Get-Location).Path ".env"),
        (Join-Path $ProjectRoot ".env"),
        (Join-Path $OrchestrationRoot ".env")
    ) | Select-Object -Unique
    foreach ($EnvFile in $EnvFiles) {
        if (Test-Path -LiteralPath $EnvFile) {
            Get-Content -LiteralPath $EnvFile | ForEach-Object {
                $Line = $_.Trim()
                if (-not $Line -or $Line.StartsWith("#") -or -not $Line.Contains("=")) { return }
                $Name, $Value = $Line.Split("=", 2)
                $Name = $Name.Trim(); $Value = $Value.Trim()
                if ($Name -and -not [Environment]::GetEnvironmentVariable($Name, "Process")) {
                    [Environment]::SetEnvironmentVariable($Name, $Value, "Process")
                }
            }
        }
    }

    $MinioEndpoint = [Environment]::GetEnvironmentVariable("MINIO_ENDPOINT", "Process")
    if ($MinioEndpoint) {
        try {
            $EndpointHost = ([Uri]$MinioEndpoint).Host
            if ($EndpointHost) {
                $NoProxy = [Environment]::GetEnvironmentVariable("NO_PROXY", "Process")
                $Hosts = @($NoProxy -split "," | ForEach-Object { $_.Trim() } | Where-Object { $_ })
                if ($Hosts -notcontains $EndpointHost) {
                    $NoProxyValue = (($Hosts + $EndpointHost) -join ",")
                    [Environment]::SetEnvironmentVariable("NO_PROXY", $NoProxyValue, "Process")
                    [Environment]::SetEnvironmentVariable("no_proxy", $NoProxyValue, "Process")
                }
            }
        } catch {}
    }

    if (-not (Test-Path -LiteralPath (Join-Path $OrchestrationRoot "ene_medallion_io"))) {
        throw "ENE_MEDALLION_ORCHESTRATION repository not found: $OrchestrationRoot (set ENE_ORCHESTRATION_ROOT)"
    }
}
