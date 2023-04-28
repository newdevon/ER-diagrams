---------------------------------------------------------------------------------------
/* Hello! We're going to practice some SQL with a database
   from Oracle. This database covers:
   - PC component products
   - categories, orders and order items for said products
   - customers and employees
   - warehouses and their inventories
   - locations, countries, regions
   Hoowhee! That's a lot of tables. But when it comes to
   data, the more the merrier :) */
use ot;
---------------------------------------------------------------------------------------


---------------------------------------------------------------------------------------
/*  	*
	1a.) Select the region_id and count of all rows from the countries table. Group 
	by the region_id and order by count descending. Limit to 1 to find the region 
	with the most countries that have company locations. */
---------------------------------------------------------------------------------------
CREATE VIEW 
	countries_in_region as
SELECT
	region_id,
    COUNT(*) as `Total Countries in Region`
FROM
	countries
GROUP BY
	region_id
ORDER BY
	`Total Countries in Region` DESC;
    
---------------------------------------------------------------------------------------
/* 	*
	1b.) Looks like we found the region with the most countries, but we don't know 
	the name of the region. Fortunately, that can be found in the regions table. 
	Using the results of the previous problem, find the name of the region with the
	most countries. We want to use an alias of 'region with most locations' for the 
        column label, as well. */
---------------------------------------------------------------------------------------
ALTER VIEW
	countries_in_region as
SELECT
	C.region_id,
    COUNT(*) as `region with most locations`,
	R.region_name
FROM
	countries as C
LEFT JOIN regions as R
	ON C.region_id = R.region_id
GROUP BY
	C.region_id
ORDER BY
	`region with most locations` DESC;

-- Top region with most locations
SELECT * FROM countries_in_region LIMIT 1;
-- OR
SELECT MAX(`region with most locations`) FROM countries_in_region;

---------------------------------------------------------------------------------------
/* 	**
	 1c.) Nice job! Now, here's a more difficult one. Using the locations table, 
	 select the state, city, and postal_code from locations where the country is 
	 NOT the United States (country_id != "US") and the name of the city starts
	 with "S". 
         Hint: Use LIKE and a wildcard. */
---------------------------------------------------------------------------------------
SELECT
	state,
    city,
    postal_code,
    country_id
FROM
	locations
WHERE
	country_id != "US"
    AND
    city LIKE 's%';
    
---------------------------------------------------------------------------------------
/*  	*
	1d.) As you may have seen in the problem above, there's a "state" column in the 
        locations table, but not all locations are in a state. Select all entries for 
        the locations that are NOT in a state. */
---------------------------------------------------------------------------------------
SELECT
	state,
    city,
    postal_code,
    country_id
FROM
	locations
WHERE
	state IS NULL;
    
---------------------------------------------------------------------------------------
/* 	**
	1e.) Your employer wants an update on the number of countries that have locations. 
	They note that they want unique countries but they're not sure how to do that 
	and they're asking you for help. Write a query for them. */
---------------------------------------------------------------------------------------
SELECT DISTINCT
	country_id,
	COUNT(*)
FROM
	locations
GROUP BY
	country_id;

---------------------------------------------------------------------------------------
/* 	**
	2a.) Why don't we switch gears? Let's take a look at the products in this
	database. Find the product names and prices of all products that have a 
	list_price between 100 and 500. You'll have to find the right table yourself on 
	this one. */
---------------------------------------------------------------------------------------
SELECT
	product_name,
    list_price
FROM
	products
WHERE
	list_price
    BETWEEN 100 AND 500;

---------------------------------------------------------------------------------------
/* 	**
	2b.) What do those product names even MEAN? If you don't know much about PC 
       components, it can be difficult to distinguish between different kinds of 
       products. Good thing we have a table for product categories! 
       
       Select the product_name, list_price, and category_name (from product category) 
       rows from the products table joined to the product_categories table on 
       category_id (using an inner join). */
---------------------------------------------------------------------------------------
SELECT
	P.product_name,
    P.list_price,
    PC.category_name
FROM
	products as P
JOIN product_categories as PC
	ON P.category_id = PC.category_id;

---------------------------------------------------------------------------------------
/* 	****
	2c.) Let's try joining more than two tables. You're looking for a popular CPU 
	that has more than 100 units in stock at your local warehouse in Toronto. You 
	only need to find the names of the products, but you'll need to join these 
	tables:
        - warehouses
        - inventories
        - products
        - product_categories
        The only info you need is the product_name and the list_price. */
---------------------------------------------------------------------------------------
SELECT
	P.product_name,
    P.list_price
--     PC.category_name,
--     I.quantity,
--     W.warehouse_name
FROM
	products as P
JOIN product_categories as PC
	ON P.category_id = PC.category_id
JOIN inventories as I
	ON P.product_id = I.product_id
JOIN warehouses as W
	ON I.warehouse_id = W.warehouse_id
WHERE
	warehouse_name = "Toronto"
	AND
    category_name = "CPU"
    AND
    quantity > 100;
    
---------------------------------------------------------------------------------------
/* 	**
	3a.) Now that we have a bit more of an idea of what kinds of products we have, 
	let's investigate prices. Select the avg list_price of all products. */
---------------------------------------------------------------------------------------
SELECT
	AVG(list_price)
FROM
	products;
---------------------------------------------------------------------------------------
/* 	***
	3b.) Let's take a closer look at the average prices of each category. Select the 
        category_name and average list_price of each product category, rounded to 2 
        decimals. */
---------------------------------------------------------------------------------------
SELECT
	PC.category_name,
	AVG(list_price)
FROM
	products as P
JOIN product_categories as PC
	ON P.category_id = PC.category_id
GROUP BY
	P.category_id;

---------------------------------------------------------------------------------------
/* 	**
	4a.) We have the mean, now, but the outliers in the data will skew the mean.
	There are other statistics that we can look at as well, like mode!
       
       Let's start by 
	-- selecting list_price and the count of list_prices 
	-- grouped by list_price
        -- ordered with the highest value first 
        -- limited to 2.
        Note: We limit to 2 to see if there are multiple modes. If the top two results 
        of this query have the same count, rerun the query with limit + 1, and repeat
        (do this manually). If there's more than one mode, this is how you find them 
        all without incorporating more advanced functions. */
---------------------------------------------------------------------------------------
SELECT
	list_price,
    COUNT(list_price) as Count
FROM
	products
GROUP BY
	list_price
ORDER BY
	Count DESC
LIMIT 2;

---------------------------------------------------------------------------------------
/* 	****
	4b.) What if we want to find the modes for list_price for each product category?
	With what we've learned so far, we can find them with a single query.
        
        Use a joined table to select category_name, list_price, and count of the
        correct groups*. Sort the results in a way that will allow you to easily see 
        the highest count in each category**. 
        
        * Tip: Remember we can use multiple groups. For example, we can group first by 
        category name, then we can group by list price for each category_name (there 
        are 4).
        
        ** Additional Tip: There isn't a very easy way to limit your query to the
        highest count of each category, but what you can do is filter out all the 
        entries that only have a count of 1, as they are certainly not the mode. */
---------------------------------------------------------------------------------------
SELECT
	PC.category_name,
	P.list_price,
    COUNT(list_price) as Count
FROM
	products as P
JOIN product_categories as PC
	ON P.category_id = PC.category_id
GROUP BY
    P.category_id
ORDER BY
	Count DESC;
