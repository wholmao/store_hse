with source as (
    select sum(o.total_amount) as source_sum
    from {{ source('shop', 'orders') }} o
    where o.status = 'paid' and exists (
          select 1 from {{ source('shop', 'payments') }} p
          where p.order_id = o.order_id and p.payment_status = 'success' and p.amount > 0
      )
),
mart as (
    select sum(order_amount) as mart_sum
    from {{ ref('fct_orders') }}
    where is_confirmed = true
)
select * from mart, source
where mart_sum != source_sum