{% macro fabric_date_series(datepart, start_date, end_date) %}
  select
    cast(
      {{ dbt.dateadd(datepart, 'numbers.generated_number', start_date) }}
      as {{ dbt.type_timestamp() }}
    ) as date_{{ datepart }}
  from (
    select
      {% for bit in range(14) %}
        p{{ bit }}.generated_number * power(2, {{ bit }})
        {% if not loop.last %} + {% endif %}
      {% endfor %}
      as generated_number
    from
      {% for bit in range(14) %}
        (select 0 as generated_number union all select 1) as p{{ bit }}
        {% if not loop.last %} cross join {% endif %}
      {% endfor %}
  ) as numbers
  where numbers.generated_number < {{ dbt.datediff(start_date, end_date, datepart) }}
{% endmacro %}

{% macro fabric__date_spine(datepart, start_date, end_date) %}
  {{ fabric_date_series(datepart, start_date, end_date) }}
{% endmacro %}

{% macro fabric__get_date_dimension(start_date, end_date) %}
  {% set date_dimension_sql = dbt_date.default__get_date_dimension(start_date, end_date) %}
  {{ return(date_dimension_sql | replace('order by 1', '')) }}
{% endmacro %}

{% macro fabric__get_base_dates(start_date, end_date, n_dateparts, datepart) %}
  {% if start_date and end_date %}
    {% set start_date = "cast('" ~ start_date ~ "' as " ~ dbt.type_timestamp() ~ ")" %}
    {% set end_date = "cast('" ~ end_date ~ "' as " ~ dbt.type_timestamp() ~ ")" %}
  {% elif n_dateparts and datepart %}
    {% set start_date = dbt.dateadd(datepart, -1 * n_dateparts, dbt_date.today()) %}
    {% set end_date = dbt_date.tomorrow() %}
  {% else %}
    {{ exceptions.raise_compiler_error(
        "get_base_dates requires start_date and end_date, or n_dateparts and datepart"
    ) }}
  {% endif %}

  {{ fabric_date_series(datepart, start_date, end_date) }}
{% endmacro %}
