{{ config(
    distributed_replicated=true,
    orientation='column'
) }}

with customers as (
    select * from {{ ref('stg_shop__customers') }}
),

confirm as (
    select 
        order_id,
        customer_id,
        order_amount,
        order_date
    from {{ ref('fct_orders') }}
    where is_confirmed = true
),

first_order as (
    select 
        customer_id,
        order_id as first_confirmed_order_id,
        order_date as first_confirmed_at
    from (
        select 
            customer_id,
            order_id,
            order_date,
            row_number() over (partition by customer_id order by order_date asc, order_id asc) as rn
        from confirm
    ) num
    where rn = 1
),

agg as (
    select
        customer_id,
        count(order_id) as confirmed_orders_count,
        sum(order_amount) as confirmed_revenue
    from confirm
    group by customer_id
),

final as (
    select
        c.*,
        f.first_confirmed_order_id,
        f.first_confirmed_at,
        coalesce(a.confirmed_orders_count, 0) as confirmed_orders_count,
        coalesce(a.confirmed_revenue, 0) as confirmed_revenue,
        case 
            when a.confirmed_orders_count > 0 then true 
            else false 
        end as is_buyer
    from customers c
    left join first_order f on c.customer_id = f.customer_id
    left join agg a on c.customer_id = a.customer_id
)

select * from final