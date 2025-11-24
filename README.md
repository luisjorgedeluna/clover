# Clover Analytics dbt Project

This dbt project contains seeds for loans, payments, and quotes data, and creates corresponding PostgreSQL tables with proper data types and KPIs.

## Quick Start with Docker

Run the entire project (database, dbt models, tests, and report generation) with a single command:

```bash
docker-compose up --build
```

This will:
1. Start a PostgreSQL container.
2. Build the dbt project container.
3. Run `dbt seed`, `dbt run`, and `dbt test`.
4. Generate the `kpi_report.html` in your local directory.

**Note for Windows Users:**
If you encounter errors, ensure you have cloned the repository with LF line endings or that `.gitattributes` is present (it is included in this repo).

## Project Structure

```
dbt_project/
├── dbt_project.yml      # Main configuration file
├── profiles.yml         # Database connection profiles (not committed to git)
├── setup_postgres.sh    # PostgreSQL setup script
├── setup.sh             # Python virtual environment setup
├── run_dbt.sh           # Helper script to run dbt commands
├── requirements.txt     # Python dependencies
├── seeds/               # CSV seed files
│   ├── loans.csv
│   ├── payments.csv
│   └── quotes.csv
├── models/              # SQL models
│   ├── loans_final.sql        # Loans table model (creates 'loans' table)
│   ├── payments_final.sql     # Payments table model (creates 'payments' table)
│   ├── quotes_final.sql       # Quotes table model (creates 'quotes' table)
│   ├── kpi_daily_loans.sql    # Daily loan KPIs
│   └── schema.yml             # Model documentation and tests
├── tests/               # Custom SQL tests
│   ├── test_loan_principal_positive.sql
│   ├── test_payment_amount_positive.sql
│   └── test_payment_amount_positive_when_success.sql
├── macros/              # Jinja macros
└── venv/                # Python virtual environment
```

## Setup Instructions

### 1. Install PostgreSQL

Run the setup script to install and configure PostgreSQL:
```bash
cd dbt_project
./setup_postgres.sh
```

Or manually install PostgreSQL:
```bash
sudo apt-get update
sudo apt-get install -y postgresql postgresql-contrib
sudo systemctl start postgresql
sudo systemctl enable postgresql
```

Then create the database and user:
```bash
sudo -u postgres psql
CREATE DATABASE clover_analytics;
CREATE USER clover_user WITH PASSWORD 'clover_password';
GRANT ALL PRIVILEGES ON DATABASE clover_analytics TO clover_user;
\c clover_analytics
GRANT ALL ON SCHEMA public TO clover_user;
\q
```

### 2. Install dbt and PostgreSQL Adapter

**Option A: Using the setup script (recommended)**
```bash
cd dbt_project
./setup.sh
```

**Option B: Manual setup with virtual environment**
```bash
cd dbt_project
python3 -m venv venv
source venv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt
```

**Note:** Always activate the virtual environment before using dbt:
```bash
source venv/bin/activate
```

### 3. Configure Database Connection

The `profiles.yml` file is pre-configured with default values. Update it if you used different credentials:
- `user`: Database user (default: clover_user)
- `password`: Database password (default: clover_password)
- `dbname`: Database name (default: clover_analytics)

### 4. Load Seeds into Database

**Make sure the virtual environment is activated:**
```bash
cd dbt_project
source venv/bin/activate
dbt seed
```

Or use the helper script:
```bash
./run_dbt.sh seed
```

This will create seed tables: `_seed_loans`, `_seed_payments`, and `_seed_quotes` in your PostgreSQL database.

### 5. Run Models to Create Tables

**Make sure the virtual environment is activated:**
```bash
source venv/bin/activate
dbt run
```

Or use the helper script:
```bash
./run_dbt.sh run
```

This will create PostgreSQL tables:
- `loans` - Loan information with proper data types
- `payments` - Payment records with proper data types
- `quotes` - Quote information with proper data types
- `kpi_daily_loans` - Daily loan KPIs (funded_count, default_rate_D90)

