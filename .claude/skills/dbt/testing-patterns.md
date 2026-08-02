# dbt Testing Patterns — Feedbackito analytics project

Supporting reference for the project's [[dbt]] skill. Reflects what's actually tested today.

## Generic tests per layer
- Staging: `unique` + `not_null` on the primary/business key (`user_id`, `space_id`, `plan_id`,
  `ab_test_id`, `subscriber_id`). `accepted_values` on bounded/enum columns — e.g. `rating`
  against `[1, 2, 3, 4, 5]` with `quote: false` for numeric enums, `quote: true` for string enums
  (sentiment buckets).
- Marts: `not_null` on values consumed downstream (`fact_reviews.rating`); `accepted_values` on
  derived categorical columns (`fact_reviews.rating_sentiment` against
  `['promoter', 'passive', 'detractor']`).
- Not every column is tested — only the grain/PK and columns downstream logic depends on.
  Descriptive/free-text columns (`organization_name`, `name`, `email`, …) get a description but
  no test unless they're a key.
- `dim_users.name`/`.email` use `severity: warn` on `unique`/`not_null` rather than `error` —
  upstream data quality issues on these fields shouldn't fail the whole build. Use `warn` for
  this kind of soft, non-key user-attribute check; keep grain/PK tests at `error`.

## Grain tests
- No composite-key grain tests exist yet — every current model has a single-column PK/grain.
  If a future model needs a composite grain, use `dbt_utils.unique_combination_of_columns`
  (this is also `dbt-docs-helper`'s default for composite keys) — but note `dbt_utils` isn't
  installed yet (see Packages below), so add it as part of that change.

## Singular tests
- One in use: `tests/assert_stg_reviews_rating_positive.sql`. Naming convention:
  `assert_<model>_<condition>.sql`. Body is a `select` of the *violating* rows (empty result =
  pass) — not a boolean/count query.
- Reach for a singular test only when the check can't be expressed as a generic or `dbt_utils`
  test (a cross-column or cross-model business rule). Everything else belongs in `schema.yml`.

## Packages
- Only `dbt-labs/codegen` (0.14.0) is installed (`packages.yml`) — used for scaffolding, not
  testing. `dbt_utils` is not yet a dependency; add it the first time a composite-key or
  cross-model test is actually needed rather than pre-emptively.

## Severity & CI
- No CI test-gating pipeline exists (`.github/` only has `CODEOWNERS`, no workflow files) —
  tests currently run manually via `dbt build`. If CI is added, gate merges on `error`-severity
  tests only; the `severity: warn` tests on `dim_users` are intentionally non-blocking and
  should stay that way.
