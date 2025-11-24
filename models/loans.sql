{{ config(
    materialized='table'
) }}

select
    loan_id::integer as loan_id,
    quote_id::integer as quote_id,
    funded_at::date as funded_at,
    principal::numeric(10, 2) as principal,
    apr::numeric(5, 4) as apr,
    term_months::integer as term_months,
    status::varchar(50) as status
from {{ ref('loans') }}


