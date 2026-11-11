{{ config(
    materialized='table',
    distributed_by='product_id',
    orientation='column'
) }}

with products as (
    select * from {{ ref('stg_shop__products') }}
),

cats as (
    select * from {{ ref('stg_shop__product_categories') }}
),

tree as (
    select * from {{ ref('int_product_categories') }}
),

joined as (
    select
        p.product_id,
        p.product_name,
        p.brand,
        c.category_name,
        p_c.category_name as parent_category_name,
        tree.root_category_name
    from products p
    left join cats c 
        on p.category = c.category_name
    left join cats p_c 
        on c.parent_category_id = p_c.category_id
    left join tree 
        on c.category_id = tree.category_id
)

select * from joined