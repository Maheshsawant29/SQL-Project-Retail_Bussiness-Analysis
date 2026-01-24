-- 2.3) Real Customers or Converted Customers (Who visited and actually bought the products)

-- 2.3.1) Extracted the Real Customers from the database using the below query

SELECT DISTINCT c.customer_id, i.customer_id, i.invoice_id
FROM customers_details as c
LEFT JOIN invoices as i
ON c.customer_id=i.customer_id
WHERE i.customer_id IS NOT NULL;

-- COUNT of Real Customers

SELECT 
      COUNT(DISTINCT c.customer_id) AS COUNT_Real_Customers
FROM customers_details as c
LEFT JOIN invoices as i
ON c.customer_id=i.customer_id
WHERE i.customer_id IS NOT NULL;

-- Conversion Rate of Real Customers = 46.51 (very poor)

SELECT 
      COUNT(DISTINCT c.customer_id) AS Total_Customers_visited,
      COUNT(DISTINCT i.customer_id) AS Customers_Bought,
      ROUND( COUNT(DISTINCT i.customer_id) * 100 / COUNT(DISTINCT c.customer_id), 2) AS Conversion_Rate
FROM customers_details as c
LEFT JOIN invoices as i
ON c.customer_id=i.customer_id;

-- 2.3.2) Real Customers V/S Age_group 

SELECT
CASE 
    WHEN c.age < 20 THEN "Teenage_Customer"
    WHEN c.age BETWEEN 20 AND 30 THEN "20's Customer"
    WHEN c.age BETWEEN 31 AND 40 THEN "30's Customer"
    WHEN c.age BETWEEN 41 AND 50 THEN "40's Customer"
    WHEN c.age BETWEEN 51 AND 60 THEN "50's Customer"
    WHEN c.age > 60 THEN "Old_Age Customers"
  END AS Age_group,
COUNT(DISTINCT i.customer_id) AS COUNT_Repeated_Customers
FROM customers_details as c
LEFT JOIN invoices as i
ON c.customer_id=i.customer_id
WHERE i.customer_id IS NOT NULL
GROUP BY Age_group
ORDER BY COUNT_repeated_customers DESC; 

-- 2.3.3) Real Customers V/S Customer_Type

SELECT c.customer_type, COUNT(DISTINCT i.customer_id)
FROM customers_details as c
LEFT JOIN invoices as i
ON c.customer_id=i.customer_id
WHERE i.customer_id IS NOT NULL
GROUP BY c.customer_type;

-- 2.3.4) Real Customers V/S payment_mode  (No use of Distinct, since we have calaculate the count of transaction mode)

SELECT i.payment_mode, COUNT(*)
FROM customers_details as c
LEFT JOIN invoices as i
ON c.customer_id=i.customer_id
WHERE i.customer_id IS NOT NULL
GROUP BY i.payment_mode
ORDER BY COUNT(*) DESC;

-- 2.3.5) Real Customers V/S final_bill_amount  (NO use of distinct since we are calculating the revenue)

SELECT SUM(i.final_bill_amount) AS Total_Revenue
FROM customers_details as c
LEFT JOIN invoices as i
ON c.customer_id=i.customer_id
WHERE i.customer_id IS NOT NULL;

-- 2.3.6) Vision_Type ( No use of DISTINCT since we are calculating the type of vision )

SELECT p.vision_type, COUNT(i.customer_id)
FROM customers_details as c
LEFT JOIN invoices as i
ON c.customer_id=i.customer_id
LEFT JOIN prescriptions as p
ON c.customer_id=p.customer_id
WHERE i.customer_id IS NOT NULL
GROUP BY p.vision_type
ORDER BY COUNT(i.customer_id) DESC;

-- 2.3.7) Real Customers V/S products

SELECT p.product_id, p.product_name, COUNT(i.customer_id) AS COUNT_product_bought_by_real_customers  -- (No use of DISTINCT to check the buys of products)
FROM customers_details as c
LEFT JOIN invoices as i
ON c.customer_id=i.customer_id
LEFT JOIN invoice_items as ii
ON i.invoice_id=ii.invoice_id
LEFT JOIN products as p
ON ii.product_id=p.product_id
WHERE i.customer_id IS NOT NULL
GROUP BY p.product_id, p.product_name
ORDER BY COUNT_product_bought_by_real_customers DESC;

-- 2.3.8) Real Customer V/S time_spend by real customers in shop 

SELECT AVG(ad.time_spend_by_customer_in_shop)
FROM customers_details as c
LEFT JOIN invoices as i
ON c.customer_id=i.customer_id
INNER JOIN additional_customer_details as ad
ON c.customer_id=ad.customer_id;

-- 2.3.9.1) COUNT Real customers V/S Month and Year  ( NO use of DISTINCT )

SELECT YEAR(invoice_date), COUNT(i.customer_id) AS COUNT_customer
FROM customers_details as c
LEFT JOIN invoices as i
ON c.customer_id=i.customer_id
WHERE i.customer_id IS NOT NULL
GROUP BY YEAR(invoice_date)
ORDER BY COUNT(i.customer_id)  DESC;

-- 2.3.9.2) COUNT Real Customers V/S Year (No use of DISTINCT )

SELECT YEAR(invoice_date), COUNT(i.customer_id) AS COUNT_customer
FROM customers_details as c
LEFT JOIN invoices as i
ON c.customer_id=i.customer_id
WHERE i.customer_id IS NOT NULL
GROUP BY YEAR(invoice_date)
ORDER BY COUNT(i.customer_id)  DESC;

-- 2.3.9.3) COUNT of Real Customers by Month   ( NO use of DISTINCT )

SELECT MONTH(invoice_date), COUNT(i.customer_id)
FROM customers_details as c
LEFT JOIN invoices as i
ON c.customer_id=i.customer_id
WHERE i.customer_id IS NOT NULL 
GROUP BY MONTH(invoice_date) 
ORDER BY COUNT(i.customer_id) DESC;
