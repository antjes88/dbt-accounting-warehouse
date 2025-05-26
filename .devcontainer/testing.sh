#!/bin/bash

set -e

echo "Compiling dbt project..."
dbt compile

echo "Dry running dbt project..."
dbt-dry-run