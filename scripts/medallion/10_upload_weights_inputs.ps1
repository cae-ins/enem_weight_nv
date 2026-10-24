# Publishes the inputs owned by the weighting stage (enumeration, enumeration updates,
# population totals; with -References the reference files) so that the weighting can
# run on any computer from MinIO. -WithCleanedSurveys is for the migration of past
# quarters only (cleaned survey files, never replaced).
param(
    [string]$Quarter = $(if ($env:ENE_QUARTER) { $env:ENE_QUARTER } else { "T1_2026" }),
    [string]$OrchestrationRoot = $(if ($env:ENE_ORCHESTRATION_ROOT) { $env:ENE_ORCHESTRATION_ROOT } else { Join-Path $PSScriptRoot "..\..\..\ENE_MEDALLION_ORCHESTRATION" }),
    [switch]$AllQuarters,
    [switch]$References,
    [switch]$WithCleanedSurveys,
    [switch]$DryRun,
    [switch]$Overwrite
)

$ErrorActionPreference = "Stop"
$ProjectRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path
. (Join-Path $PSScriptRoot "_minio_env.ps1")
Initialize-MinioEnvironment -ProjectRoot $ProjectRoot -OrchestrationRoot $OrchestrationRoot

$ArgsList = @((Join-Path $OrchestrationRoot "ene_medallion_io\10_upload_weights_inputs.py"),
              "--quarter", $Quarter, "--base-dir", $ProjectRoot)
if ($AllQuarters) { $ArgsList += "--all-quarters" }
if ($References) { $ArgsList += "--references" }
if ($WithCleanedSurveys) { $ArgsList += "--with-cleaned-surveys" }
if ($DryRun) { $ArgsList += "--dry-run" }
if ($Overwrite) { $ArgsList += "--overwrite" }

& python @ArgsList
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
