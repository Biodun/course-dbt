with session_sale_data AS (
    -- Sessions with sales
    select 
        session_id,
        was_purchase_completed
    from {{ ref('fact_page_views') }}
    where was_purchase_completed = True
    group by session_id, was_purchase_completed

    union

    -- Sessions without sales
        (
            select 
                session_id,
                was_purchase_completed
            from {{ ref('fact_page_views') }}
            where was_purchase_completed = False
            group by session_id, was_purchase_completed
        )
),
events as (
    select * from {{ ref('_stg_postgres__events')}}
)

select 
    sales.session_id,
    was_purchase_completed,
    {{ duration_calculator('created_at', "session")}},
    
from 
    session_sale_data sales

join
    events on events.session_id = sales.session_id

group by 1, 2
