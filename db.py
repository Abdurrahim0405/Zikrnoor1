"""MySQL helpers for Zikrnoor with SSL support for managed MySQL providers."""

import os
import mysql.connector
from mysql.connector import Error
from dotenv import load_dotenv

load_dotenv()


def _env(primary, *fallbacks, default=None):
    """Return the first configured non-empty environment variable."""
    for name in (primary, *fallbacks):
        value = os.environ.get(name)
        if value:
            return value
    return default


def get_connection():
    host = _env("DB_HOST", "MYSQLHOST", "MYSQL_HOST", default="127.0.0.1")
    port = int(_env("DB_PORT", "MYSQLPORT", "MYSQL_PORT", default="3306"))
    user = _env("DB_USER", "MYSQLUSER", "MYSQL_USER", default="root")
    password = _env("DB_PASSWORD", "MYSQLPASSWORD", "MYSQL_PASSWORD", default="")
    database = _env("DB_NAME", "MYSQLDATABASE", "MYSQL_DATABASE", default="zikrnoor")

    # Set DB_SSL_CA to a certificate file path to verify managed MySQL TLS.
    # For Aiven, commit the CA certificate as aiven-ca.pem and set DB_SSL_CA=aiven-ca.pem.
    ssl_ca = _env("DB_SSL_CA", "MYSQL_SSL_CA")
    ssl_options = {}
    if ssl_ca:
        ssl_options.update(ssl_ca=ssl_ca, ssl_verify_cert=True, ssl_verify_identity=True)

    return mysql.connector.connect(
        host=host,
        port=port,
        user=user,
        password=password,
        database=database,
        charset="utf8mb4",
        autocommit=False,
        connection_timeout=10,
        **ssl_options,
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
