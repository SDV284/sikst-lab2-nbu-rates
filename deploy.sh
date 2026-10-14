#!/usr/bin/env bash
# Розгортання коду лабораторної роботи №2 на чистому Ubuntu:
# клонування git-репозиторію, створення віртуального середовища Python і встановлення залежностей.
# Якщо задано змінну BUCKET — одразу виконується конвеєр: API НБУ -> JSON -> CSV -> S3.
set -euo pipefail

REPO_URL="${REPO_URL:-https://github.com/SDV284/sikst-lab2-nbu-rates.git}"
APP_DIR="${APP_DIR:-$HOME/sikst-lab2-nbu-rates}"
VENV_DIR="$APP_DIR/.venv"
APT="sudo DEBIAN_FRONTEND=noninteractive apt-get -o DPkg::Lock::Timeout=600 -qq"

log() { echo "[deploy $(date +%T)] $*"; }
trap 'log "ПОМИЛКА в рядку $LINENO (код $?)"' ERR

log "1/4 Системні пакети (git, python3-venv, python3-pip)"
if ! command -v git >/dev/null 2>&1 || ! python3 -c "import ensurepip" >/dev/null 2>&1; then
    $APT update
    $APT install -y git python3-venv python3-pip >/dev/null
fi
log "    $(git --version), $(python3 --version)"

log "2/4 Код з $REPO_URL"
if [ -d "$APP_DIR/.git" ]; then
    git -C "$APP_DIR" pull --ff-only
else
    git clone --depth 1 "$REPO_URL" "$APP_DIR"
fi
log "    коміт $(git -C "$APP_DIR" log -1 --format='%h %s')"

log "3/4 Віртуальне середовище $VENV_DIR і залежності з requirements.txt"
# Системний Python в Ubuntu 23.04+ захищений від pip (PEP 668), тому — venv
python3 -m venv "$VENV_DIR"
"$VENV_DIR/bin/pip" install -q --upgrade pip
"$VENV_DIR/bin/pip" install -q -r "$APP_DIR/requirements.txt"

log "4/4 Перевірка встановлених бібліотек"
"$VENV_DIR/bin/python" - <<'PY'
import boto3, requests, pandas, matplotlib, notebook
print("    boto3", boto3.__version__, "| requests", requests.__version__, "| pandas", pandas.__version__,
      "| matplotlib", matplotlib.__version__, "| notebook", notebook.__version__)
PY

if [ -n "${BUCKET:-}" ]; then
    log "Конвеєр даних -> s3://$BUCKET"
    cd "$APP_DIR"
    "$VENV_DIR/bin/python" fetch_nbu.py
    "$VENV_DIR/bin/python" json_to_csv.py
    "$VENV_DIR/bin/python" upload_to_s3.py "$BUCKET"
fi
log "Готово. Активація середовища: source $VENV_DIR/bin/activate"
