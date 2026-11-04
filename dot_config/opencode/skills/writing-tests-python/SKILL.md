---
name: writing-tests-python
description: Use when modifying or writing Python tests.
---

# Writing Python tests

## General guidance

- Always use Pytest as the testing framework.
- Prefer using `pathlib.Path` over string paths whenever available.
- Minimize setup code.
- Minimize usage of `mocker`/`monkeypatch` in integration tests. Excessive usage can
  quickly lead to testing an unrealistic scenario. This rule applies to unit tests as
  well, but to a slightly relaxed extent.
- Do not rewrite unrelated or unmodified tests to match the style asserted by this skill.

## Test style

- Unit tests live under `tests/unit`, integration tests under `tests/integration`.
- Always use type hints in all function signatures.
- Helpers and fixtures go at the top of the relevant current section (top of the file,
  if there are no sections).
- Follow the arrange-act-assert pattern, using an extra newline to delineate each step.
- Do not create a test class (e.g., `class TestFunctionality`) to encapsulate a group of
  tests unless the file you are modifying already uses that pattern. Prefer free-standing
  test functions, grouped by purpose.

## Parametrization

- Always consider if you can use `@pytest.mark.parametrize` on a test.
- Attempt to coalesce multiple new tests into a single parametrized test when possible.
- Consider if a new feature can be covered by adding a new variant to an existing test,
  either as a new variant or by making the test parametrized.
- Always use `pytest.param(..., id=...)` for test variants, using clear and brief names
  to disambiguate tests.
- Only add a comment above a test variant if the value of the `id` kwarg is insufficient.
  This should not happen often.
- Be wary of parametrized tests with `if` statements that branch based on the parameter.
  This is commonly an indicator that the test should be split into two distinct tests.
  This is highly subjective; if unsure, write the test as one test and then show the
  user the outcome and ask them if it should be split.

## Fixtures

- Fixtures should be used whenever tests duplicate setup logic.
- Avoid defining new autouse fixtures.
- Check the available fixtures using `uv run pytest --fixtures`.
