with session_event_counts as (
    select
        session_id,
        SUM(CASE WHEN event_type = 'page_view' THEN 1 ELSE 0 END) AS num_pageviews_in_session,
        SUM(CASE WHEN event_type = 'add_to_cart' then 1 else 0 end) as num_add_to_cart_events_in_session,
        sum(case when event_type = 'checkout' then 1 else 0 end) as num_checkout_events_in_session,
        sum(case when event_type = 'package_shipped' then 1 else 0 end) as num_package_shipped_events_in_session
from 
    {{ ref('_stg_postgres__events') }}
group by 1

),
session_duration AS (
    select
        session_id,
        min(created_at) AS session_start_time,
        max(created_at) AS session_end_time,
        DATEDIFF(minute, session_start_time, session_end_time)  AS session_duration_minutes
    from 
        {{ ref('_stg_postgres__events') }}
    group by 1
),

ranked_event_timestamps AS (
    SELECT 
        session_id,
        created_at,
        event_type,
        RANK() over (partition by session_id order by created_at desc) AS event_rank
    from {{ ref('_stg_postgres__events') }}
)

select
    ranked_events.session_id,
    session_dur.session_start_time,
    session_dur.session_end_time,
    session_dur.session_duration_minutes,
    event_counts.num_pageviews_in_session,
    event_counts.num_add_to_cart_events_in_session,
    event_counts.num_checkout_events_in_session,
    event_counts.num_package_shipped_events_in_session,
    ranked_events.event_type AS final_session_event,
    (final_session_event = 'package_shipped') OR (final_session_event = 'checkout') AS was_purchase_completed,
    
    
from ranked_event_timestamps ranked_events
join session_duration as session_dur ON session_dur.session_id = ranked_events.session_id
join session_event_counts as event_counts on event_counts.session_id = ranked_events.session_id
where
    event_rank = 1
