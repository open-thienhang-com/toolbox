#!/bin/bash

# Description: 🔴 Postgres| Apply all migrations that have not yet been applied
# Author: thienhang.com
# Date: Feb 1, 2024
current_version="$(./migrations/current-version)"
printf '%-30s %s\n' "current datase version:" "$current_version"

for m in ./migrations/*/; do
    migration_version="$(basename $m)"
    if [[ ! "$migration_version" > "$current_version" ]]; then
        printf '%-30s %s\n' "up to date, skipping:" "$migration_version"
        continue
    fi
    printf '%-30s %s\n' "applying migration:" "$migration_version"
    script="${m}up.sql"
    if [[ ! -f $script ]]; then
        echo "missing up migration script $script"
        exit 1
    fi
    script_output="$(psql -f $script 2>&1)"
    if [[ $? -ne 0 ]]; then
        echo "problem during last migration step, exiting early:"
        echo $script_output
        exit 1
    fi
done

printf '%-30s %s\n' "done. database at version: " "$(./migrations/current-version)"
