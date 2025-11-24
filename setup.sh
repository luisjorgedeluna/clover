#!/bin/bash

# Setup script for dbt project with virtual environment

set -e

echo "Setting up dbt project..."

# Check if virtual environment exists
if [ ! -d "venv" ]; then
    echo "Creating virtual environment..."
    python3 -m venv venv
fi

# Activate virtual environment
echo "Activating virtual environment..."
source venv/bin/activate

# Upgrade pip
echo "Upgrading pip..."
pip install --upgrade pip

# Install requirements
echo "Installing dbt and dependencies..."
pip install -r requirements.txt

echo ""
echo "Setup complete! To use dbt, activate the virtual environment:"
echo "  source venv/bin/activate"
echo ""
echo "Then you can run:"
echo "  dbt seed  # Load CSV files into database"
echo "  dbt run   # Create tables from models"
echo "  dbt test  # Run data quality tests"

