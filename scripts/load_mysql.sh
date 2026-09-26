#!/usr/bin/env bash
# Loads the ClassicModels challenge database into a local MySQL / MariaDB server.
# Usage:  ./scripts/load_mysql.sh [mysql-user]      (you will be asked for the password)
set -euo pipefail
cd "$(dirname "$0")/.."
USER_NAME="${1:-root}"
echo "Creating schema ..."
mysql -u "$USER_NAME" -p < sql/01_schema.sql
echo "Loading data (about 145,000 rows) ..."
mysql -u "$USER_NAME" -p < sql/02_data.sql
echo "Done. Open the 'classicmodels' database and start with sql/03_queries.sql"
