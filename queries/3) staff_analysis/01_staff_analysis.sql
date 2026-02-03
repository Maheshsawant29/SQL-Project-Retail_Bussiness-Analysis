-- =============== 3) Staff Analysis ====================

-- 3.1) EXtracting the Staff from the staff_tabele - we have a total of 20 Staffs
SELECT * FROM staff;

-- 3.2) Staff who has generated highest Revenue for the bussiness
SELECT s.staff_id, SUM(i.final_bill_amount) AS Revenue_Generated_by_Staff
FROM staff as s
INNER JOIN customers_details as c
ON s.staff_id=c.assigned_staff_id
INNER JOIN invoices as i
ON c.customer_id=i.customer_id
GROUP BY s.staff_id WITH ROLLUP
ORDER BY Revenue_Generated_by_Staff DESC;

-- 3.3) COUNT of All customers handle by each staff
SELECT s.staff_id, COUNT(DISTINCT c.customer_id) AS COUNT_ALL_Customers
FROM staff as s
INNER JOIN customers_details as c
ON s.staff_id=c.assigned_staff_id
GROUP BY s.staff_id WITH ROLLUP
ORDER BY COUNT(c.customer_id) DESC;

-- 3.4) COUNT of Real customers Handled by each staff

SELECT s.staff_id, COUNT(i.customer_id) AS COUNT_Real_Customers
FROM staff as s
INNER JOIN customers_details as c
ON s.staff_id=c.assigned_staff_id
INNER JOIN invoices as i
ON c.customer_id=i.customer_id
GROUP BY s.staff_id WITH ROLLUP
ORDER BY COUNT_Real_Customers DESC;

-- 3.5.1) Conversion Rate of customers by each staff
 SELECT 
      s.staff_id,
      COUNT(DISTINCT c.customer_id) AS Total_Visted_Customers,
      COUNT(DISTINCT i.customer_id) AS Converted_Customers,
      ROUND( COUNT(DISTINCT i.customer_id) * 100 / COUNT(DISTINCT c.customer_id), 2) AS Lead_Conversion_Rate
FROM staff as s
INNER JOIN customers_details as c
ON s.staff_id=c.assigned_staff_id
LEFT JOIN invoices as i
ON c.customer_id=i.customer_id
GROUP BY s.staff_id WITH ROLLUP
ORDER BY Lead_Conversion_Rate DESC;

-- 3.5.2) Overall Lead Conversion Rate of Customers
SELECT 
      COUNT(DISTINCT c.customer_id) AS Total_Visted_Customers,
      COUNT(DISTINCT i.customer_id) AS Converted_Customers,
      ROUND( COUNT(DISTINCT i.customer_id) * 100 / COUNT(DISTINCT c.customer_id), 2) AS Lead_Conversion_Rate
FROM staff as s
INNER JOIN customers_details as c
ON s.staff_id=c.assigned_staff_id
LEFT JOIN invoices as i
ON c.customer_id=i.customer_id;

-- 3.6) Staff with Repeated Customers / Retention Rate

SELECT 
      s.staff_id, 
      COUNT(DISTINCT i.customer_id) AS COUNT_Total_Repeated_Customers, 
      COUNT(DISTINCT rc.customer_id) AS COUNT_Unique_Repeated_Customers,
      ROUND( COUNT(DISTINCT rc.customer_id) * 100 / COUNT(i.customer_id), 2) AS Customer_Retention_Rate
FROM staff as s
INNER JOIN customers_details as c
ON s.staff_id=c.assigned_staff_id
INNER JOIN invoices as i
ON c.customer_id=i.customer_id
LEFT JOIN repeated_customers as rc
ON rc.customer_id=i.customer_id
GROUP BY s.staff_id WITH ROLLUP;

