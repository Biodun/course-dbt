# Week 4 Project

### Part 1. dbt Snapshots
1. Which products had their inventory change from week 3 to week 4?

    __Answer:__ 

    | Name | Old inventory level | New inventory level |
    | --- | --- | ---- | 
    | Bamboo | 44 | 23 | 
    | Monstera | 50 | 31 | 
    | Philodendron| 15 | 30 | 
    | Pothos | 0 | 20 | | 
    | String of pearls | 0  | 10 | 
    | ZZ Plant | 53 | 41 | 

    > 
    ```sql
    select * 
    from
        products_snapshot
    where
        product_id in (
            -- Items that were updated this week
            select
                product_id
            from products_snapshot
            where
                date_trunc(week, dbt_updated_at) = date_trunc(week, current_date())
            )
    order by name
    ```
    

2. Which products had the most fluctuations in inventory? 
    
    __Answer:__ 
    
    String of pearls. It's inventory levels went from 58 to 10 to 0 and then back to 10.

    > 
    ```sql
    select
        name,
        VARIANCE(inventory) AS inventory_variance
    from
        products_snapshot
    where
        product_id in 
        (
            -- Product id's that had a change
            select 
                product_id
            from 
                products_snapshot
            where
                dbt_valid_to IS NOT NULL
        )
        
    group by 1
    order by inventory_variance desc;
    
    ```

2. Did we have any items go out of stock in the last 3 weeks??

    __Answer:__ 

    Yes, the following products went of stock
    
    * Pothos
    * String of pearls 

    ```sql
    select 
        *
    from 
        products_snapshot
    where
        inventory = 0;

    ```

 
### Part 2. Modeling challenge

1. Create any additional dbt models needed to help answer these questions from our product team

    __Answer:__

    I created a `greenery_aggregate_funnel` table to visualize Greenery's product funnel, and show how sessions transition from one event to another. 

    > 
 
    ```sql
        select
            count(distinct case when num_page_views_for_product > 0 then session_id end) AS num_page_views,
            count(distinct case when num_add_to_cart_for_product > 0 then session_id end) as num_add_to_carts,
            count(distinct case when num_checkout_events_for_product > 0 then session_id end) as num_checkouts
        from 
            fact_page_views;
    ```
2. Which steps in the funnel have largest drop off points?

    __Answer:__

    The biggest drop off is between the `add to cart` and `checkout` events. Only 77.3% of `add to cart` events transition to a `checkout` event.
    
3. Use an exposure on your product analytics model to represent that this is being used in downstream BI tools

    __Answer:__

    I created an exposure called `greenery_product_funnel` that points to a Sigma dashboard with the product funnel data.
    
    ```yaml
    version: 2

    exposures:

    - name: greenery_product_funnel
        type: dashboard
        maturity: low
        url: https://app.sigmacomputing.com/corise-dbt/workbook/Greenery-Sales-Funnel-6G44i05c4vTwfbMScYAuWV
        description: >
        Table and funnel chart showing the what percentage of page views transition to add to cart and checkout events
        
        depends_on:
        - ref('greenery_aggregate_funnel')
        
        owner:
        name: Biodun Iwayemi
            
    ```


### Part 3. Reflections and next steps

1. __dbt next steps for you:__  If your organization is thinking about using dbt, how would you pitch the value of dbt/analytics engineering to a decision maker at your organization?
    
    __Answer:__

    dbt offers several beneficial features including excellent visualizations of the lineage of each table; version control of data transformations; user-friendly documentation of data models all of which make for cleaner and more maintainable data platforms.

2. __Setting up for production / scheduled dbt run of your project__: After learning about the various options for dbt deployment and seeing your final dbt project, how would you go about setting up a production/scheduled dbt run of your project in an ideal state ?
    
    __Answer:__

    I will setup an instance of dbt Core and connect it to our Snowflake instance, and dbt runs would be scheduled using Dagster. Some models would be run daily, while others will be hourly depending on how frequently the dashboards they drive expect new data.

