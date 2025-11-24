-- Custom test: Detect volume drops
-- Fails if funded_count on day D <= 0.5 * median(funded_count) over prior rolling 3 days (excluding D)

with kpi_data as (
    select
        funded_date,
        funded_count
    from {{ ref('kpi_daily_loans') }}
    where funded_count is not null
),

prior_3_days_median as (
    -- For each day, calculate median of funded_count from the 3 days before (excluding current day)
    select
        current.funded_date,
        current.funded_count,
        PERCENTILE_CONT(0.5) WITHIN GROUP (
            ORDER BY prior.funded_count
        )::numeric as median_prior_3_days
    from kpi_data current
    left join kpi_data prior
        on prior.funded_date < current.funded_date
        and prior.funded_date >= current.funded_date - INTERVAL '3 days'
    group by current.funded_date, current.funded_count
    having COUNT(prior.funded_date) >= 1  -- Need at least 1 prior day to calculate median
)

select
    funded_date,
    funded_count,
    median_prior_3_days,
    ROUND((0.5 * median_prior_3_days)::numeric, 2) as threshold,
    ROUND((median_prior_3_days - funded_count)::numeric, 2) as drop_amount
from prior_3_days_median
where funded_count <= 0.5 * median_prior_3_days
    and median_prior_3_days is not null
