"""MySQL helpers for Zikrnoor; supports local .env and Railway MySQL variables."""

import os
import mysql.connector
from mysql.connector import Error
from dotenv import load_dotenv

load_dotenv()


def _env(primary, railway_name, default=None):
    """Prefer the app's DB_* setting, then Railway's native MySQL variable."""
    return os.environ.get(primary) or os.environ.get(railway_name) or default


def get_connection():
    host = _env("DB_HOST", "MYSQLHOST", "127.0.0.1")
    port = int(_env("DB_PORT", "MYSQLPORT", "3306"))
    user = _env("DB_USER", "MYSQLUSER", "root")
    password = _env("DB_PASSWORD", "MYSQLPASSWORD", "")
    database = _env("DB_NAME", "MYSQLDATABASE", "zikrnoor")
    return mysql.connector.connect(
        host=host,
        port=port,
        user=user,
        password=password,
        database=database,
        charset="utf8mb4",
        autocommit=False,
        connection_timeout=10,
    )


def fetch_all(sql, params=None):
    conn = None
    cur = None
    try:
        conn = get_connection()
        cur = conn.cursor(dictionary=True)
        cur.execute(sql, params or ())
        return cur.fetchall()
    finally:
        if cur is not None:
            cur.close()
        if conn is not None and conn.is_connected():
            conn.close()


def fetch_one(sql, params=None):
    conn = None
    cur = None
    try:
        conn = get_connection()
        cur = conn.cursor(dictionary=True)
        cur.execute(sql, params or ())
        return cur.fetchone()
    finally:
        if cur is not None:
            cur.close()
        if conn is not None and conn.is_connected():
            conn.close()


def execute(sql, params=None):
    conn = None
    cur = None
    try:
        conn = get_connection()
        cur = conn.cursor()
        cur.execute(sql, params or ())
        conn.commit()
        return cur.lastrowid if cur.lastrowid else cur.rowcount
    except Error:
        if conn is not None:
            conn.rollback()
        raise
    finally:
        if cur is not None:
            cur.close()
        if conn is not None and conn.is_connected():
            conn.close()
