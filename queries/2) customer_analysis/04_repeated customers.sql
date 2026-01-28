-- 2.4) Repeated Customers

-- Extracted the converted Customers 0r the customers who actually bought from us
SELECT c.customer_id, i.customer_id, i.invoice_id 
FROM customers_details as c
LEFT JOIN invoices as i
ON c.customer_id=i.customer_id
WHERE i.customer_id IS NOT NULL;

-- Counting the Converted customers or Customers who actullay bought from us = 5000 (but this is not the count of actual customers, since there are many repeated customers in it) 
SELECT COUNT(i.customer_id) AS Total_Count_of_customers
FROM customers_details as c
LEFT JOIN invoices as i
ON c.customer_id=i.customer_id
WHERE i.customer_id IS NOT NULL;

-- Count the distinct customers in the Actual buyers or converted csutomers=3721  (hence it simply means that there are many repeated customers in it)
SELECT COUNT(DISTINCT i.customer_id) AS COUNT_Actual_Customers
FROM customers_details as c
LEFT JOIN invoices as i
ON c.customer_id=i.customer_id
WHERE i.customer_id IS NOT NULL;

-- 2.4.1)  Identifying the repeated customers ( Logic of repeated customers) and Created a VIEW of Reapeated Customers

CREATE VIEW repeated_customers AS 
SELECT i.customer_id
FROM customers_details as c
LEFT JOIN invoices as i
ON c.customer_id=i.customer_id
WHERE i.customer_id IS NOT NULL
GROUP BY i.customer_id
HAVING COUNT(*) > 1 
ORDER BY COUNT(*) DESC;

-- Checking/ Fetching our Virtual Table
SELECT * FROM repeated_customers;

-- 2.4.2) Count of Repeated Customers
SELECT COUNT(*) AS COUNT_repeated_customers FROM repeated_customers;

-- 2.4.3) Repeated Customers V/S Age_group

SELECT
CASE 
    WHEN c.age < 20 THEN "Teenage_Customer"
    WHEN c.age BETWEEN 20 AND 30 THEN "20's Customer"
    WHEN c.age BETWEEN 31 AND 40 THEN "30's Customer"
    WHEN c.age BETWEEN 41 AND 50 THEN "40's Customer"
    WHEN c.age BETWEEN 51 AND 60 THEN "50's Customer"
    WHEN c.age > 60 THEN "Old_Age Customers"
  END AS Age_group,
COUNT(*) AS Count_Repeated_Customers 
FROM customers_details as c
INNER JOIN repeated_customers as rc
ON c.customer_id=rc.customer_id
GROUP BY Age_group  
ORDER BY Count_Repeated_Customers DESC;

-- 2.4.4) Repeated Customers V/S payment_mode

SELECT i.payment_mode, COUNT(DISTINCT rc.customer_id) AS COUNT_Customers
FROM invoices as i
INNER JOIN repeated_customers as rc
ON i.customer_id=rc.customer_id
GROUP BY i.payment_mode
ORDER BY COUNT(rc.customer_id) DESC;

-- 2.4.5) Repeated Customers V/S final_bill_amount

SELECT SUM(i.final_bill_amount) AS Revenue_Generated_by_Repeated_Customers
FROM invoices as i
INNER JOIN repeated_customers as rc
ON i.customer_id=rc.customer_id;

-- 2.4.6) Repeated Customers V/S Vision_Type

SELECT p.vision_type, COUNT(rc.customer_id) AS COUNT_Repeared_Customers
FROM prescriptions as p
INNER JOIN repeated_customers as rc
ON p.customer_id=rc.customer_id
GROUP BY p.vision_type 
ORDER BY COUNT_Repeared_Customers DESC;  

-- 2.4.7) Repeated Customers 

-- Unique Customers=1051
SELECT COUNT( DISTINCT rc.customer_id) AS Unique_Customers
FROM invoices as i
INNER JOIN repeated_customers as rc
ON i.customer_id=rc.customer_id;

-- Repeated Cutomers
SELECT COUNT(i.customer_id) AS Total_Repeated_Customers
FROM invoices as i
INNER JOIN repeated_customers as rc
ON i.customer_id=rc.customer_id;

-- 2.4.8) Final Summary of Customers
SELECT 
      COUNT( DISTINCT c.customer_id) AS Total_Visited_Customers,
      COUNT( i.customer_id) AS Total_Buyers,
      COUNT( DISTINCT i.customer_id) AS Total_Unique_Buyers,
      ROUND( COUNT(DISTINCT i.customer_id) * 100 /  COUNT(DISTINCT c.customer_id), 2) AS Conversion_Rate,
      COUNT( DISTINCT rc.customer_id) AS Repeated_Customers,
      ROUND( COUNT( DISTINCT rc.customer_id) * 100 / COUNT( DISTINCT i.customer_id), 2) AS Customer_Retention_Rate
FROM customers_details as c
LEFT JOIN invoices as i
ON c.customer_id=i.customer_id
LEFT JOIN repeated_customers as rc
ON c.customer_id=rc.customer_id;