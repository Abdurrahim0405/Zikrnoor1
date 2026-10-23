"""
setup_db.py — runs automatically before the website starts (see Procfile).

1. Waits for MySQL to be reachable.
2. Creates any missing tables (schema.sql).
3. Fills in the starter Adhkar, Hadith and Routine data — but only if
   that table is still empty, so your data is never duplicated.

Safe to run as many times as you like.
"""

import os
import sys
import time

import db

BASE_DIR = os.path.dirname(os.path.abspath(__file__))

# (table that must be empty, seed file to run)
SEEDS = [
    ("adhkar", "seed_adhkar.sql"),
    ("hadith_references", "seed_hadith.sql"),
    ("routines", "seed_routines.sql"),
]


def strip_leading_comments(stmt):
    lines = stmt.split("\n")
    cleaned, seen_sql = [], False
    for line in lines:
        s = line.strip()
        if not seen_sql and (not s or s.startswith("--")):
            continue
        seen_sql = True
        cleaned.append(line)
    return "\n".join(cleaned).strip()


def run_sql_file(name):
    with open(os.path.join(BASE_DIR, name), "r", encoding="utf-8") as f:
        raw = f.read()
    statements = [strip_leading_comments(s) for s in raw.split(";")]
    statements = [s for s in statements if s]
    conn = db.get_connection()
    cur = conn.cursor()
    try:
        for stmt in statements:
            cur.execute(stmt)
        conn.commit()
    except Exception:
        conn.rollback()
        raise
    finally:
        cur.close()
        conn.close()
    print(f"  {name}: {len(statements)} statement(s) applied")


def wait_for_db(attempts=30, delay=2):
    for i in range(1, attempts + 1):
        try:
            db.fetch_one("SELECT 1 AS ok")
            return
        except Exception as e:
            print(f"  Waiting for MySQL ({i}/{attempts}): {e}")
            time.sleep(delay)
    print("ERROR: could not reach MySQL. Check the DB_* variables.")
    sys.exit(1)


def main():
    print("Setting up database...")
    wait_for_db()
    run_sql_file("schema.sql")
    for table, seed_file in SEEDS:
        row = db.fetch_one(f"SELECT COUNT(*) AS n FROM {table}")
        if row["n"] == 0:
            run_sql_file(seed_file)
        else:
            print(f"  {table}: already has data, skipping {seed_file}")
    print("Database ready.")


if __name__ == "__main__":
    main()
