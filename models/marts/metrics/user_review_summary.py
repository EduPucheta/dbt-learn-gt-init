import pyspark.sql.functions as F


def model(dbt, session):
    dbt.config(
        submission_method="serverless",
        materialized="table",
    )

    reviews = dbt.ref("fact_reviews")

    return (
        reviews.filter(F.col("user_id").isNotNull())
        .groupBy("user_id", "plan")
        .agg(
            F.count("*").alias("review_count"),
            F.avg("rating").alias("average_rating"),
            F.sum(F.when(F.col("rating_sentiment") == "promoter", 1).otherwise(0)).alias("promoter_count"),
            F.sum(F.when(F.col("rating_sentiment") == "passive", 1).otherwise(0)).alias("passive_count"),
            F.sum(F.when(F.col("rating_sentiment") == "detractor", 1).otherwise(0)).alias("detractor_count"),
        )
    )
