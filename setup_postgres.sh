#!/bin/bash

# Script to set up PostgreSQL for dbt project

echo "Installing PostgreSQL..."
sudo apt-get update
sudo apt-get install -y postgresql postgresql-contrib

echo "Starting PostgreSQL service..."
sudo systemctl start postgresql
sudo systemctl enable postgresql

echo "Setting up database and user..."
sudo -u postgres psql << EOF
-- Create database
CREATE DATABASE clover_analytics;

-- Create user (you may want to change the password)
CREATE USER clover_user WITH PASSWORD 'clover_password';

-- Grant privileges
GRANT ALL PRIVILEGES ON DATABASE clover_analytics TO clover_user;

-- Connect to database and grant schema privileges
\c clover_analytics
GRANT ALL ON SCHEMA public TO clover_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO clover_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO clover_user;

\q
EOF

echo "PostgreSQL setup complete!"
echo "Update profiles.yml with:"
echo "  host: localhost"
echo "  user: clover_user"
echo "  password: clover_password"
echo "  dbname: clover_analytics"
echo "  port: 5432"


