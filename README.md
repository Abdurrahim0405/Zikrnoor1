# Zikrnoor

Flask + MySQL web app for Quran, Adhkar, Tasbeeh, Hadith, routines, and bookmarks.

## Local setup

1. Install Python 3.10+ and MySQL 8+.
2. Create a UTF-8 database named `zikrnoor`.
3. Copy `.env.example` to `.env` and set the DB credentials.
4. Install dependencies and initialize the database:

```bash
python -m venv .venv
source .venv/bin/activate  # Windows: .venv\\Scripts\\activate
pip install -r requirements.txt
python setup_db.py
python -m flask --app app run
```

Open http://127.0.0.1:5000 and check `/api/health`.

## Render + Aiven deployment

1. Create a Render Web Service from this repository; choose the Free instance if you want to avoid the shown monthly instance charge.
2. Build command: `pip install -r requirements.txt`.
3. Start command: `python setup_db.py && gunicorn app:app --bind 0.0.0.0:$PORT --workers 2 --timeout 120`.
4. In Render's Environment settings, add:
   - `DB_HOST`: Aiven host
   - `DB_PORT`: Aiven port
   - `DB_USER`: Aiven user (often `avnadmin`)
   - `DB_PASSWORD`: Aiven password
   - `DB_NAME`: Aiven database name (the default is often `defaultdb`)
   - `DB_SSL_CA`: `aiven-ca.pem` (path is relative to the repository root)
   - `SECRET_KEY`: generate a strong random value in Render; do not commit it.
5. Aiven MySQL requires SSL. `db.py` verifies the server certificate using `DB_SSL_CA`; the repository includes the Aiven CA certificate as `aiven-ca.pem`.
6. Deploy and open `https://YOUR-RENDER-SERVICE.onrender.com/api/health`. A healthy response should say `"status":"ok"` and `"database":"connected"`.

## Notes

- Keep the Aiven password and `SECRET_KEY` out of GitHub. Only the CA certificate is committed.
- The free Aiven service may power off when inactive; the Render free service may spin down. First requests can take a while after inactivity.
- `setup_db.py` creates missing tables and seeds starter Adhkar, Hadith, and routine records only if their tables are empty.
- Quran tables are present in the schema, but the setup script does not import Quran text into those tables. The frontend uses AlQuran Cloud for Quran reading; backend Quran endpoints need a verified import to return Quran rows.
