# dbt Certification Practice Roadmap

Ideas for exercising this repo against the dbt Analytics Engineering Certification exam domains. Check items off as you complete them.

## New tables to wire up: `plans` and `user_quotas`
Found in the `public` dataset (same `raw` source as `profiles`/`reviews`/`surveys`) but not yet declared in the project. Real schemas, confirmed via BigQuery on 2026-07-29:

- `plans`: `id`, `plan_name`, `plan_monthly_token_quota`, `plan_monthly_responses`, `created_at` (+ Fivetran metadata cols). Small dimension, 3 rows (Free/Pro/Scale).
- `user_quotas`: `user_id`, `tokens_used`, `monthly_cap`, `quota_reset_date`, `created_at`, `updated_at` (+ Fivetran metadata cols). One row per user, and rows genuinely change over time (`tokens_used`/`updated_at` move) — this is a much better snapshot candidate than a static table.

Exercises:
- [ ] Add `plans` and `user_quotas` to [sources.yml](models/staging/sources.yml) under the `raw` source, with column descriptions
- [ ] Build `stg_plans.sql` and `stg_user_quotas.sql` following the existing staging pattern (source CTE -> renamed CTE, exclude Fivetran metadata columns like `ctid_fivetran_id`/`_fivetran_synced`)
- [ ] Add a `relationships` test: `stg_user_quotas.user_id` -> `stg_profiles.user_id` (needs `dbt_utils`, see Testing below)
- [ ] Add a business-rule test that `tokens_used <= monthly_cap` — good candidate for the custom generic test exercise below
- [ ] Extend `dim_users` (or add a new `fct_user_usage` mart) joining `stg_user_quotas` + `stg_plans` to compute quota remaining per user
- [ ] Snapshot `user_quotas` instead of a hypothetical table — `strategy: timestamp`, `updated_at` as the timestamp column — and actually watch it accumulate history across a couple of `dbt snapshot` runs

## Developing dbt models
- [ ] Split `fact_reviews` join logic into an `int_reviews_joined` intermediate model (try `ephemeral` materialization)
- [ ] Convert `fact_reviews` to `incremental` (`is_incremental()`, `unique_key`, merge strategy)
- [ ] Fix naming convention on `stg__gsc__site_report_by_site` (double underscore, no renaming/casting yet)

## User-defined functions (UDFs)
This project runs on dbt Fusion (`dbt-fusion 2.0.0-preview.177`), which has **native first-class UDF support** as a resource type — not the old dbt-core pattern of a macro + `on-run-start` hook running raw `CREATE FUNCTION` DDL. See https://docs.getdbt.com/docs/build/udfs.
- [x] Reference example: `rating_to_sentiment` — defined as a proper `functions/` resource: body in [functions/rating_to_sentiment.sql](functions/rating_to_sentiment.sql), config (arguments/returns) in [functions/rating_to_sentiment.yml](functions/rating_to_sentiment.yml), declared via `function-paths: ["functions"]` in [dbt_project.yml](dbt_project.yml). Called from [fact_reviews.sql](models/marts/core/fact_reviews.sql) as `{{ function('rating_to_sentiment') }}(cast(r.rating as int64))` — dbt resolves the qualified name and adds a real DAG edge (`function public.rating_to_sentiment` builds before `model public.fact_reviews`, confirmed via `dbt list --select "resource_type:function"` and `dbt build --select "rating_to_sentiment+"`). Tested with `accepted_values` on the resulting column in [schema.yml](models/marts/core/schema.yml). Note: the source `rating` column comes through as `BIGNUMERIC`, so it needs `cast(rating as int64)` to match the UDF's declared `int64` argument.
- [ ] Practice: write a second UDF yourself following the same pattern — e.g. `quota_status(tokens_used, monthly_cap)` returning `'over'`/`'near_limit'`/`'ok'` for the planned `user_quotas` work above, or a JS UDF body (`functions/*.js`, supported on BigQuery) for something like normalizing an email domain on `stg_profiles`
- [ ] Practice: add a `unit_tests:` case (dbt 1.8+/Fusion) against a model that calls your UDF — the docs show `dbt build --select "+my_model_to_test" --empty` to make sure the UDF exists first
- [ ] Practice: reuse a UDF's logic inside a custom generic test (e.g. assert no row's `quota_status` UDF output is `'over'` for more than N% of users) — ties together the UDF and custom generic test exercises

## Testing
- [ ] Install `dbt-labs/dbt_utils` and add a `relationships` test between `fact_reviews.user_id` and `dim_users.user_id`
- [ ] Turn `assert_stg_reviews_rating_positive.sql` into a reusable custom generic test (macro with `test_` prefix) — reuse it for the `tokens_used <= monthly_cap` check on `user_quotas` above
- [ ] Add `unit_tests:` (dbt 1.8+) for `stg_reviews` or `surveys_avgs`
- [ ] Add source freshness config on `raw.reviews` / `raw.profiles` and run `dbt source freshness`

## Documentation
- [ ] Flesh out `google_search_console.site_report_by_site` source columns (currently "Do not know this table yet")
- [ ] Add a doc block (`.md` + `{{ doc(...) }}`) for a column reused across models (e.g. `plan`)
- [ ] Add an `exposures.yml` describing a dashboard consuming `surveys_avgs`
- [ ] Run `dbt docs generate` and review the DAG/lineage view

## Ad hoc analyses (`analysis/`)
The `analysis/` folder (wired up via `analysis-paths` in [dbt_project.yml](dbt_project.yml)) holds one-off reporting SQL that compiles with `ref()`/`source()` like a model but isn't part of the DAG — no materialization, no `schema.yml` tests/docs.
- [x] Reference examples added: [nps_by_survey.sql](analysis/nps_by_survey.sql) (conditional aggregation / ratios via `countif`), [user_review_activity.sql](analysis/user_review_activity.sql) (window functions: `row_number`, `lag`, `avg() over`), [plan_review_summary.sql](analysis/plan_review_summary.sql) (join + group by across `dim_users`/`fact_reviews`)
- [ ] Practice: run `dbt compile --select path:analysis` and inspect the compiled SQL under `target/compiled/.../analysis/`
- [ ] Practice: once `user_quotas`/`plans` are wired up (see above), write an analysis joining them in for a quota-utilization-by-plan report

## Deployment / project mechanics
- [ ] Add a `staging` target and confirm `generate_schema_name` / `generate_database_name` behavior with `dbt run --target staging`
- [ ] Add tags (`tag: core`, `tag: metrics`) and practice selectors (`dbt build --select tag:core+`, `--select state:modified+`)
- [ ] Wire up a minimal GitHub Actions workflow running `dbt build`
