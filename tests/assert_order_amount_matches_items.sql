with order_sums as (
    select
        o.order_id,
        o.order_amount,
        sum(oi.line_amount) as line_tot
    from {{ ref('fct_orders') }} o
    left join {{ ref('fct_order_items') }} oi on o.order_id = oi.order_id
    group by o.order_id, o.order_amount
)
select * from order_sums
where order_amount != coalesce(line_tot, 0)