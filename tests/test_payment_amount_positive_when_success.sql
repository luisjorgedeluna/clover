-- Custom test: Verify that payment amounts are positive when status='success'
-- This test fails if any successful payment has amount <= 0

select payment_id, amount, status
from {{ ref('payments') }}
where status = 'success' and amount <= 0

