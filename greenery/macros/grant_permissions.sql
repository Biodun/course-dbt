{% macro grant_permissions(role) %}

    {% set grants_query %}
        GRANT USAGE ON SCHEMA {{ schema }} to ROLE {{ role }};
        GRANT SELECT ON {{ this }} to ROLE {{ role }};
    {% endset %}

    {% set table =  run_query(grants_query) %}

{% endmacro %}