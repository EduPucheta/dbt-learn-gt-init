---
name: dbt
description: Use when authoring, structuring, or reviewing dbt models in this project (Feedbackito analytics on BigQuery) — model layering, naming, materializations, BigQuery-specific macros/UDFs/Python models, sources, and grants. Project-specific; overrides the generic cross-project dbt skill while working in this repo. See testing-patterns.md for test guidance.
---

# dbt Conventions — Feedbackito analytics project

Grounded in this repo's actual models, macros, and config — not aspirational rules. Update this
file when a new pattern is established, or when something below is superseded.

## Project layout
- `models/staging/` — one `stg_` model per source table. Sources declared in
  `models/staging/sources.yml`; all staging model docs/tests live in a single
  `models/staging/schema.yml` (not one yml per model).
- `models/marts/core/` — core business entities (`dim_users`, `fact_reviews`), own `schema.yml`.
- `models/marts/metrics/` — aggregates built on top of core marts, own `schema.yml`. Includes
  both SQL (`surveys_avgs.sql`) and Python (`user_review_summary.py`) models.
- No `models/intermediate/` layer exists yet — marts currently select straight from staging
  (e.g. `dim_users` ← `stg_profiles`). Don't add an `int_` layer speculatively; introduce it only
  once real reuse/complexity across marts justifies it.
- `functions/` — BigQuery persistent UDFs (dbt's `functions` project path), e.g.
  `rating_to_sentiment.sql` + matching `.yml` doc block.
- `seeds/` — static lookups (e.g. `rating_sentiment_map.csv`). When a seed mirrors UDF logic for
  contexts where the UDF isn't called, keep both in sync and cross-reference them in the
  descriptions (see `rating_sentiment_map` ↔ `functions/rating_to_sentiment.sql`).
- `snapshots/` — SCD2 snapshots of mutable source tables, defined as YAML blocks (`relation:
  source(...)`, not embedded in `.sql`), e.g. `profiles_snapshot.yml`.

## Naming
- Same-source (Supabase/Fivetran, `raw` source) staging models: `stg_<entity>` —
  `stg_reviews`, `stg_profiles`, `stg_spaces`, `stg_plans`, `stg_ab_tests`,
  `stg_presale_subscribers`, `stg_survey_devices`, `stg_user_quotas`.
- Staging models from a *different* source system get a double-underscore source tag:
  `stg__<source_system>__<entity>` — e.g. `stg__gsc__site_report_by_site` (Google Search
  Console). Use this form only when the source isn't the main product DB.
- Marts use `dim_` / `fact_` in full — **not** the `fct_` abbreviation. Match this exact spelling
  for new marts (`dim_users`, `fact_reviews`).
- Metrics/aggregate models beyond core facts/dims have no fixed prefix — name them for what they
  report (`surveys_avgs`, `user_review_summary`).
- Always `ref()` / `source()` — no hardcoded table names anywhere in this project; keep it that way.

## Materializations
- Staging: explicit `{{ config(materialized='view') }}` in the model even where it matches the
  project default — keep doing this for clarity (see `stg_reviews.sql`).
- Marts: `table`, set via `dbt_project.yml` (`models.jaffle_shop.marts.+materialized: table`) —
  no need to repeat it per-model unless overriding.
- Python models: configured inline via `dbt.config(materialized="table",
  submission_method="serverless")` inside `model(dbt, session)` — this runs on Dataproc
  serverless, not project YAML config.

## BigQuery specifics
- `macros/generate_schema_name.sql` / `generate_database_name.sql`: only the `dev`/`prod` targets
  use the custom schema name as-is; any other target gets the default schema prefixed
  (`{default}_{custom}`), keeping ad hoc/sandbox targets isolated. Database name is only
  overridden when the target name contains `"prod"`.
- `dispatch` block in `dbt_project.yml` puts the `public` macro namespace before `dbt` so the
  custom `generate_schema_name` macro is the one dbt actually calls.
- BigQuery IAM grants are configured directly in `schema.yml` under a model's `config.grants`
  block (see `stg_reviews`, which grants `roles/bigquery.dataViewer` to a specific user) —
  replicate this pattern rather than managing grants outside dbt.
- Remote UDFs live under `functions/`, each with a description + typed `arguments`/`returns` in
  the sibling `.yml`. Reference the UDF's file path in the consuming column's description (see
  `fact_reviews.rating_sentiment`).

## Testing
See [[testing-patterns]] (`testing-patterns.md` in this skill folder) for what's tested, at
which layer, and current package/CI status.

## Related
- Docs/YAML scaffolding for a model is handled by the separate `dbt-docs-helper` skill
  (`/dbt-helper`) — use it to generate or update a `schema.yml` from a model's SQL; it already
  knows to mirror this project's existing yml style.
