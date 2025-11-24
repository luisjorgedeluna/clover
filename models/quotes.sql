{{ config(
    materialized='table'
) }}

select
    quote_id::integer as quote_id,
    created_at::date as created_at,
    band::varchar(10) as band,
    system_size_kw::numeric(5, 2) as system_size_kw,
    down_payment::numeric(10, 2) as down_payment,
    system_price::numeric(10, 2) as system_price,
    email::varchar(255) as email
from {{ ref('quotes') }}


