"""Завантаження офіційного курсу гривні до USD та EUR за 2022 рік з API НБУ (JSON)."""
import json
import sys
from pathlib import Path

import requests

API = "https://bank.gov.ua/NBU_Exchange/exchange_site"
CURRENCIES = ["usd", "eur"]


def fetch(valcode, start="20220101", end="20221231"):
    params = {"start": start, "end": end, "valcode": valcode,
              "sort": "exchangedate", "order": "asc", "json": ""}
    resp = requests.get(API, params=params, timeout=30)
    resp.raise_for_status()
    return resp.json()


def main(out_dir="data"):
    out = Path(out_dir)
    out.mkdir(exist_ok=True)
    for cur in CURRENCIES:
        data = fetch(cur)
        path = out / f"nbu_{cur}_2022.json"
        path.write_text(json.dumps(data, ensure_ascii=False, indent=2), encoding="utf-8")
        print(f"{cur.upper()}: {len(data)} записів -> {path}")


if __name__ == "__main__":
    main(*sys.argv[1:])
