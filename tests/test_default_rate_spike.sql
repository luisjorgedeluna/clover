-- Custom test: Detect default rate spikes
-- Fails if default_rate_D90 on day D >= 1.5 * median(default_rate_D90) over prior rolling 3 days (excluding D)
-- This test identifies days with unusually high default rates compared to recent history

with kpi_data as (
    select
        funded_date,
        default_rate_D90
    from {{ ref('kpi_daily_loans') }}
    where default_rate_D90 is not null
),

prior_3_days_median as (
    -- For each day, calculate median of default_rate_D90 from the 3 days before (excluding current day)
    select
        current.funded_date,
        current.default_rate_D90,
        PERCENTILE_CONT(0.5) WITHIN GROUP (
            ORDER BY prior.default_rate_D90
        )::numeric as median_prior_3_days
    from kpi_data current
    left join kpi_data prior
        on prior.funded_date < current.funded_date
        and prior.funded_date >= current.funded_date - INTERVAL '3 days'
    group by current.funded_date, current.default_rate_D90
    having COUNT(prior.funded_date) >= 1  -- Need at least 1 prior day to calculate median
)

select
    funded_date,
    default_rate_D90,
    median_prior_3_days,
    ROUND((1.5 * median_prior_3_days)::numeric, 2) as threshold,
    ROUND((default_rate_D90 - (1.5 * median_prior_3_days))::numeric, 2) as spike_amount
from prior_3_days_median
where default_rate_D90 >= 1.5 * median_prior_3_days
    and median_prior_3_days is not null

