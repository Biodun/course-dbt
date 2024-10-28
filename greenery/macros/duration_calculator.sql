{% macro duration_calculator(timestamp_column, result_name) %}
    min( {{ timestamp_column }} ) AS {{result_name }}_start_time,
    max( {{ timestamp_column }}) AS {{result_name }}_end_time,
    DATEDIFF(minute, {{result_name }}_start_time, {{result_name }}_end_time) AS {{result_name }}_duration_minutes

{% endmacro %}