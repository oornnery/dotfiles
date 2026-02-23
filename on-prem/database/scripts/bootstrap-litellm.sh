#!/bin/sh
set -e

required_vars="POSTGRES_USER POSTGRES_PASSWORD POSTGRES_DB"
for var_name in $required_vars; do
  eval "var_value=\${$var_name}"
  if [ -z "$var_value" ]; then
    echo "Missing required env var: $var_name" >&2
    exit 1
  fi
done

export PGPASSWORD="$POSTGRES_PASSWORD"

resolve_env_ref() {
  value="$1"

  case "$value" in
    '$'{*})
      var_name="${value#\$\{}"
      var_name="${var_name%\}}"
      ;;
    '$'*)
      var_name="${value#\$}"
      ;;
    *)
      echo "$value"
      return 0
      ;;
  esac

  case "$var_name" in
    *[!A-Za-z0-9_]*|'')
      echo "Invalid env var reference: $value" >&2
      exit 1
      ;;
  esac

  eval "resolved=\${$var_name}"
  if [ -z "$resolved" ]; then
    echo "Env var $var_name is not set" >&2
    exit 1
  fi

  echo "$resolved"
}

ensure_db_and_role() {
  db_name="$1"
  db_user="$2"
  db_pass="$3"

  if [ -z "$db_name" ] || [ -z "$db_user" ] || [ -z "$db_pass" ]; then
    echo "Invalid entry. Expected: <db_name>:<db_user>:<db_password>" >&2
    exit 1
  fi

  echo "Ensuring database '$db_name' and role '$db_user'..."

  psql -v ON_ERROR_STOP=1 \
    -h postgres \
    -p 5432 \
    -U "$POSTGRES_USER" \
    -d "$POSTGRES_DB" <<EOSQL
SELECT format('CREATE ROLE %I LOGIN PASSWORD %L', '$db_user', '$db_pass')
WHERE NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = '$db_user')\gexec
SELECT format('ALTER ROLE %I WITH LOGIN PASSWORD %L', '$db_user', '$db_pass')\gexec
SELECT format('CREATE DATABASE %I OWNER %I', '$db_name', '$db_user')
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = '$db_name')\gexec
EOSQL

  echo "Done: '$db_name' / '$db_user'"
}

attempt=1
max_attempts=30
until psql -h postgres -p 5432 -U "$POSTGRES_USER" -d "$POSTGRES_DB" -c 'SELECT 1;' >/dev/null 2>&1; do
  if [ "$attempt" -ge "$max_attempts" ]; then
    echo "Failed to connect to postgres after $max_attempts attempts" >&2
    exit 1
  fi

  echo "Waiting for authenticated Postgres connection ($attempt/$max_attempts)..."
  attempt=$((attempt + 1))
  sleep 2
done

echo "Postgres connection ready, applying LiteLLM bootstrap SQL..."

databases_file="${DATABASES_FILE:-/databases}"
if [ ! -f "$databases_file" ]; then
  echo "Missing databases file at $databases_file" >&2
  exit 1
fi

echo "Reading databases from: $databases_file"

while IFS= read -r line; do
  line="$(printf '%s' "$line" | tr -d '\r')"

  case "$line" in
    ''|\#*)
      continue
      ;;
  esac

  IFS=':' read -r raw_name raw_user raw_pass extra <<-EOF
$line
EOF

  raw_name="$(printf '%s' "$raw_name" | tr -d '\r')"
  raw_user="$(printf '%s' "$raw_user" | tr -d '\r')"
  raw_pass="$(printf '%s' "$raw_pass" | tr -d '\r')"
  extra="$(printf '%s' "$extra" | tr -d '\r')"

  if [ -n "$extra" ]; then
    echo "Invalid entry. Expected: <db_name>:<db_user>:<db_password>" >&2
    exit 1
  fi

  db_name="$(resolve_env_ref "$raw_name")"
  db_user="$(resolve_env_ref "$raw_user")"
  db_pass="$(resolve_env_ref "$raw_pass")"
  ensure_db_and_role "$db_name" "$db_user" "$db_pass"
done < "$databases_file"

echo "Database bootstrap completed successfully"
