# sikst-lab2-nbu-rates

Код лабораторної роботи № 2 з дисципліни «Сучасні інформаційно-комунікаційні системи та технології»
(СумДУ, ІН-32/2): курс гривні до USD та EUR за 2022 рік з API НБУ → CSV → Amazon S3 → графік.

| Файл | Призначення |
|---|---|
| `fetch_nbu.py` | завантажує курс USD та EUR за 2022 рік з API НБУ у JSON (`data/`) |
| `json_to_csv.py` | конвертує JSON у CSV (`date,currency,rate`) |
| `upload_to_s3.py BUCKET` | вивантажує CSV у бакет S3 з префіксом `nbu/` |
| `lab2_rates.ipynb` | читає CSV з S3, будує графік і зберігає його в бакет (`plots/`) |
| `deploy.sh` | розгортання на чистому Ubuntu: клонування репозиторію, venv, залежності |

## Розгортання

```bash
curl -fsSL https://raw.githubusercontent.com/SDV284/sikst-lab2-nbu-rates/main/deploy.sh | bash
# або з одразу виконаним конвеєром даних:
curl -fsSL https://raw.githubusercontent.com/SDV284/sikst-lab2-nbu-rates/main/deploy.sh | BUCKET=my-bucket bash
```

Доступ до S3 на інстансі EC2 надається IAM-роллю інстансу, ключі доступу в репозиторії не зберігаються.
