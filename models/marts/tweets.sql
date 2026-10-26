with tweets as (
    select *
    from {{ ref('stg_tweets') }}
),

final as (
    select
        count(tweet_id) as count,
        max(tweeted_at) as most_recent,
        cast(datename(weekday, tweeted_at) as varchar(30)) as day_of_week_name
    from tweets
    group by datename(weekday, tweeted_at)
)

select *
from final
