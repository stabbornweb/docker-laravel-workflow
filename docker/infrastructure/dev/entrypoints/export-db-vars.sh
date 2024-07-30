#!/bin/sh

# Specify the variables to export
VARS="DB_PASSWORD DB_USERNAME DB_DATABASE"

# Source the source.env file
set -a
. ./source.env
set +a

# Append the specified variables to target.env
for VAR in $VARS; do
    # shellcheck disable=SC2039
    echo "$VAR=${!VAR}" >> target.env
done
