select
    count(distinct case when num_page_views_for_product > 0 then session_id end) AS num_page_views,
    count(distinct case when num_add_to_cart_for_product > 0 then session_id end) as num_add_to_carts,
    count(distinct case when num_checkout_events_for_product > 0 then session_id end) as num_checkouts
from 
    {{ ref('fact_page_views')}}
    
