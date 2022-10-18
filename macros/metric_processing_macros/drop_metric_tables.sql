{% macro drop_metric_tables() %}
    {%- set metric_tables_dict = dbt_utils.get_query_results_as_dict(get_metric_tables()) -%}
    {%- for fully_qualified_bq_table in metric_tables_dict['fully_qualified_bq_table'] %}
       DROP TABLE {{fully_qualified_bq_table}};
    {%- endfor -%}
{% endmacro %}