## About this project

This is the dbt analytics layer for **[Feedbackito](https://feedbackito.com)** (a feedback-widget SaaS product built on the [ShipFast](https://shipfa.st) + Supabase template — product repo: `shipfast-template-supabse`). Raw data is synced via Fivetran from the product's Supabase/Postgres database (reviews, profiles, surveys, spaces, plans, ab_tests, presale_subscribers, user_quotas) plus Google Search Console, and modeled here through staging → marts.

It's a real personal project, not a throwaway sandbox — and it also doubles as hands-on practice for the **dbt Developer Certification**.

### Using the starter project

Try running the following commands:
- dbt build


### Resources:
- Learn more about dbt [in the docs](https://docs.getdbt.com/docs/introduction)
- Check out [Discourse](https://discourse.getdbt.com/) for commonly asked questions and answers
- Join the [chat](http://slack.getdbt.com/) on Slack for live discussions and support
- Find [dbt events](https://events.getdbt.com) near you
- Check out [the blog](https://blog.getdbt.com/) for the latest news on dbt's development and best practices
