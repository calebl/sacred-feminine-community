# /coverage

Run tests with coverage, analyze the report, and add tests for files with insufficient coverage.

## Process

1. **Run tests with coverage**
   - Execute `COVERAGE=1 bin/rails test` to generate the coverage report
   - Confirm all existing tests pass before proceeding

2. **Read the coverage report**
   - Parse `coverage/.last_run.json` for the overall coverage percentage
   - Parse `coverage/.resultset.json` to identify per-file line and branch coverage
   - List files sorted by coverage (lowest first)
   - Flag any file below 80% line coverage as needing attention

3. **Analyze coverage gaps**
   - For each under-covered file, read the source file
   - Identify which lines/branches lack coverage using the resultset data
   - Determine what test scenarios would exercise the uncovered code paths:
     - Untested controller actions
     - Untested model validations, callbacks, or methods
     - Untested policy conditions
     - Untested job logic
     - Untested error/edge-case branches

4. **Write missing tests**
   - For each gap, add tests to the appropriate existing test file (or create one if none exists)
   - Follow the project's existing test conventions:
     - Minitest (not RSpec)
     - Fixtures for test data (check `test/fixtures/` for available records)
     - `Devise::Test::IntegrationHelpers` for authenticated integration tests
     - Pundit policy tests should test both allowed and denied cases
   - Do NOT modify application code to improve coverage — only add tests

5. **Verify**
   - Run `COVERAGE=1 bin/rails test` again
   - Confirm new tests pass and coverage has improved
   - Report the before/after coverage percentages

## Output Format

```
## Coverage Report

**Before:** XX.X% line / XX.X% branch
**After:**  XX.X% line / XX.X% branch

### Files Improved
- `app/models/foo.rb`: 60% → 95%
- `app/controllers/bar_controller.rb`: 45% → 85%

### Tests Added
- `test/models/foo_test.rb`: [describe what was added]
- `test/controllers/bar_controller_test.rb`: [describe what was added]

### Remaining Gaps
- [Any files still under 80% with explanation of why]
```

## Important Rules

- Never modify application code to improve coverage. Only add or modify test files.
- Do not add trivial tests just to hit a number (e.g., testing that a constant exists). Tests should verify meaningful behavior.
- If a line is uncovered because it handles an edge case that's hard to trigger in tests (e.g., rescue blocks for external service failures), note it in "Remaining Gaps" rather than writing a brittle test.
- Keep tests focused and readable. One assertion concept per test method.
