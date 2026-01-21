-- 2.2) Customer_Behaviour Analysis

-- Here we have two types of customers 
-- 1) Actual customers who buyed 
-- 2) Window Shoppers

-- 2.2.1) Window Shoppers

-- 2.2.1) Window shoppers

SELECT c.customer_id, i.customer_id, i.invoice_id 
FROM customers_details as c
LEFT JOIN invoices as i
ON c.customer_id=i.customer_id;

-- View of Window Shoppers 
SELECT c.customer_id, i.customer_id, i.invoice_id 
FROM customers_details as c
LEFT JOIN invoices as i
ON c.customer_id=i.customer_id
WHERE i.customer_id IS NULL;

-- 2.2.2) Count of Window Shoppers & Rate of Window Shoppers

SELECT 
COUNT(c.customer_id) AS COUNT_Window_shoppers,
ROUND( (COUNT(c.customer_id) * 100/ (SELECT COUNT(*) FROM customers_details)) , 2) AS Rate_Window_shoppers
FROM customers_details as c
LEFT JOIN invoices as i
ON c.customer_id=i.customer_id
WHERE i.customer_id IS NULL; 

-- 2.2.3) Age_group V/S Window Shoppers

SELECT
CASE 
    WHEN c.age < 20 THEN "Teenage_Customer"
    WHEN c.age BETWEEN 20 AND 30 THEN "20's Customer"
    WHEN c.age BETWEEN 31 AND 40 THEN "30's Customer"
    WHEN c.age BETWEEN 41 AND 50 THEN "40's Customer"
    WHEN c.age BETWEEN 51 AND 60 THEN "50's Customer"
    WHEN c.age > 60 THEN "Old_Age Customers"
  END AS Age_group,
COUNT(c.customer_id) AS COUNT_Window_Shoppers
FROM customers_details as c
LEFT JOIN invoices as i
ON c.customer_id=i.customer_id
WHERE i.customer_id IS NULL
GROUP BY Age_group
ORDER BY COUNT_Window_Shoppers DESC;

-- 2.2.4) Window_ Shopers V/S customer_type 

SELECT c.customer_type, COUNT(c.customer_id) AS COUNT_Window_Shoppers 
FROM customers_details as c
LEFT JOIN invoices as i
ON c.customer_id=i.customer_id
WHERE i.customer_id IS NULL
GROUP BY c.customer_type
ORDER BY COUNT_Window_Shoppers DESC;

-- 2.2.5) Window_Shoppers V/S vison_type

SELECT vision_type, COUNT(c.customer_id) AS COUNT_Window_Shoppers
FROM customers_details as c
LEFT JOIN prescriptions as p
ON c.customer_id=p.customer_id
LEFT JOIN invoices as i
ON c.customer_id=i.customer_id
WHERE i.customer_id IS NUll
GROUP BY vision_type 
ORDER BY COUNT_Window_Shoppers DESC;

-- 2.2.6) Window Shoppers V/S Staff

-- 2.2.(6.1) COUNT(Window Shoppers) V/S Staff

SELECT s.staff_id, s.staff_full_name, COUNT(c.customer_id) AS COUNT_Window_Shoppers
FROM customers_details as c
LEFT JOIN staff as s
ON c.assigned_staff_id=s.staff_id
LEFT JOIN invoices as i
ON c.customer_id=i.customer_id
WHERE i.customer_id IS NULL
GROUP BY s.staff_id, s.staff_full_name 
ORDER BY COUNT_Window_Shoppers DESC;

-- 2.2.(6.2) Staff with 0 window Shoppers

SELECT s.staff_id, s.staff_full_name,
SUM( CASE WHEN i.customer_id IS NULL THEN 1 ELSE 0 END) AS COUNT_Window_Shoppers
FROM customers_details as c
LEFT JOIN staff as s
ON c.assigned_staff_id=s.staff_id
LEFT JOIN invoices as i
ON c.customer_id=i.customer_id
GROUP BY s.staff_id, s.staff_full_name
HAVING COUNT_Window_Shoppers=0;

-- 2.2.(7.1)) Window Shoppers V/S additional customers_details month, year

SELECT YEAR(p.visit_date) AS Visit_Year, MONTH(p.visit_date)_Visit_Month , COUNT(c.customer_id) AS Window_Shoppers
FROM customers_details as c
LEFT JOIN prescriptions as p
ON c.customer_id=p.customer_id
LEFT JOIN invoices as i
ON c.customer_id=i.customer_id
WHERE i.customer_id IS NULL
GROUP BY YEAR(p.visit_date), MONTH(p.visit_date) 
ORDER BY Window_Shoppers DESC;