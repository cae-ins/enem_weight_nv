param(
    [string]$Period = $(if ($env:ENE_PERIOD) { $env:ENE_PERIOD } else { "quarterly" }),
    [string]$Quarter = $(if ($env:ENE_QUARTER) { $env:ENE_QUARTER } else { "T4_2025" }),
    [string]$Year = $(if ($env:ENE_YEAR) { $env:ENE_YEAR } else { "2025" }),
    [string]$OrchestrationRoot = "C:\Users\f.migone\Desktop\ENE_MEDALLION_ORCHESTRATION",
    [switch]$DryRun,
    [switch]$Overwrite
)

$ErrorActionPreference = "Stop"
$ProjectRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path
$ScriptPath = Join-Path $OrchestrationRoot "ene_medallion_io\04_upload_weights_outputs.py"

$ArgsList = @($ScriptPath, "--period", $Period, "--quarter", $Quarter, "--year", $Year, "--base-dir", $ProjectRoot)
if ($DryRun) { $ArgsList += "--dry-run" }
if ($Overwrite) { $ArgsList += "--overwrite" }

& python @ArgsList
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
