"""
Upload Visa_export.csv to Firebase Firestore.

Setup:
  pip install firebase-admin
  Download your Firebase service account key:
    Firebase Console → Project Settings → Service Accounts → Generate new private key
  Save it as serviceAccountKey.json next to this script.

Run:
  python3 upload_visas.py
"""

import csv
import json
import firebase_admin
from firebase_admin import credentials, firestore

cred = credentials.Certificate("serviceAccountKey.json")
firebase_admin.initialize_app(cred)
db = firestore.client()

def parse_list(value):
    v = value.strip()
    if not v or v == "[]":
        return []
    try:
        return json.loads(v)
    except Exception:
        return []

def parse_int(value):
    v = value.strip()
    try:
        return int(v) if v else None
    except ValueError:
        return None

with open("Visa_export.csv", newline="", encoding="utf-8") as f:
    # First line is "Visa_export" label — skip it
    first = f.readline()
    if not first.startswith("country"):
        pass  # already skipped the label row
    else:
        # No label row — rewind
        f.seek(0)

    reader = csv.DictReader(f)
    batch = db.batch()
    count = 0

    for row in reader:
        visa_id = row.get("id", "").strip()
        country = row.get("country", "").strip()
        if not visa_id or not country:
            continue

        data = {
            "country":               country,
            "visa_type":             row.get("visa_type", "").strip(),
            "visa_name":             row.get("visa_name", "").strip(),
            "description":           row.get("description", "").strip(),
            "duration":              row.get("duration", "").strip(),
            "processing_time":       row.get("processing_time", "").strip(),
            "cost":                  row.get("cost", "").strip(),
            "requirements":          parse_list(row.get("requirements", "")),
            "eligible_nationalities":parse_list(row.get("eligible_nationalities", "")),
            "required_education":    parse_list(row.get("required_education", "")),
            "application_url":       row.get("application_url", "").strip(),
        }

        min_age = parse_int(row.get("min_age", ""))
        max_age = parse_int(row.get("max_age", ""))
        req_occ = row.get("required_occupation", "").strip()

        if min_age is not None: data["min_age"] = min_age
        if max_age is not None: data["max_age"] = max_age
        if req_occ:             data["required_occupation"] = req_occ

        batch.set(db.collection("visas").document(visa_id), data)
        count += 1

        # Firestore batches are limited to 500 writes
        if count % 499 == 0:
            batch.commit()
            batch = db.batch()
            print(f"  Committed {count} so far...")

    batch.commit()
    print(f"Done — uploaded {count} visas to Firestore.")
