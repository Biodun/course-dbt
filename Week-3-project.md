# Week 3 Project

### Part 1. Conversion Rate
1. What is our overall conversion rate?
    __Answer:__ 63%

    I created a `fact_session_sales` table to answer this question. It has the following columns:
    * session_id
    * was_purchase_completed
    * session_start_time
    * session_end_time
    * session_duration_minutes

    > 
    ```sql

    select
        SUM(CASE WHEN was_purchase_completed = TRUE THEN 1 ELSE 0 END) AS num_of_sessions_with_a_purchase,
        SUM(CASE WHEN was_purchase_completed = FALSE THEN 1 ELSE 0 END) AS num_of_sessions_without_a_purchase,
        (num_of_sessions_with_a_purchase + num_of_sessions_without_a_purchase) AS num_unique_sessions,
        div0(num_of_sessions_with_a_purchase, num_unique_sessions) AS conversion_rate
    from
        fact_sessions_sales;
    
    ```
    

2. What is our conversion rate by product?
    __Answer:__ XX

    > 
    ```sql
    
    ```

2. Why are some products converting at higher/lower rates than others?

    __Answer:__ Factors could include product prices, the season of the year, popularity of a product based on good press, promos and other factors.
 
### Part 2. Macros
Create a macro to simplify part of your model(s)

1. __duration_calculator__ macro: This macro calculates the start, end and duration of a specified event, session or occurance in one of our tables. It makes it easy to quickly add event duration data to a table. 

    > 
    ```jinja
        {% macro duration_calculator(timestamp_column, result_name) %}

            min( {{ timestamp_column }} ) AS {{result_name }}_start_time,
            max( {{ timestamp_column }}) AS {{result_name }}_end_time,
            DATEDIFF(minute, {{result_name }}_start_time, {{result_name }}_end_time) AS {{result_name }}_duration_minutes

        {% endmacro %}
    
    ```
    Usage

    ```sql
        select
            session_id,
            {{ duration_calculator("created_at", "session") }}
        from 
            {{ ref('_stg_postgres__events') }}
        group by 1
    ```

    The result is:

    ```sql

        select
            session_id,
            min( created_at ) AS session_start_time,
            max( created_at) AS session_end_time,
            DATEDIFF(minute, session_start_time, session_end_time) AS session_duration_minutes
        from 
            dev_db.dbt_bioduniwayemiclearwayenergycom._stg_postgres__events
        group by 1

    ```


### Part 3. Granting Permissions
I added a post-hook for a macro called __grant_permissions__ to grant access permissions for the _reporter_ role for all the tables and schema's created in this dbt project. 

Macro:

    ```sql
    {% macro grant_permissions(role) %}

    {% set grants_query %}
        GRANT USAGE ON SCHEMA {{ schema }} to ROLE {{ role }};
        GRANT SELECT ON {{ this }} to ROLE {{ role }};
    {% endset %}

    {% set table =  run_query(grants_query) %}

    {% endmacro %}
    ```
Macro documentation:

    ```yaml
    - name: grant_permissions
      description: Grants the user-specified permissions the schema's and models created by the dbt operations in this project. 
      arguments:
        - name: role
          type: string
          description: The Snowflake role that we want to grant permissions to.
    ```

Post-hook definition
    

    ```yaml

    models:
        greenery:
            # Config indicated by + and applies to all files under models/example/
            +post-hook:
            - "{{ grant_permissions(role='reporting') }}"

    ```

### Part 4. dbt Packages
I installed the __`dbt_expectations`__ package and used it's `expect_table_column_count_to_equal` test to validate the number of columns in one of my intermediate tables:

```yaml
    models:
    - name: aggregated_session_data
        description: Aggregated metrics for each session (session duration, number of page views, final step, was purchase completed, etc.)
        tests:
        - dbt_expectations.expect_table_column_count_to_equal:
            value: 10
```


### Part 5. Show your DAG
1. XXX    



### Part 6. dbt Snapshots
1. What products had their inventory change from week 2 to week 3

    __Answer:__ 
    The X products below all had a drop in inventory:
    
    | Name | Old inventory level | New inventory level |
    | --- | --- | ---- | 
    | Bamboo | 56 | 44 | 
    | Monstera | 64 | 50 | 
    | Philodendron| 25 | 15 | 
    | Pothos | 20 | 0 | | 
    | String of pearls | 10  | 0 | 
    | ZZ Plant | 89 | 53 | 
