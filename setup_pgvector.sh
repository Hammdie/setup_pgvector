#!/usr/bin/env bash
set -euo pipefail

# Optionaler Parameter: DB-User, dem wir Schema-Usage geben (Standard: odoo)
DB_USER="${1:-odoo}"

echo ">> Verwende DB-User für Rechte: ${DB_USER}"

# PostgreSQL Major-Version ermitteln
PG_MAJOR=$(sudo -u postgres psql -tAc "SHOW server_version;" | cut -d. -f1)
echo ">> Erkannte PostgreSQL-Version (Major): ${PG_MAJOR}"

echo ">> Installiere pgvector-Paket ..."
sudo apt-get update
sudo apt-get install -y "postgresql-${PG_MAJOR}-pgvector"

echo ">> Hole Liste aller Datenbanken (ohne Templates) ..."
DBS=$(sudo -u postgres psql -tAc "SELECT datname FROM pg_database WHERE datistemplate = false;")

for db in $DBS; do
  echo "---------------------------------------------"
  echo ">> Konfiguriere pgvector in Datenbank: ${db}"

  # Extension anlegen (falls noch nicht vorhanden)
  sudo -u postgres psql -d "$db" -c "CREATE EXTENSION IF NOT EXISTS vector;"

  # Prüfen, ob Rolle existiert – wenn ja, minimale Rechte setzen
  if sudo -u postgres psql -tAc "SELECT 1 FROM pg_roles WHERE rolname='${DB_USER}';" | grep -q 1; then
    echo ">> Vergabe von Schema-Usage auf public an '${DB_USER}' in DB ${db} ..."
    sudo -u postgres psql -d "$db" -c "GRANT USAGE ON SCHEMA public TO ${DB_USER};" || \
      echo "   (Konnte Rechte in ${db} nicht setzen – ignoriere.)"
  else
    echo ">> Rolle '${DB_USER}' existiert nicht – überspringe Rechtevergabe in ${db}."
  fi
done

echo "---------------------------------------------"
echo ">> pgvector Installation und Einrichtung abgeschlossen."
