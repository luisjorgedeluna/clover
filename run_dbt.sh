#!/bin/bash

# Helper script to run dbt commands with virtual environment activated

cd "$(dirname "$0")"

# Activate virtual environment
source venv/bin/activate

# Run dbt command with all arguments
dbt "$@"

