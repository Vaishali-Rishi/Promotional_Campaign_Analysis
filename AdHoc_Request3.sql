#3. Display each campaign along with total revenue generated before and after the campaign
------------------------------------------------------------------------------------------------------------------------------------------------------

  
SELECT c.campaign_name,
       round((sum(f.base_price * f.`quantity_sold(before_promo)`)/1000000),2) AS `revenue_before_campaign (In million)`,
       round((SUM(CASE
                      WHEN promo_type = 'BOGOF' THEN (base_price * 0.5) * (2 * `quantity_sold(after_promo)`)
                      WHEN promo_type = '25% OFF' THEN (base_price * 0.75) * `quantity_sold(after_promo)`
                      WHEN promo_type = '50% OFF' THEN (base_price * 0.50) * `quantity_sold(after_promo)`
                      WHEN promo_type = '33% OFF' THEN (base_price * 0.67) * `quantity_sold(after_promo)`
                      WHEN promo_type = '500 Cashback' THEN (base_price - 500) * `quantity_sold(after_promo)`
                      ELSE base_price * `quantity_sold(after_promo)`
                  END)/1000000),2) AS `revenue_after_campaign (In million)`
FROM fact_events f
JOIN dim_campaigns c ON f.campaign_id = c.campaign_id
GROUP BY c.campaign_name;



# Retrieves revenue data for each campaign from the fact_events table.
# Joins fact_events with dim_campaigns using campaign_id to get campaign names.
# Calculates revenue before campaign by multiplying base_price with quantity_sold(before_promo), then dividing by 1,000,000 to express it in millions.
# Calculates revenue after campaign by applying logic based on the promo_type:
    # -'BOGOF': Half price per item, sold in double quantity.
    # -'25% OFF': 25% discount on base price.
    # -'50% OFF': 50% discount on base price.
    # -'33% OFF': 33% discount on base price.
    # -'500 Cashback': Flat ₹500 discount on base price.
# Rounds both revenue values to 2 decimal places.
# Groups the results by campaign_name to show revenue impact per campaign.
