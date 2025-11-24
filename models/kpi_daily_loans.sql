{{ config(
    materialized='table'
) }}

with daily_loans as (
    select
        funded_at::date as funded_date,
        loan_id,
        apr,
        principal
    from {{ ref('loans') }}
    where funded_at is not null
        and status NOT IN ('cancelled', 'withdrawn')
),

loans_with_defaults as (
    -- Identify loans with failed/missed payments within D90 window
    -- D90 window: funded_at to funded_at + 90 days (inclusive)
    -- Payments after this window are ignored for this KPI
    select distinct
        dl.funded_date,
        dl.loan_id
    from daily_loans dl
    inner join {{ ref('payments') }} p
        on dl.loan_id = p.loan_id
    where p.status IN ('failed', 'missed')
        and p.payment_dt::date >= dl.funded_date
        and p.payment_dt::date <= (dl.funded_date + INTERVAL '90 days')
)

select
    dl.funded_date,
    COUNT(DISTINCT dl.loan_id) as funded_count,
    ROUND(
        100.0 * COUNT(DISTINCT CASE WHEN lwd.loan_id IS NOT NULL THEN dl.loan_id END) / 
        NULLIF(COUNT(DISTINCT dl.loan_id), 0),
        2
    ) as default_rate_D90,
    CASE 
        WHEN COUNT(DISTINCT dl.loan_id) = 0 THEN NULL
        ELSE ROUND(AVG(dl.apr), 4)
    END as avg_apr,
    CASE 
        WHEN COUNT(DISTINCT dl.loan_id) = 0 THEN NULL
        ELSE ROUND(SUM(dl.principal * (dl.apr - 0.05)) / NULLIF(SUM(dl.principal), 0), 4)
    END as principal_weighted_margin
from daily_loans dl
left join loans_with_defaults lwd
    on dl.loan_id = lwd.loan_id
    and dl.funded_date = lwd.funded_date
group by dl.funded_date
order by dl.funded_date

