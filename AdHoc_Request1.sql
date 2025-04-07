# 1.List of products with base price greater than 500 that are featured in BOGOF.
-----------------------------------------------------------------------------------------------------------------------------------------------------------

SELECT DISTINCT p.product_code,
                p.product_name,
                f.base_price,
                f.promo_type
FROM fact_events f
JOIN dim_products p ON f.product_code = p.product_code
WHERE (f.base_price > 500) AND (promo_type = 'BOGOF');



# -Selects unique product records using DISTINCT to avoid duplicates.
# -Joins the fact_events table with dim_products table using product_code.
# -Filters results using WHERE clause to only include: Products where base_price is greater than 500 and Promotion type is 'BOGOF' (Buy One Get One Free)


 
