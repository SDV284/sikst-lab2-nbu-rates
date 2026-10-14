"""Програматичне вивантаження CSV-файлів на S3."""
import sys
from pathlib import Path

import boto3
from botocore.exceptions import ClientError


def upload(bucket, data_dir="data", prefix="nbu/"):
    s3 = boto3.client("s3")
    for p in sorted(Path(data_dir).glob("*.csv")):
        key = prefix + p.name
        try:
            s3.upload_file(str(p), bucket, key)
            print(f"uploaded {p} -> s3://{bucket}/{key}")
        except ClientError as e:
            print(f"помилка завантаження {p}: {e}")


if __name__ == "__main__":
    upload(sys.argv[1], *sys.argv[2:])
