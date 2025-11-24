#!/bin/bash
set -e

echo "Waiting for PostgreSQL to start..."
# Simple wait loop (could use wait-for-it.sh for robustness, but this suffices for demo)
sleep 5

echo "Running dbt seeds..."
dbt seed

echo "Running dbt models..."
dbt run

echo "Running dbt tests..."
# We allow tests to fail without stopping the script immediately, 
# so we can generate the report with failure details.
# However, 'set -e' would stop it. Let's capture the exit code.
set +e
dbt test
TEST_EXIT_CODE=$?
set -e

echo "Generating KPI report..."
python generate_kpi_report.py

echo "Done! Report generated at kpi_report.html"
echo "Test exit code: $TEST_EXIT_CODE"

# Exit with the test exit code if you want the container to fail on test failure
# exit $TEST_EXIT_CODE
