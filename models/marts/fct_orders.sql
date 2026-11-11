{{ config(distributed_by='order_id', orientation='column') }}
-- Задание 4. Факт заказов: одна строка — один заказ. Тестовые заказы в витрину не попадают.
-- Материализация — table (задана для папки marts в dbt_project.yml).
with orders as (
    select
        order_id,
        customer_id,
        order_date,
        ordered_at,
        order_status,
        order_amount,
        paid_amount,
        refunded_amount,
        net_paid_amount,
        successful_payments_count,
        first_paid_at,
        is_confirmed
    from {{ ref('int_orders_with_payments') }}
    where not is_test_order
),

items as (
    select
        order_id,
        count(distinct product_id) as items_count
    from {{ ref('stg_shop__order_items') }}
    group by order_id
)

select
    o.*,
    coalesce(i.items_count, 0) as items_count
from orders o
left join items i on o.order_id = i.order_id