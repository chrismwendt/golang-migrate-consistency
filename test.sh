#!/usr/bin/env bash

# Clean slate.
psql <<EOF > /dev/null
DROP DATABASE IF EXISTS migrate;
CREATE DATABASE migrate;
EOF

# Kick off a migration in the background.
migrate -database "postgres://${PGHOST}:${PGPORT}/migrate" -path ./migrations up 1 &
# Give the migrate command enough time to connect to Postgres and initiate the query.
sleep 0.5
# Kill the migrate command. The query will continue to execute in Postgres.
kill %1
# Suppress "Terminated" message
wait 2>/dev/null

# Give the Postgres host time to finish running the migration.
sleep 2

# Read dirty bit.
psql -t -d migrate <<EOF | grep . >/dev/null
select * from schema_migrations where dirty;
EOF
dirty=$?

# Check whether or not the migration succeeded.
psql -t -d migrate <<EOF | grep . >/dev/null
select * from foo;
EOF
succeeded=$?

# Report whether or not the DB is consistent.
if [ $dirty = 0 ] && [ $succeeded = 0 ]; then
  echo "INCONSISTENT: DB is marked dirty, but migration succeeded"
elif [ $dirty = 1 ] && [ $succeeded = 1 ]; then
  echo "INCONSISTENT: DB is marked clean, but migration failed"
elif [ $dirty = 0 ] && [ $succeeded = 1 ]; then
  echo "OK: DB is marked dirty and migration failed"
elif [ $dirty = 1 ] && [ $succeeded = 0 ]; then
  echo "OK: DB is marked clean and migration succeeded"
fi
