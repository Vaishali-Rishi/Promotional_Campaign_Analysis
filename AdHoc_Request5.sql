#5. Top 5 products ranked by IR% across all campaigns.
------------------------------------------------------------------------------------------------------------------------------------------------------------
  
WITH revenue_calc AS
  (SELECT p.product_name,
          p.category,
          sum(f.base_price * f.`quantity_sold(before_promo)`) AS `revenue_before_campaign`,
          SUM(CASE
                  WHEN promo_type = 'BOGOF' THEN (base_price * 0.5) * (2 * `quantity_sold(after_promo)`)
                  WHEN promo_type = '25% OFF' THEN (base_price - (base_price * 0.25)) * `quantity_sold(after_promo)`
                  WHEN promo_type = '50% OFF' THEN (base_price - (base_price * 0.50)) * `quantity_sold(after_promo)`
                  WHEN promo_type = '33% OFF' THEN (base_price - (base_price * 0.33)) * `quantity_sold(after_promo)`
                  WHEN promo_type = '500 Cashback' THEN (base_price - 500) * `quantity_sold(after_promo)`
                  ELSE base_price * `quantity_sold(after_promo)`
              END) AS `revenue_after_campaign`
   FROM fact_events f
   JOIN dim_products p ON f.product_code = p.product_code
   GROUP BY p.product_name,
            p.category)
  
SELECT product_name,
       category,
       sum(`revenue_after_campaign`-`revenue_before_campaign`) AS IR,
       round((sum(`revenue_after_campaign`-`revenue_before_campaign`)) / sum(`revenue_before_campaign`) * 100, 2) AS `IR%`,
       RANK() OVER(
                   ORDER BY (sum(`revenue_after_campaign`-`revenue_before_campaign`)) / sum(`revenue_before_campaign`) DESC) AS rank_order
FROM revenue_calc
GROUP BY product_name,
         category
ORDER BY `IR%` DESC
LIMIT 5;



# Calculates Incremental Revenue (IR) and IR% for each product across all campaigns.
# Uses a CTE revenue_calc to compute revenue before and after promotion based on promo_type.
# Applies different discount formulas for each promo type (e.g., BOGOF, 25% OFF, etc.).
# In the final query, calculates IR as the difference between post- and pre-campaign revenue.
# Computes IR% by dividing IR by revenue before the campaign and multiplying by 100.
# Ranks products based on IR% in descending order.
# Returns the top 5 products with the highest IR%.
