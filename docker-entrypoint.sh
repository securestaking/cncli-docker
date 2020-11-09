#!/usr/bin/env bash
set -eE

function err_hook() {
    echo "ERROR on line $1"
}

trap 'err_hook $LINENO' ERR 

if [ -z "$TARGET_HOST" ]; then
    TARGET_HOST=localhost
fi

if [ -z "$TARGET_PORT" ]; then
    TARGET_PORT=3000
fi

if [ -z "$DB_LOCATION" ]; then
    DB_LOCATION='storage/sqlite.db'
fi

if [ -z "$NETWORK_MAGIC" ]; then
    NETWORK_MAGIC=764824073
fi

cncli sync --host $TARGET_HOST --port $TARGET_PORT --db $DB_LOCATION --network-magic $NETWORK_MAGIC