-- 3.7) Count of Unique Customers Handle by each staff with Vision_Type (Using CTE)
WITH unique_customers AS (
     SELECT i.customer_id
     FROM customers_details as c
     INNER JOIN invoices as i
     ON c.customer_id=i.customer_id 
     GROUP BY i.customer_id
)     
SELECT 
      c.assigned_staff_id,
      COUNT(DISTINCT uc.customer_id) AS Total_Unique_Customers,
      SUM(CASE WHEN p.vision_type="Near" THEN 1 ELSE 0 END) AS Near,
      SUM(CASE WHEN p.vision_type="Distance" THEN 1 ELSE 0 END) AS Distance,
      SUM(CASE WHEN p.vision_type="Bifocal" THEN 1 ELSE 0 END) AS Bifocal,
      SUM(CASE WHEN p.vision_type="Progressive" THEN 1 ELSE 0 END) AS Progressive
FROM customers_details as c
INNER JOIN unique_customers as uc
ON uc.customer_id=c.customer_id
INNER JOIN prescriptions as p
ON uc.customer_id=p.customer_id
GROUP BY c.assigned_staff_id WITH ROLLUP;


-- 3.8) Count of Repeated customers handle by each staff with COUNT of vision_type
SELECT 
      s.staff_id,
      COUNT(DISTINCT rc.customer_id) AS Total_Customers,
      SUM(CASE WHEN p.vision_type="Near" THEN 1 ELSE 0 END) AS Near,
      SUM(CASE WHEN p.vision_type="Distance" THEN 1 ELSE 0 END) AS Distance,
      SUM(CASE WHEN p.vision_type="Bifocal" THEN 1 ELSE 0 END) AS Bifocal,
      SUM(CASE WHEN p.vision_type="Progressive" THEN 1 ELSE 0 END) AS Progressive
FROM staff as s
INNER JOIN customers_details as c
ON s.staff_id=c.assigned_staff_id
INNER JOIN repeated_customers as rc
ON rc.customer_id=c.customer_id
INNER JOIN prescriptions as p
ON rc.customer_id=p.customer_id
GROUP BY s.staff_id WITH ROLLUP
ORDER BY s.staff_id;

-- 3.9) Count of Different Age group Visited_Customers Handle by each staff

SELECT 
      s.staff_id,
      COUNT(c.customer_id) AS Total_Customers,
      SUM( CASE WHEN c.age BETWEEN 13 AND 19 THEN 1 ELSE 0 END) AS Teenage,
      SUM( CASE WHEN c.age BETWEEN 20 AND 29 THEN 1 ELSE 0 END) AS 20s_Customer,
      SUM( CASE WHEN c.age BETWEEN 30 AND 39 THEN 1 ELSE 0 END) AS 30s_Customer,
      SUM( CASE WHEN c.age BETWEEN 40 AND 49 THEN 1 ELSE 0 END) AS 40s_Customer,
      SUM( CASE WHEN c.age BETWEEN 50 AND 59 THEN 1 ELSE 0 END) AS 50s_Customer,
      SUM( CASE WHEN c.age BETWEEN 60 AND 69 THEN 1 ELSE 0 END) AS 60s_Customer,
      SUM( CASE WHEN c.age BETWEEN 70 AND 79 THEN 1 ELSE 0 END) AS 70s_Customer,
      SUM( CASE WHEN c.age BETWEEN 80 AND 89 THEN 1 ELSE 0 END) AS 80s_Customer
FROM staff as s
INNER JOIN customers_details as c
ON s.staff_id=c.assigned_staff_id
GROUP BY s.staff_id WITH ROLLUP;

-- 3.10) Count of different Age group Unique Buyers handle by each staff

