#4. Calculate Incremental Sold Quantity for each category during Diwali campaign and provide ranking for categories in order of their ISU.
-------------------------------------------------------------------------------------------------------------------------------------------------------
  
  
  WITH ISU AS
  (SELECT p.category,
          round((sum(CASE
                         WHEN f.promo_type = 'BOGOF' THEN (2 * `quantity_sold(after_promo)`)
                         ELSE `quantity_sold(after_promo)`
                     END) - sum(f.`quantity_sold(before_promo)`)) / sum(f.`quantity_sold(before_promo)`) * 100, 2) AS `ISU%`
   FROM fact_events f
   JOIN dim_products p ON f.product_code = p.product_code
   WHERE f.campaign_id = 'CAMP_DIW_01'
   GROUP BY p.category)
SELECT *,
       Rank() over(
                   ORDER BY `ISU%` DESC) AS rank_order
FROM ISU;




# Calculates the Incremental Sold Units Percentage (ISU%) for each product category during the Diwali campaign (CAMP_DIW_01).
# Joins fact_events with dim_products using product_code to get product categories.
# Applies a condition:
    # If promo_type is 'BOGOF', it doubles the quantity_sold(after_promo) to reflect free units.
    # Otherwise, uses the original quantity_sold(after_promo).
# Subtracts total quantity_sold(before_promo) from adjusted quantity_sold(after_promo) to get incremental sold units 
# Divides the difference by quantity_sold(before_promo) and multiplies by 100 to get ISU%.
# Uses a Common Table Expression (CTE) named ISU to store the category-wise ISU%.
# In the final SELECT, ranks categories in descending order of ISU% using RANK().
# Displays category, ISU%, and its rank in the final result.
