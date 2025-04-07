#2. Number of stores in each city.
---------------------------------------------------------------------------------------------------------------------------------
  
  
SELECT city,
       count(store_id) AS store_count
FROM dim_stores
GROUP BY city
ORDER BY store_count DESC;


# Retrieves the list of cities from the dim_stores table and counts the number of stores in each city using COUNT().
# Groups the results by city to get a count per city.
# Sorts the final result in descending order of store_count to show cities with the most stores at the top.
