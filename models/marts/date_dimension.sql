{% set sql_stmt %}
    select {{ dateadd(datepart="year", interval=1, from_date_or_timestamp=current_timestamp()) }} as val
{% endset %}
{{ dbt_date.get_date_dimension('2017-01-01', dbt_utils.get_single_value(sql_stmt)) }}
