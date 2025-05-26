#!/bin/bash
# shellcheck disable=SC1091,SC2059

rm -rf ./dbt_packages
source /usr/app/venv/bin/activate
dbt deps

git config --global --add safe.directory /workspaces/dbt-accounting-warehouse
gcloud auth login --enable-gdrive-access --update-adc

FILE="./.devcontainer/git_config.sh"
if [ -f "$FILE" ]; then
    chmod +x "$FILE"
    "$FILE"
else
    echo "$FILE not found. Follow instructions in README.md to set up git config. ### Configure Git"
fi