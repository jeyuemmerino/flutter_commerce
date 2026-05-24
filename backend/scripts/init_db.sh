#!/usr/bin/env bash
# Bash helper to create `ecommerce_db` and import schema.sql
# Usage: ./init_db.sh root YourRootPassword

MYSQL_HOST=${1:-localhost}
MYSQL_USER=${2:-root}
MYSQL_PASS=${3:-}
DB_NAME=${4:-ecommerce_db}

if ! command -v mysql >/dev/null 2>&1; then
  echo "mysql client not found. Please install MySQL client." >&2
  exit 1
fi

echo "Creating database $DB_NAME on $MYSQL_HOST..."
mysql --host="$MYSQL_HOST" --user="$MYSQL_USER" --password="$MYSQL_PASS" -e "CREATE DATABASE IF NOT EXISTS $DB_NAME;"
if [ $? -ne 0 ]; then
  echo "Failed to create database" >&2
  exit 1
fi

SCHEMA_FILE="$(dirname "$0")/../database/schema.sql"
if [ ! -f "$SCHEMA_FILE" ]; then
  echo "schema.sql not found at $SCHEMA_FILE" >&2
  exit 1
fi

echo "Importing schema from $SCHEMA_FILE..."
mysql --host="$MYSQL_HOST" --user="$MYSQL_USER" --password="$MYSQL_PASS" "$DB_NAME" < "$SCHEMA_FILE"
if [ $? -ne 0 ]; then
  echo "Failed to import schema" >&2
  exit 1
fi

echo "Database $DB_NAME created and schema imported."