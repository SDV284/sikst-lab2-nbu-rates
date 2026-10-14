"""Конвертація JSON-файлів НБУ у CSV (дата, код валюти, курс)."""
import csv
import json
import sys
from datetime import datetime
from pathlib import Path


def convert(json_path):
    json_path = Path(json_path)
    records = json.loads(json_path.read_text(encoding="utf-8"))
    csv_path = json_path.with_suffix(".csv")
    with csv_path.open("w", newline="", encoding="utf-8") as f:
        w = csv.writer(f)
        w.writerow(["date", "currency", "rate"])
        for r in records:
            date = datetime.strptime(r["exchangedate"], "%d.%m.%Y").date().isoformat()
            w.writerow([date, r["cc"], r["rate_per_unit"]])
    print(f"{json_path.name} -> {csv_path.name} ({len(records)} рядків)")
    return csv_path


if __name__ == "__main__":
    data_dir = Path(sys.argv[1] if len(sys.argv) > 1 else "data")
    for p in sorted(data_dir.glob("nbu_*.json")):
        convert(p)
