{{ config(
    materialized='table'
) }}

select
    payment_id::integer as payment_id,
    loan_id::integer as loan_id,
    payment_dt::date as payment_dt,
    amount::numeric(10, 2) as amount,
    status::varchar(50) as status
from {{ ref('payments') }}


