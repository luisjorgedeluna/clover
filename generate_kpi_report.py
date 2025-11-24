import os
import psycopg2
from jinja2 import Environment, FileSystemLoader
from datetime import datetime

# Database connection parameters
DB_PARAMS = {
    "host": os.getenv("DB_HOST", "localhost"),
    "database": os.getenv("DB_NAME", "clover_analytics"),
    "user": os.getenv("DB_USER", "clover_user"),
    "password": os.getenv("DB_PASSWORD", "clover_password"),
    "port": os.getenv("DB_PORT", "5432")
}

def get_data():
    conn = psycopg2.connect(**DB_PARAMS)
    cur = conn.cursor()
    cur.execute("""
        SELECT 
            funded_date, 
            funded_count, 
            default_rate_d90, 
            avg_apr, 
            principal_weighted_margin 
        FROM kpi_daily_loans 
        ORDER BY funded_date DESC
    """)
    data = cur.fetchall()
    cur.close()
    conn.close()
    return data

def get_test_results(test_file):
    with open(test_file, 'r') as f:
        sql = f.read()
    
    # Simple replacement for dbt ref
    sql = sql.replace("{{ ref('kpi_daily_loans') }}", "kpi_daily_loans")
    
    conn = psycopg2.connect(**DB_PARAMS)
    cur = conn.cursor()
    try:
        cur.execute(sql)
        failures = cur.fetchall()
        columns = [desc[0] for desc in cur.description]
    except Exception as e:
        print(f"Error running test {test_file}: {e}")
        failures = []
        columns = []
    finally:
        cur.close()
        conn.close()
    
    return {
        "name": os.path.basename(test_file),
        "status": "FAIL" if failures else "PASS",
        "failures": [dict(zip(columns, row)) for row in failures],
        "columns": columns
    }

def generate_report():
    data = get_data()
    
    if not data:
        print("No data found")
        return

    # Run tests
    tests = [
        "tests/test_default_rate_spike.sql",
        "tests/test_volume_drop.sql"
    ]
    test_results = []
    for test_file in tests:
        if os.path.exists(test_file):
            test_results.append(get_test_results(test_file))

    # Format data for display
    formatted_data = []
    
    # Data for charts (need to be chronological, so reverse the desc order)
    chart_dates = []
    chart_funded_counts = []
    chart_default_rates = []
    
    # Data is ordered by date DESC
    dates = [row[0] for row in data]
    min_date = min(dates).strftime("%Y-%m-%d")
    max_date = max(dates).strftime("%Y-%m-%d")

    for row in data:
        formatted_data.append({
            "date": row[0].strftime("%Y-%m-%d"),
            "funded_count": row[1],
            "default_rate": f"{row[2]:.2f}%" if row[2] is not None else "N/A",
            "avg_apr": f"{row[3]*100:.2f}%" if row[3] is not None else "N/A",
            "margin": f"{row[4]*100:.2f}%" if row[4] is not None else "N/A"
        })

    # Prepare chart data (chronological)
    for row in reversed(data):
        chart_dates.append(row[0].strftime("%Y-%m-%d"))
        chart_funded_counts.append(row[1])
        chart_default_rates.append(float(row[2]) if row[2] is not None else 0)

    env = Environment(loader=FileSystemLoader('.'))
    template = env.get_template('kpi_report_template.html')
    
    html_output = template.render(
        data=formatted_data,
        generated_at=datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
        date_range=f"{min_date} to {max_date}",
        chart_dates=chart_dates,
        chart_funded_counts=chart_funded_counts,
        chart_default_rates=chart_default_rates,
        test_results=test_results
    )
    
    with open('kpi_report.html', 'w') as f:
        f.write(html_output)
    
    print("Report generated: kpi_report.html")

if __name__ == "__main__":
    generate_report()
