#!/usr/bin/env python3
"""MinIO launcher of ENE_SURVEY_WEIGHTS (Windows and Linux; replaces the PowerShell wrappers).

    python scripts/medallion/medallion.py download        --quarter T1_2026 [--dry-run]
    python scripts/medallion/medallion.py upload-inputs   --quarter T1_2026 [--all-quarters] [--references]
    python scripts/medallion/medallion.py upload-outputs  --quarter T1_2026 [--overwrite]
    python scripts/medallion/medallion.py upload-outputs  --period annual --year 2025

The shared logic (.env loading, NO_PROXY, call of the I/O scripts) lives in
ENE_MEDALLION_ORCHESTRATION/ene_medallion_io/launcher.py, found next to this repository
or in ENE_ORCHESTRATION_ROOT. Data contract: ene_medallion_io/weights_contract.py.
"""
from __future__ import annotations

import os
import sys
from pathlib import Path

PROJECT_ROOT = Path(__file__).resolve().parents[2]
_orch = Path(os.environ.get("ENE_ORCHESTRATION_ROOT", PROJECT_ROOT.parent / "ENE_MEDALLION_ORCHESTRATION"))
sys.path.insert(0, str(_orch / "ene_medallion_io"))
try:
    from launcher import Command, main  # noqa: E402
except ImportError:
    sys.exit(f"ENE_MEDALLION_ORCHESTRATION introuvable : {_orch} (définir ENE_ORCHESTRATION_ROOT)")

COMMANDS = {
    "download": Command("03_download_weights_inputs.py", "Télécharge toutes les entrées de la pondération"),
    "upload-inputs": Command(
        "10_upload_weights_inputs.py", "Publie les entrées dont la pondération est propriétaire",
        flags=("all-quarters", "references", "with-cleaned-surveys"),
    ),
    "upload-outputs": Command(
        "04_upload_weights_outputs.py", "Publie les poids (trimestriels ou annuels)",
        period=True, options=("calibration-strategy",),
    ),
}

if __name__ == "__main__":
    sys.exit(main(PROJECT_ROOT, COMMANDS, "Lanceur MinIO de ENE_SURVEY_WEIGHTS"))