WITH unique_customers AS (
SELECT 
      i.customer_id
      FROM invoices as i
      GROUP BY i.customer_id
)      
SELECT 
      s.staff_id,
       COUNT(c.customer_id) AS Total_Customers,
      SUM( CASE WHEN c.age BETWEEN 13 AND 19 THEN 1 ELSE 0 END) AS Teenage,
      SUM( CASE WHEN c.age BETWEEN 20 AND 29 THEN 1 ELSE 0 END) AS 20s_Customer,
      SUM( CASE WHEN c.age BETWEEN 30 AND 39 THEN 1 ELSE 0 END) AS 30s_Customer,
      SUM( CASE WHEN c.age BETWEEN 40 AND 49 THEN 1 ELSE 0 END) AS 40s_Customer,
      SUM( CASE WHEN c.age BETWEEN 50 AND 59 THEN 1 ELSE 0 END) AS 50s_Customer,
      SUM( CASE WHEN c.age BETWEEN 60 AND 69 THEN 1 ELSE 0 END) AS 60s_Customer,
      SUM( CASE WHEN c.age BETWEEN 70 AND 79 THEN 1 ELSE 0 END) AS 70s_Customer,
      SUM( CASE WHEN c.age BETWEEN 80 AND 89 THEN 1 ELSE 0 END) AS 80s_Customer
FROM staff as s
INNER JOIN customers_details as c
ON s.staff_id=c.assigned_staff_id
INNER JOIN unique_customers as uc
ON c.customer_id=uc.customer_id
GROUP BY s.staff_id WITH ROLLUP;

-- 3.11) COUNT of different Age_group Repeated_Customers handle by each staff
SELECT 
       s.staff_id,
      COUNT(rc.customer_id) AS Total_Repeated_Customers, 
	  SUM( CASE WHEN c.age BETWEEN 13 AND 19 THEN 1 ELSE 0 END) AS Teenage,
      SUM( CASE WHEN c.age BETWEEN 20 AND 29 THEN 1 ELSE 0 END) AS 20s_Customer,
      SUM( CASE WHEN c.age BETWEEN 30 AND 39 THEN 1 ELSE 0 END) AS 30s_Customer,
      SUM( CASE WHEN c.age BETWEEN 40 AND 49 THEN 1 ELSE 0 END) AS 40s_Customer,
      SUM( CASE WHEN c.age BETWEEN 50 AND 59 THEN 1 ELSE 0 END) AS 50s_Customer,
      SUM( CASE WHEN c.age BETWEEN 60 AND 69 THEN 1 ELSE 0 END) AS 60s_Customer,
      SUM( CASE WHEN c.age BETWEEN 70 AND 79 THEN 1 ELSE 0 END) AS 70s_Customer,
      SUM( CASE WHEN c.age BETWEEN 80 AND 89 THEN 1 ELSE 0 END) AS 80s_Customer
FROM staff as s
INNER JOIN customers_details as c
ON s.staff_id=assigned_staff_id
INNER JOIN repeated_customers as rc
ON rc.customer_id=c.customer_id
GROUP BY s.staff_id WITH ROLLUP;

-- 3.12) Count of Customer_type handle by eahc staff

SELECT s.staff_id,
	  SUM(CASE WHEN customer_type="New" THEN 1 ELSE 0 END) AS New,
	  SUM(CASE WHEN customer_type="Referral" THEN 1 ELSE 0 END) AS Referral
FROM staff as s
INNER JOIN customers_details as c
ON s.staff_id=assigned_staff_id
GROUP BY s.staff_id WITH ROLLUP;

-- 3.13) Products Sales by each Type

SELECT 
      s.staff_id,
      SUM(CASE WHEN pd.product_id=1 THEN 1 ELSE 0 END) AS Frame,
      SUM(CASE WHEN pd.product_id=2 THEN 1 ELSE 0 END) AS Glass,
      SUM(CASE WHEN pd.product_id=3 THEN 1 ELSE 0 END) AS Sunglass,
      SUM(CASE WHEN pd.product_id=4 THEN 1 ELSE 0 END) AS Contact_Lens,
      SUM(CASE WHEN pd.product_id=6 THEN 1 ELSE 0 END) AS Lens_Solution
FROM staff as s
INNER JOIN customers_details as c
ON s.staff_id=assigned_staff_id
INNER JOIN invoices as i
ON c.customer_id=i.customer_id
INNER JOIN invoice_items as ii
ON i.invoice_id=ii.invoice_id
INNER JOIN products as pd
ON ii.product_id=pd.product_id
GROUP BY s.staff_id WITH ROLLUP;

-- verifying the Query
SELECT COUNT(*) FROM invoice_items

