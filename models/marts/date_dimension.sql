{% set end_year = run_started_at.year + 1 %}
{% set end_month = run_started_at.month %}
{% set end_day = run_started_at.day %}
{% if end_month == 2 and end_day == 29 %}
    {% set end_day = 28 %}
{% endif %}
{% set end_date = '%04d-%02d-%02d' | format(end_year, end_month, end_day) %}

{{ dbt_date.get_date_dimension('2017-01-01', end_date) }}
