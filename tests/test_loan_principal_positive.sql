-- Custom test: Verify that all loan principals are positive (no negative values)
-- This test fails if any principal is <= 0

select loan_id, principal
from {{ ref('loans') }}
where principal <= 0

