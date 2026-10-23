# Zikrnoor

Zikrnoor is a Flask + MySQL web app for Quran, Adhkar, Tasbeeh, Hadith, routines, and bookmarks.

## Local setup

1. Install Python 3.10+ and MySQL 8+.
2. Create a database named `zikrnoor` with UTF-8 support.
3. Copy `.env.example` to `.env` and set the database credentials.
4. Install dependencies and initialize the database:

```bash
python -m venv .venv
source .venv/bin/activate  # Windows: .venv\\Scripts\\activate
pip install -r requirements.txt
python setup_db.py
python -m flask --app app run
```

Open http://127.0.0.1:5000. Check `/api/health` to verify the database connection.

## Deploy on Railway

1. Push this repository to GitHub and create a Railway project from the repository.
2. Add a MySQL service to the same Railway project.
3. In the web service's Variables settings, either reference the MySQL service's native variables or set the app's `DB_*` variables. The app accepts Railway's `MYSQLHOST`, `MYSQLPORT`, `MYSQLUSER`, `MYSQLPASSWORD`, and `MYSQLDATABASE` variables directly.
4. Set `SECRET_KEY` to a long random secret in the web service Variables settings. Do not commit secrets or a real `.env` file.
5. Deploy. The `Procfile` runs `setup_db.py` before Gunicorn starts. Database setup is designed to create missing tables and seed starter Adhkar, Hadith, and routine data only when the respective tables are empty.
6. Once deployed, open `https://YOUR-DOMAIN/api/health`. A healthy response should include `"status":"ok"` and `"database":"connected"`.

If the deployment fails, check Railway's deploy logs and confirm the web service can reach the MySQL service. Do not paste database passwords or secret keys into issue reports.

## Quran content

The database schema includes Quran tables, but `setup_db.py` does not import Quran text into them. The frontend currently calls AlQuran Cloud for Quran reading. If you want the backend Quran API endpoints to return Quran data, import a verified dataset with clear attribution before relying on those endpoints.

## Important

- Keep `.env`, credentials, and secret keys out of Git.
- The health endpoint verifies database connectivity; it does not guarantee every content source is populated.
- For production, configure a stable `SECRET_KEY` in the hosting dashboard.
