# Custom Tests

This folder contains custom SQL tests (singular tests) that require custom logic beyond the generic tests available in `schema.yml`.

## When to Use Custom Tests vs schema.yml

### Use `schema.yml` for:
- ✅ Generic tests: `unique`, `not_null`, `accepted_values`, `relationships`
- ✅ Simple validation rules
- ✅ Tests that are defined alongside model documentation

### Use `tests/` folder for:
- ✅ Complex business logic
- ✅ Custom SQL queries that don't fit generic test patterns
- ✅ Tests that need to return specific rows (fail if any rows returned)
- ✅ Multi-table validations
- ✅ Custom calculations or aggregations

## How Custom Tests Work

Custom tests in the `tests/` folder:
- Must return 0 rows to pass
- If any rows are returned, the test fails
- Use `{{ ref('model_name') }}` to reference models
- Are run with `dbt test` just like generic tests

## Example Custom Tests

- `test_loan_principal_positive.sql` - Ensures all loan principals are positive
- `test_payment_amount_positive.sql` - Ensures all payment amounts are positive
- `test_payment_amount_positive_when_success.sql` - Ensures successful payments have positive amounts

