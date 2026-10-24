#!/usr/bin/env python3
"""MinIO launcher of the ENE weighting pipeline (replaces the former PowerShell wrappers).

Runs the I/O scripts of the sibling repository ENE_MEDALLION_ORCHESTRATION
(ene_medallion_io/) for this repository. It loads the .env files of the current
folder, of this repository and of the orchestration repository (never overriding a
variable already set), adds the MinIO host to NO_PROXY, then calls the script with
the current Python interpreter. Works on Windows and Linux; needs Python >= 3.9 and
the packages of the orchestration module (boto3).

Usage, from anywhere:
    python scripts/medallion/medallion.py download        --quarter T1_2026 [--dry-run]
    python scripts/medallion/medallion.py upload-inputs   --quarter T1_2026 [--all-quarters] [--references]
    python scripts/medallion/medallion.py upload-outputs  --quarter T1_2026 [--overwrite]
    python scripts/medallion/medallion.py upload-outputs  --period annual --year 2025

The data contract (what is read, where it lands under data/) is
ENE_MEDALLION_ORCHESTRATION/ene_medallion_io/weights_contract.py.
"""
from __future__ import annotations

import argparse
import os
import subprocess
import sys
from pathlib import Path
from urllib.parse import urlparse

PROJECT_ROOT = Path(__file__).resolve().parents[2]
DEFAULT_QUARTER = "T1_2026"
DEFAULT_YEAR = "2025"

SCRIPTS = {
    "download": "03_download_weights_inputs.py",
    "upload-outputs": "04_upload_weights_outputs.py",
    "upload-inputs": "10_upload_weights_inputs.py",
}


def orchestration_root() -> Path:
    root = Path(os.environ.get("ENE_ORCHESTRATION_ROOT", PROJECT_ROOT.parent / "ENE_MEDALLION_ORCHESTRATION"))
    if not (root / "ene_medallion_io").is_dir():
        sys.exit(f"ENE_MEDALLION_ORCHESTRATION introuvable : {root} (définir ENE_ORCHESTRATION_ROOT)")
    return root.resolve()


def load_env_files(orchestration: Path) -> None:
    for env_file in dict.fromkeys([Path.cwd() / ".env", PROJECT_ROOT / ".env", orchestration / ".env"]):
        if not env_file.is_file():
            continue
        for line in env_file.read_text(encoding="utf-8").splitlines():
            line = line.strip()
            if not line or line.startswith("#") or "=" not in line:
                continue
            name, value = (part.strip() for part in line.split("=", 1))
            if name and not os.environ.get(name):
                os.environ[name] = value


def add_minio_host_to_no_proxy() -> None:
    host = urlparse(os.environ.get("MINIO_ENDPOINT", "")).hostname
    if not host:
        return
    hosts = [h.strip() for h in os.environ.get("NO_PROXY", "").split(",") if h.strip()]
    if host not in hosts:
        os.environ["NO_PROXY"] = os.environ["no_proxy"] = ",".join(hosts + [host])


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("command", choices=sorted(SCRIPTS))
    parser.add_argument("--quarter", default=None, help="TX_YYYY (défaut : ENE_QUARTER, sinon %(default)s)")
    parser.add_argument("--period", choices=("quarterly", "annual"), default=None,
                        help="upload-outputs uniquement (défaut : ENE_PERIOD, sinon quarterly)")
    parser.add_argument("--year", default=None, help="upload-outputs annuel (défaut : ENE_YEAR)")
    parser.add_argument("--calibration-strategy", default=None, help="upload-outputs (défaut : 180X_1D)")
    parser.add_argument("--all-quarters", action="store_true", help="upload-inputs : tout l'historique")
    parser.add_argument("--references", action="store_true", help="upload-inputs : fichiers de référence")
    parser.add_argument("--with-cleaned-surveys", action="store_true",
                        help="upload-inputs, migration seulement : fichiers apurés absents de silver")
    parser.add_argument("--dry-run", action="store_true")
    parser.add_argument("--overwrite", action="store_true")
    args = parser.parse_args()

    orchestration = orchestration_root()
    load_env_files(orchestration)
    add_minio_host_to_no_proxy()

    quarter = args.quarter or os.environ.get("ENE_QUARTER") or DEFAULT_QUARTER
    command = [sys.executable, str(orchestration / "ene_medallion_io" / SCRIPTS[args.command]),
               "--quarter", quarter, "--base-dir", str(PROJECT_ROOT)]
    if args.command == "upload-outputs":
        command += [
            "--period", args.period or os.environ.get("ENE_PERIOD") or "quarterly",
            "--year", args.year or os.environ.get("ENE_YEAR") or DEFAULT_YEAR,
            "--calibration-strategy",
            args.calibration_strategy or os.environ.get("ENE_CALIBRATION_STRATEGY") or "180X_1D",
        ]
    if args.command == "upload-inputs":
        command += [flag for flag, on in (("--all-quarters", args.all_quarters),
                                          ("--references", args.references),
                                          ("--with-cleaned-surveys", args.with_cleaned_surveys)) if on]
    command += [flag for flag, on in (("--dry-run", args.dry_run), ("--overwrite", args.overwrite)) if on]

    # The orchestration scripts import their sibling modules (ene_minio, weights_contract).
    return subprocess.call(command, cwd=orchestration / "ene_medallion_io")


if __name__ == "__main__":
    sys.exit(main())
