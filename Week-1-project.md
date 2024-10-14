# Week 1 Project

1. How many users do we have?
    > 
    ```sql
    SELECT COUNT(DISTINCT user_id) 
    FROM DEV_DB.DBT_BIODUNIWAYEMICLEARWAYENERGYCOM._stg_postgres__users; 
    ```
    __Answer:__ 130 users 
    

2. On average, how many orders do we receive per hour?
    > 
    ```sql
    WITH orders_by_hour AS (
        SELECT 
            DATE_PART(HOUR, created_at) AS "order_hour",
            COUNT(*) AS "num_orders_in_the_hour"
        FROM dev_db.dbt_bioduniwayemiclearwayenergycom._stg_postgres__orders
        GROUP BY DATE_PART(HOUR, CREATED_AT)
    ) 

    SELECT 
        ROUND(SUM("num_orders_in_the_hour") / COUNT(DISTINCT "order_hour"), 2) AS "Average # of orders per hour",
    FROM orders_by_hour;
    ```
    __Answer:__ 15.04 orders/hour

3. On average, how long does an order take from being placed to being delivered?
    >  
    
    ```sql
    WITH delivered_orders AS (
        SELECT 
            order_id,
            user_id,
            created_at,
            delivered_at,
            datediff(hour, created_at, delivered_at) AS "order_duration (hours)",
            datediff(hour, created_at, delivered_at)/24 AS "order_duration (days)"
        FROM dev_db.dbt_bioduniwayemiclearwayenergycom._stg_postgres__orders
        WHERE status = 'delivered'
    )

    SELECT
        AVG("order_duration (days)") AS "average_order_duration in days",
        AVG("order_duration (hours)") AS "average_order_duration in hours"
    FROM
        delivered_orders;
    ```
    
    __Answer:__ 93.4 hours or 3.9 days

4. How many users have only made:
    - One purchase?
        > __Answer:__ 25
    - Two purchases? 
        > __Answer:__ 28
    - Three+ purchases?
        > __Answer:__ 71

    ```sql
    WITH num_order_by_user AS (
        SELECT
            user_id,
            COUNT(DISTINCT ORDER_ID) AS "Number of orders"
        FROM dev_db.dbt_bioduniwayemiclearwayenergycom._stg_postgres__orders
        GROUP BY user_id
        ORDER BY COUNT(DISTINCT ORDER_ID)
    )

    SELECT
        "Number of orders",
        CASE WHEN "Number of orders" = 1 THEN COUNT("Number of orders") 
        ELSE 0 END AS "Number of users with only 1 order",

        CASE WHEN "Number of orders" = 2 THEN COUNT("Number of orders") 
        ELSE 0 END AS "Number of users who placed 2 orders",

        SUM(CASE WHEN "Number of orders" >2 THEN 1
        ELSE 0 END) AS "Number of users who placed 3 or more orders"

    FROM num_order_by_user
    GROUP BY "Number of orders"
    ```

5. On average, how many unique sessions do we have per hour?
    > 
    
    ```sql
    WITH num_sessions_by_hour AS (
        SELECT
            DATE_PART(HOUR, created_at) AS "hour_session_started",
            COUNT(*) AS "Number of sessions",
        
        FROM 
            dev_db.dbt_bioduniwayemiclearwayenergycom._stg_postgres__events
        GROUP BY DATE_PART(HOUR, created_at)
    )
    SELECT
        SUM("Number of sessions") AS "Total number of sessions",
        COUNT(DISTINCT "hour_session_started") AS "Number of distinct hours",
        AVG("Number of sessions") AS "Avg # of sessions per hour"
    FROM
        num_sessions_by_hour

    ```
    
    __Answer:__ 148 sessions per hour