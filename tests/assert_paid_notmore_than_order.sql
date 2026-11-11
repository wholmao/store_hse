{{ config(severity='warn') }}

select 
    order_id, 
    order_amount, 
    paid_amount
from {{ ref('fct_orders') }}
where paid_amount > order_amount