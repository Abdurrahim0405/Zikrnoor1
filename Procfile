web: python setup_db.py && (python seed_quran.py || echo "WARNING: Quran import was skipped/failed; app will still start.") && gunicorn app:app --bind 0.0.0.0:$PORT --workers 2
