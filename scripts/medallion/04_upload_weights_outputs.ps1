# Publishes the weighting products of a quarter (silver/enem/<T>/poids/, calibration
# design, gold/enem/<T>/base_ponderee/) or of a year (-Period annual -Year <a>).
param(
    [string]$Period = $(if ($env:ENE_PERIOD) { $env:ENE_PERIOD } else { "quarterly" }),
    [string]$Quarter = $(if ($env:ENE_QUARTER) { $env:ENE_QUARTER } else { "T1_2026" }),
    [string]$Year = $(if ($env:ENE_YEAR) { $env:ENE_YEAR } else { "2025" }),
    [string]$CalibrationStrategy = $(if ($env:ENE_CALIBRATION_STRATEGY) { $env:ENE_CALIBRATION_STRATEGY } else { "180X_1D" }),
    [string]$OrchestrationRoot = $(if ($env:ENE_ORCHESTRATION_ROOT) { $env:ENE_ORCHESTRATION_ROOT } else { Join-Path $PSScriptRoot "..\..\..\ENE_MEDALLION_ORCHESTRATION" }),
    [switch]$DryRun,
    [switch]$Overwrite
)

$ErrorActionPreference = "Stop"
$ProjectRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path
. (Join-Path $PSScriptRoot "_minio_env.ps1")
Initialize-MinioEnvironment -ProjectRoot $ProjectRoot -OrchestrationRoot $OrchestrationRoot

$ArgsList = @(
    (Join-Path $OrchestrationRoot "ene_medallion_io\04_upload_weights_outputs.py"),
    "--period", $Period,
    "--quarter", $Quarter,
    "--year", $Year,
    "--base-dir", $ProjectRoot,
    "--calibration-strategy", $CalibrationStrategy
)
if ($DryRun) { $ArgsList += "--dry-run" }
if ($Overwrite) { $ArgsList += "--overwrite" }

& python @ArgsList
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
