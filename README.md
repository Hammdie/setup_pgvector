# pgvector Setup Script

Automatisiertes Setup-Script zur Installation und Konfiguration von pgvector für PostgreSQL auf Debian/Ubuntu-Systemen.

## Funktion

Das Script führt im Wesentlichen folgende Schritte aus:

1. **PostgreSQL-Major-Version ermitteln:**
   ```sql
   SHOW server_version;
   ```

2. **Passendes pgvector-Paket installieren:**
   ```bash
   sudo apt-get install -y postgresql-<PG_MAJOR>-pgvector
   ```

3. **Alle nicht-Template-Datenbanken abrufen:**
   ```sql
   SELECT datname FROM pg_database WHERE datistemplate = false;
   ```

4. **Für jede dieser Datenbanken:**
   - Extension erstellen:
     ```sql
     CREATE EXTENSION IF NOT EXISTS vector;
     ```
   - Falls die angegebene Rolle existiert:
     ```sql
     GRANT USAGE ON SCHEMA public TO <ROLLE>;
     ```

> **Hinweis:** Es wird kein `ALTER EXTENSION ... OWNER TO ...` verwendet, da Extensions keinen Owner im klassischen Sinne besitzen und dieser Befehl zu einem Syntaxfehler führt.

## Voraussetzungen

- Debian-/Ubuntu-basiertes System mit `apt`
- Installierter und laufender PostgreSQL-Server
- Zugriff als `root` oder ein User mit `sudo`-Rechten
- `psql` muss verfügbar sein
- Zugriff auf den PostgreSQL-Superuser `postgres` (via `sudo -u postgres`)

## Installation

Script herunterladen und ausführbar machen:

```bash
wget https://raw.githubusercontent.com/Hammdie/setup_pgvector/main/setup_pgvector.sh -O setup_pgvector.sh
chmod +x setup_pgvector.sh
```

Alternativ: Aus der Repo-Struktur auschecken und ausführbar machen.

## Nutzung

### Standardaufruf (DB-User: `odoo`)

```bash
sudo ./setup_pgvector.sh
```

### Mit explizitem Datenbank-User

```bash
sudo ./setup_pgvector.sh odoo
```

oder z. B.:

```bash
sudo ./setup_pgvector.sh myappuser
```

### Was der Parameter macht

Der optionale erste Parameter ist der Name der Datenbankrolle, der Schema-Usage auf `public` in jeder Datenbank gegeben wird:

```sql
GRANT USAGE ON SCHEMA public TO odoo;
```

Wenn die Rolle nicht existiert, wird dieser Schritt einfach übersprungen.

## Beispielausgabe

```
>> Verwende DB-User für Rechte: odoo
>> Erkannte PostgreSQL-Version (Major): 16
>> Installiere pgvector-Paket ...
>> Hole Liste aller Datenbanken (ohne Templates) ...
---------------------------------------------
>> Konfiguriere pgvector in Datenbank: postgres
CREATE EXTENSION
>> Vergabe von Schema-Usage auf public an 'odoo' in DB postgres ...
GRANT
---------------------------------------------
>> Konfiguriere pgvector in Datenbank: prod
CREATE EXTENSION
>> Vergabe von Schema-Usage auf public an 'odoo' in DB prod ...
GRANT
---------------------------------------------
>> pgvector Installation und Einrichtung abgeschlossen.
```

## Hinweise

- Das Script arbeitet bewusst über **alle nicht-Template-Datenbanken**.
- Wenn du es nur für bestimmte Datenbanken (z. B. `odoo%`) ausführen möchtest, kannst du die SQL-Query im Script anpassen:
  ```sql
  SELECT datname
  FROM pg_database
  WHERE datistemplate = false
    AND datname LIKE 'odoo%';
  ```
- Der Aufruf sollte nach Möglichkeit nur **einmal pro Server/Installation** nötig sein.
- Durch `CREATE EXTENSION IF NOT EXISTS` ist das Script **idempotent** und kann gefahrlos erneut ausgeführt werden.
- Ideal für Setups, in denen mehrere Odoo-Datenbanken auf einem PostgreSQL-Server laufen und alle pgvector nutzen sollen.

## Lizenz

Nutze das Script frei in deinen Projekten. Anpassungen für eigene Zwecke sind ausdrücklich erwünscht. 🙂
