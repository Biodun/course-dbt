with aggregated_session_events as (
    select * 
    from {{ ref('aggregated_session_data') }}
),

order_items as (
    select *
    from {{ ref('_stg_postgres__order_items') }}
),


events as (
    select * from {{ ref('_stg_postgres__events')}}
)

select
    events.session_id,
    coalesce(events.product_id, order_items.product_id) as product_id,
    sum(case when events.event_type = 'page_view' then 1 else 0 end) as num_page_views_for_product,
    sum(case when events.event_type = 'add_to_cart' then 1 else 0 end) as num_add_to_cart_for_product,
    sum(case when events.event_type = 'checkout' then 1 else 0 end) as num_checkout_events_for_product,
    sum(case when events.event_type = 'package_shipped' then 1 else 0 end) as num_package_shipped_events_for_product,
    agg_events.session_start_time,
    agg_events.session_end_time ,
    agg_events.session_duration_minutes,
    agg_events.num_pageviews_in_session,
    agg_events.num_add_to_cart_events_in_session,
    agg_events.num_checkout_events_in_session,
    agg_events.num_package_shipped_events_in_session,
    agg_events.final_session_event,
    agg_events.was_purchase_completed

from 
    events
join
    aggregated_session_events as agg_events on agg_events.session_id = events.session_id
left join 
    order_items on order_items.order_id = events.order_id
group by all
