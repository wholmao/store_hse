with recursive category_tree as (
    select
        category_id,
        category_name,
        parent_category_id,
        1 as level,
        category_name as root_category_name,
        category_name as category_path
    from {{ ref('stg_shop__product_categories') }}
    where parent_category_id is null

    union all

    select
        child.category_id,
        child.category_name,
        child.parent_category_id,
        parent.level + 1 as level,
        parent.root_category_name as root_category_name,
        parent.category_path || ' > ' || child.category_name as category_path
    from {{ ref('stg_shop__product_categories') }} child
    join category_tree parent 
        on child.parent_category_id = parent.category_id
)

select * from category_tree