-- Custom test: Verify that all payment amounts are positive (no negative values)
-- This test fails if any payment amount is <= 0

select payment_id, amount
from {{ ref('payments') }}
where amount <= 0

