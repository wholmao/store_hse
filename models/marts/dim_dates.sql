{{ config(
    materialized='table',
    distributed_replicated=true,
    orientation='column'
) }}

with date_spine as (
    {{ dbt_utils.date_spine(
        datepart="day",
        start_date="cast('2026-03-01' as date)",
        end_date="cast('2026-07-12' as date)"
    ) }}
),

final as (
    select
        date_day as date_id,
        extract(year from date_day) as year,
        extract(quarter from date_day) as quarter,
        extract(month from date_day) as month,
        extract(day from date_day) as day_of_month,
        extract(dow from date_day) as day_of_week,
        case 
            when extract(dow from date_day) in (0, 6) then true 
            else false 
        end as is_weekend
    from date_spine
)

select * from final