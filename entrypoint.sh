#!/bin/bash
# File: sleep_tracker/entrypoint.sh
# docker entrypoint script.

# # assign a default for the database_user
# DB_USER=${DATABASE_USER:-postgres}

# # wait until Postgres is ready
# while ! pg_isready -q -h $DATABASE_HOST -p $DB_PORT -U $DB_USER
# do
#   echo "$(date) - waiting for database to start"
#   sleep 2
# done

bin="/app/bin/sleep_tracker"
eval "$bin eval \"SleepTracker.Release.create_and_migrate\""
# start the elixir application
exec "$bin" "start"
