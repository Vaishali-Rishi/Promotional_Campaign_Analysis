-------------------------------------------------------------- PROJECT- ANALYSIS OF PROMOTIONAL CAMPAIGNS --------------------------------------------------------------

-- Using Database
use retail_events_db;

-- Viewing all the records
SELECT * FROM dim_campaigns;
SELECT * FROM dim_products;
SELECT * FROM dim_stores;
SELECT * FROM fact_events;

-- Adding required columns

-- 1. Adjusted column
ALTER TABLE fact_events ADD adjusted_quantity decimal;
UPDATE fact_events SET adjusted_quantity = case when promo_type = 'BOGOF' THEN `quantity_sold(after_promo)` * 2
												else `quantity_sold(after_promo)` end;

-- 2. Promotional Price
ALTER TABLE fact_events ADD promotional_price decimal;
UPDATE fact_events SET promotional_price = case when promo_type = 'BOGOF' THEN base_price * 0.5
												when promo_type = '25% OFF' THEN base_price - (base_price * 0.25)
                                                when promo_type = '50% OFF' THEN base_price - (base_price * 0.50)
                                                when promo_type = '33% OFF' THEN base_price - (base_price * 0.33)
												else base_price end;
 
-- 3. Revenue before promo
ALTER TABLE fact_events ADD revenue_before_promo int;
UPDATE fact_events SET revenue_before_promo = base_price * `quantity_sold(before_promo)`;

-- 3. Revenue after promo
ALTER TABLE fact_events ADD revenue_after_promo int;
UPDATE fact_events SET revenue_after_promo = case when promo_type = '500 Cashback' then (promotional_price * adjusted_quantity) - 500
												  else promotional_price * adjusted_quantity end ;


----------------------------------------------------------------------- ANALYSIS -------------------------------------------------------------------------

#1.List of products with base price greater than 500 that are featured in BOGOF
SELECT DISTINCT p.product_code, product_name, f.base_price, f.promo_type
FROM fact_events f JOIN dim_products p ON f.product_code = p.product_code
WHERE (f.base_price > 500) AND (promo_type = 'BOGOF');


#2. Number of stores in each city
SELECT city, count(store_id) as store_count
FROM dim_stores
GROUP BY city
ORDER BY store_count desc;


#3. Display each campaign along with total revenue generated before and after the campaign
SELECT c.campaign_name, round((sum(f.revenue_before_promo)/1000000),2) as `revenue_before_campaign (In million)`, 
						round((sum(f.revenue_after_promo)/1000000),2) as `revenue_after_campaign (In million)`
                        
FROM fact_events f JOIN dim_campaigns c ON f.campaign_id = c.campaign_id
GROUP BY c.campaign_name;


#4. Calculate Incremental Sold Quantity for each category during Diwali campaign and provide ranking for categories in order of their ISU.
SELECT p.category, round((sum(f.`quantity_sold(after_promo)`) - sum(f.`quantity_sold(before_promo)`)) /  sum(f.`quantity_sold(before_promo)`) *100,2) as `ISU%`,
	   Rank() over(ORDER BY ((sum(f.`quantity_sold(after_promo)`) - sum(f.`quantity_sold(before_promo)`)) /  sum(f.`quantity_sold(before_promo)`) *100) DESC) AS rank_order
       
FROM fact_events f JOIN dim_products p ON f.product_code = p.product_code
WHERE f.campaign_id = 'CAMP_DIW_01'
GROUP BY p.category;


#5. Top 5 products ranked by IR% across all campaigns
SELECT p.product_name, p.category, round((sum(f.revenue_after_promo) - sum(revenue_before_promo)) / sum(revenue_before_promo) * 100, 2) as `IR%`
FROM fact_events f JOIN dim_products p ON f.product_code = p.product_code
GROUP BY p.product_name, p.category
ORDER BY `IR%` DESC
LIMIT 5;

----------------------------------------------------------------------- END ----------------------------------------------------------------------------
