with checkout_events as (
    select 
        session_id,
        user_id,
        order_id,
        event_id,
        created_at,
        event_type
    from {{ ref('_stg_postgres__events') }}
    where event_type = 'checkout'
)

select 
    orders.order_id,
    chkout.session_id,
    items.product_id,
    chkout.user_id,
    chkout.event_id,
    chkout.created_at,
    prods.name,
    prods.inventory,
    prods.price,
    items.quantity,
    (prods.price * items.quantity) as sale_amount,
    chkout.event_type,
    
    
from {{ ref('_stg_postgres__orders') }} as orders
inner join checkout_events as chkout on chkout.order_id = orders.order_id
left join {{ ref('_stg_postgres__order_items') }} as items on items.order_id = orders.order_id
left join {{ ref('_stg_postgres__products') }} prods on prods.product_id = items.product_id

order by orders.order_id, chkout.session_id