### 6. Run Tests

**Make sure the virtual environment is activated:**
```bash
source venv/bin/activate
dbt test
```

Or use the helper script:
```bash
./run_dbt.sh test
```

This will run data quality tests defined in `schema.yml` and custom tests in the `tests/` folder.

## Quick Reference

All dbt commands can be run using the helper script:
```bash
./run_dbt.sh <command>
```

Examples:
- `./run_dbt.sh seed` - Load seeds
- `./run_dbt.sh run` - Run models
- `./run_dbt.sh test` - Run tests
- `./run_dbt.sh compile` - Compile models
- `./run_dbt.sh docs generate` - Generate documentation
- `./run_dbt.sh --version` - Check version

## Data Types

The models use the following PostgreSQL data types:

### Loans Table
- `loan_id`: INTEGER
- `quote_id`: INTEGER
- `funded_at`: DATE
- `principal`: NUMERIC(10, 2)
- `apr`: NUMERIC(5, 4)
- `term_months`: INTEGER
- `status`: VARCHAR(50)

### Payments Table
- `payment_id`: INTEGER
- `loan_id`: INTEGER
- `payment_dt`: DATE
- `amount`: NUMERIC(10, 2)
- `status`: VARCHAR(50)

### Quotes Table
- `quote_id`: INTEGER
- `created_at`: DATE
- `band`: VARCHAR(10)
- `system_size_kw`: NUMERIC(5, 2)
- `down_payment`: NUMERIC(10, 2)
- `system_price`: NUMERIC(10, 2)
- `email`: VARCHAR(255)

## KPIs

### kpi_daily_loans
- `funded_date`: Date loans were funded
- `funded_count`: Number of loans funded on each day
- `default_rate_D90`: Percentage of loans funded on that day that had any payment with status 'failed' or 'missed' within 90 days

## Seeds

The project includes three seed files:
- **loans.csv**: Loan information including loan_id, quote_id, funded_at, principal, APR, term_months, and status
- **payments.csv**: Payment records with payment_id, loan_id, payment_dt, amount, and status
- **quotes.csv**: Quote data with quote_id, created_at, band, system_size_kw, down_payment, system_price, and email

## Tests

### Generic Tests (in schema.yml)
- Primary key uniqueness and not null tests
- Foreign key relationship tests
- Accepted values tests (status, band)
- Not null tests for required fields

### Custom Tests (in tests/ folder)
- `test_loan_principal_positive`: Ensures all loan principals are positive
- `test_payment_amount_positive`: Ensures all payment amounts are positive
- `test_payment_amount_positive_when_success`: Ensures successful payments have positive amounts

## Querying Tables in PostgreSQL

### Option 1: Local Connection (if psql is installed)

Connect to PostgreSQL:
```bash
PGPASSWORD=clover_password psql -h localhost -U clover_user -d clover_analytics
```

### Option 2: Via Docker Container

If you are running the project via Docker, you can access the database inside the container:

1. Find the container ID or name:
   ```bash
   docker ps
   ```
   (Look for the container named `dbt_project-postgres-1` or similar)

2. Connect to the database:
   ```bash
   docker exec -it dbt_project-postgres-1 psql -U clover_user -d clover_analytics
   ```

### Example Queries

Once connected (via either method), you can run SQL queries:

```sql
-- View all loans
SELECT * FROM loans LIMIT 5;

-- View KPI table
SELECT * FROM kpi_daily_loans ORDER BY funded_date DESC;

-- Check for volume drops (manual check)
SELECT * FROM kpi_daily_loans WHERE funded_count <= 2;

-- Disable pager for better experience with wide tables
\pset pager off
```

To exit the psql shell, type `\q`.

## Troubleshooting

### Virtual Environment
Always activate the virtual environment before running dbt:
```bash
source venv/bin/activate
```

### PostgreSQL Connection
If you get connection errors, verify PostgreSQL is running:
```bash
sudo systemctl status postgresql
```

### Table Not Found
Make sure you've run both `dbt seed` and `dbt run` to create all tables.

