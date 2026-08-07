-- =====================================================
-- =========2.2) Customer_Behaviour Analysis======
-- =====================================================

-- Here we have two types of customers 1) Actual customers who buyed 2) Window Shoppers

-- 2.2.1) Window Shoppers

-- 2.2.1) Window shoppers

SELECT c.customer_id, i.customer_id, i.invoice_id 
FROM customers_details as c
LEFT JOIN invoices as i
ON c.customer_id=i.customer_id;

-- Extracted Window Shoppers 
SELECT c.customer_id, i.customer_id, i.invoice_id 
FROM customers_details as c
LEFT JOIN invoices as i
ON c.customer_id=i.customer_id
WHERE i.customer_id IS NULL;

-- 2.2.2) Count of Window Shoppers and get the percentage of Window Shoppers

SELECT 
COUNT(c.customer_id) AS COUNT_Window_shoppers,
ROUND( (COUNT(DISTINCT c.customer_id) * 100/ (SELECT COUNT(*) FROM customers_details)) , 2) AS Rate_Window_shoppers
FROM customers_details as c
LEFT JOIN invoices as i
ON c.customer_id=i.customer_id
WHERE i.customer_id IS NULL; 

-- testing query
SELECT 
      COUNT(DISTINCT c.customer_id) AS Total_Visited_Customers,
      COUNT(DISTINCT CASE WHEN i.customer_id IS NULL THEN c.customer_id END) AS Window_Shoppers,
      COUNT( DISTINCT CASE WHEN i.customer_id IS NOT NULL THEN c.customer_id END) AS Buyers,
      ROUND( COUNT(DISTINCT CASE WHEN i.customer_id IS NULL THEN c.customer_id END) * 100 / 
      COUNT(DISTINCT c.customer_id), 2) AS Percentage_of_Window_Shoppers,
      ROUND( COUNT( DISTINCT CASE WHEN i.customer_id IS NOT NULL THEN c.customer_id END) * 100 /
      COUNT(DISTINCT c.customer_id), 2) AS Percentage_Buyers
FROM customers_details as c
LEFT JOIN invoices as i
ON c.customer_id=i.customer_id;

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
COUNT(DISTINCT c.customer_id) 
AS Total_Visited_Customers, 
COUNT(DISTINCT CASE WHEN i.customer_id IS NULL THEN c.customer_id END) 
AS COUNT_Window_Shoppers,
ROUND(COUNT(DISTINCT CASE WHEN i.customer_id IS NULL THEN c.customer_id END)*100/
COUNT(DISTINCT c.customer_id), 2) AS Percentage_of_Window_Shoppers
FROM customers_details as c
LEFT JOIN invoices as i
ON c.customer_id=i.customer_id
GROUP BY Age_group WITH ROLLUP
ORDER BY COUNT_Window_Shoppers DESC;

-- 2.2.4) Window_ Shopers V/S customer_type 

SELECT c.customer_type, COUNT(c.customer_id) 
AS COUNT_Window_Shoppers 
FROM customers_details as c
LEFT JOIN invoices as i
ON c.customer_id=i.customer_id
WHERE i.customer_id IS NULL
GROUP BY c.customer_type
ORDER BY COUNT_Window_Shoppers DESC;

-- 
SELECT c.customer_type, 
       COUNT(DISTINCT c.customer_id ) 
       AS Total_Visited_Customers,
       COUNT(DISTINCT i.customer_id) 
       AS Buyers,
       COUNT(DISTINCT CASE WHEN i.customer_id IS NULL THEN c.customer_id END) 
       AS Window_Shoppers,
       ROUND(COUNT(DISTINCT CASE WHEN i.customer_id IS NULL THEN c.customer_id END)*100/
       COUNT(DISTINCT c.customer_id ), 2) 
       AS Percentage_of_Window_Shoppers
FROM customers_details as c
LEFT JOIN invoices as i
ON c.customer_id=i.customer_id
GROUP BY c.customer_type;

-- 2.2.5) Window_Shoppers V/S vison_type

SELECT vision_type, COUNT(c.customer_id) 
AS COUNT_Window_Shoppers
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

SELECT s.staff_id, 
       s.staff_full_name, 
	   COUNT(c.customer_id) 
       AS COUNT_Window_Shoppers
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

-- ================== END OF Window Shoppers ====================== --


-- ====================================================
-- 2.3) Real Customers or Converted Customers or Buyers
-- (Who visited and actually bought the products)
-- =====================================================

-- 2.3.1) Extracted the Real Customers from the database using the below query

SELECT DISTINCT c.customer_id, i.customer_id, i.invoice_id
FROM customers_details as c
LEFT JOIN invoices as i
ON c.customer_id=i.customer_id
WHERE i.customer_id IS NOT NULL;
-- OR
SELECT c.customer_id, i.customer_id, i.invoice_id
FROM customers_details as c
INNER JOIN invoices as i
ON c.customer_id=i.customer_id;

-- Total Real Customers NON-Unique Who buyed from us
SELECT 
      COUNT(c.customer_id) AS COUNT_Real_Customers
FROM customers_details as c
LEFT JOIN invoices as i
ON c.customer_id=i.customer_id
WHERE i.customer_id IS NOT NULL;

-- COUNT of Unique Real Customers

SELECT 
	COUNT(DISTINCT c.customer_id) AS Total_Visited_Customers,
	COUNT(DISTINCT CASE WHEN i.customer_id IS NOT NULL THEN i.customer_id END) 
	AS COUNT_Unique_Real_Customers,
	ROUND( COUNT(DISTINCT CASE WHEN i.customer_id IS NOT NULL THEN i.customer_id END) * 100 / 
	COUNT(DISTINCT c.customer_id), 2) AS Conversion_Rate
FROM customers_details as c
LEFT JOIN invoices as i
ON c.customer_id=i.customer_id;


-- Conversion Rate of Uniqiue Real Customers = 46.51 (very poor)

-- This query answers: "Out of 100 people who walked into my shop, how many unique individuals actually opened their wallets?"

-- Logic: COUNT(DISTINCT i.customer_id) / COUNT(DISTINCT c.customer_id)

-- Why it's the standard: Conversion is about the transition from "Lead" to "Customer." 
-- Once a person has bought something, they are "converted." 
-- If they come back and buy again, they aren't "converting" again; they are "re-purchasing."
-- Best for: Measuring marketing effectiveness and the sales team's ability to close a deal with a new person.

SELECT 
      COUNT(DISTINCT c.customer_id) AS Total_Customers_visited,
      COUNT(DISTINCT i.customer_id) AS Unique_Customers_Bought,
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

SELECT 
	  c.customer_type, 
      COUNT(DISTINCT i.customer_id) 
      AS Count_Customers
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

SELECT 
	p.product_id, 
    p.product_name, 
    SUM(ii.quantity) AS Count_Products
FROM customers_details as c
LEFT JOIN invoices as i
ON c.customer_id=i.customer_id
LEFT JOIN invoice_items as ii
ON i.invoice_id=ii.invoice_id
LEFT JOIN products as p
ON ii.product_id=p.product_id
WHERE i.customer_id IS NOT NULL
GROUP BY p.product_id, p.product_name 
ORDER BY Count_Products DESC;

-- 2.3.7.2) Real Customers V/S Product / Product Brand / Product_Type

-- CREATED A VIEW FROM easy extraction of data related to customer Product, brand, Product_Type
CREATE VIEW customers_product_brand_type_qty_reveneu AS 
WITH customers AS (
SELECT DISTINCT c.customer_id
FROM customers_details as c
),
customers_invoices AS (
SELECT cc.customer_id, i.invoice_id 
FROM customers as cc
INNER JOIN invoices as i
ON cc.customer_id=i.customer_id
),
customers_invoices_items AS (
SELECT 
     ci.customer_id, ci.invoice_id, 
	 ii.item_id, ii.product_id, 
     ii.brand_id, ii.product_type_id, 
     ii.quantity, ii.final_product_price
FROM customers_invoices as ci
INNER JOIN invoice_items as ii
ON ci.invoice_id=ii.invoice_id
)
SELECT 
	cii.customer_id, cii.invoice_id, 
	cii.item_id, cii.product_id, 
    cii.brand_id, cii.product_type_id, 
    cii.quantity, cii.final_product_price
FROM customers_invoices_items as cii;

-- Product Brand
WITH customers AS (
SELECT DISTINCT c.customer_id
FROM customers_details as c
),
customers_invoices AS (
SELECT cc.customer_id, i.invoice_id 
FROM customers as cc
INNER JOIN invoices as i
ON cc.customer_id=i.customer_id
),
customers_invoices_items AS (
SELECT 
     ci.customer_id, ci.invoice_id, 
	 ii.item_id, ii.product_id, 
     ii.brand_id, ii.product_type_id, 
     ii.quantity, ii.final_product_price
FROM customers_invoices as ci
INNER JOIN invoice_items as ii
ON ci.invoice_id=ii.invoice_id
),
customers_invoices_products_name AS (
SELECT 
    cii.customer_id, cii.invoice_id, 
    cii.item_id, cii.product_id, 
    cii.brand_id, cii.product_type_id, 
    cii.quantity, cii.final_product_price,
    pd.product_name
FROM customers_invoices_items as cii
INNER JOIN products as pd
ON cii.product_id=pd.product_id
),
customers_invoices_products_name_brand_name AS (
SELECT 
    cipn.customer_id, cipn.invoice_id, 
	cipn.item_id, cipn.product_id, 
    cipn.brand_id, cipn.product_type_id, 
    cipn.quantity, cipn.product_name, 
    cipn.final_product_price,
    pb.brand_name
FROM customers_invoices_products_name as cipn
INNER JOIN product_brand as pb
ON cipn.brand_id=pb.brand_id
)
SELECT 
    cipnbn.brand_name, 
    SUM(cipnbn.quantity) AS QTY_SOLD
FROM customers_invoices_products_name_brand_name 
as cipnbn
GROUP BY cipnbn.brand_name 
ORDER BY QTY_SOLD DESC;

-- Product_Type Sold
SELECT 
    pd.product_name, cpbtqr.product_type_id, 
	product_type_name, SUM(cpbtqr.quantity) 
    AS QTY_SOLD 
FROM customers_product_brand_type_qty_reveneu 
as cpbtqr
INNER JOIN product_type AS pt
ON cpbtqr.product_type_id=pt.product_type_id
INNER JOIN products as pd
ON pd.product_id=cpbtqr.product_id
GROUP BY pd.product_name, 
         cpbtqr.product_type_id, 
         product_type_name 
ORDER BY QTY_SOLD DESC;


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

-- ================== END OF Actual Buyers Customers ===================== --

-- ============================================ --
-- ========== 2.4) Repeated Customers =========== --
-- ============================================ -- 

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
WITH repeated_customers AS (
SELECT i.customer_id
FROM customers_details as c
LEFT JOIN invoices as i
ON c.customer_id=i.customer_id
WHERE i.customer_id IS NOT NULL
GROUP BY i.customer_id
HAVING COUNT(*) > 1 
ORDER BY COUNT(*) DESC
),
repeated_customers_details AS (
SELECT 
      r.customer_id, c.customer_full_name, 
      c.age, c.mobile, c.assigned_staff_id,
      c.referred_by_id, c.created_at
FROM repeated_customers as r
INNER JOIN customers_details as c
ON r.customer_id=c.customer_id
)
SELECT rc.customer_id, rc.customer_full_name, 
      rc.age, rc.mobile, rc.assigned_staff_id,
      rc.referred_by_id, rc.created_at
FROM repeated_customers_details as rc;


-- Checking/ Fetching our Virtual Table
SELECT * FROM repeated_customers;

-- 2.4.2) Count of Repeated Customers
SELECT 
      COUNT(DISTINCT i.customer_id) AS Total_Buyers,
      COUNT(DISTINCT rc.customer_id) AS Repeated_Customers,
      ROUND( COUNT(DISTINCT rc.customer_id) * 100 / 
      COUNT(DISTINCT i.customer_id), 2) 
      AS Retention_Rate
FROM invoices as i      
LEFT JOIN repeated_customers as rc
ON rc.customer_id=i.customer_id;


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

SELECT 
	SUM(i.final_bill_amount) AS Total_Revenue_Collected,
    SUM(CASE WHEN rc.customer_id IS NOT NULL THEN i.final_bill_amount END) 
    AS Revenue_from_Repeated_Customers,
    ROUND( SUM(CASE WHEN rc.customer_id IS NOT NULL THEN i.final_bill_amount END) * 100 /
    SUM(i.final_bill_amount), 2)
     AS Contribution_in_Revenue_by_Repeated_Customers
FROM invoices as i
LEFT JOIN repeated_customers as rc
ON i.customer_id=rc.customer_id;

-- query verification
SELECT SUM(i.final_bill_amount) 
FROM invoices as i
INNER JOIN repeated_customers as rc
ON i.customer_id=rc.customer_id;


-- 2.4.6) Repeated Customers V/S Vision_Type

SELECT 
    p.vision_type, COUNT(rc.customer_id) 
    AS COUNT_Repeared_Customers
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
      
      ROUND( COUNT(DISTINCT i.customer_id) * 100 /  
      COUNT(DISTINCT c.customer_id), 2) AS Conversion_Rate,
      
      COUNT( DISTINCT rc.customer_id) AS Unique_Repeated_Customers,
      
      ROUND( COUNT( DISTINCT rc.customer_id) * 100 / 
      COUNT( DISTINCT i.customer_id), 2) AS Customer_Retention_Rate
FROM customers_details as c
LEFT JOIN invoices as i
ON c.customer_id=i.customer_id
LEFT JOIN repeated_customers as rc
ON c.customer_id=rc.customer_id;

-- 2.4.9) Number of days gap between the last visit and current date of repeated_customers
-- basically repeated_customers who are about to churn\

WITH churning_customers AS (
SELECT 
      rc.customer_id,
      MAX(i.invoice_date) AS Last_Visit_Date,
      DATEDIFF(CURDATE(), MAX(i.invoice_date)) 
      AS Days_from_last_visit
FROM repeated_customers as rc
INNER JOIN invoices as i
ON rc.customer_id=i.customer_id
GROUP BY rc.customer_id
HAVING Days_from_last_visit > 180
ORDER BY Days_from_last_visit DESC
),
churning_customers_details AS (
SELECT 
       cc.customer_id, c.customer_full_name, 
       c.mobile, c.age, cc.Last_Visit_Date, 
       cc.Days_from_last_visit
FROM churning_customers as cc
INNER JOIN customers_details as c
ON cc.customer_id=c.customer_id
)
SELECT 
       ccd.customer_id, ccd.customer_full_name, 
       ccd.mobile, ccd.age, ccd.Last_Visit_Date, 
       ccd.Days_from_last_visit
FROM churning_customers_details as ccd;


-- 2.4.10) How long have repeat customers remained active with the business, 
-- measured by the number of days between their first and most recent purchase?

WITH loyal_Customers AS (
SELECT 
      rc.customer_id,
      DATE(MIN(i.invoice_date)) AS First_Purchase_Date,
      DATE(MAX(i.invoice_date)) AS Last_Purchase_Date,
      DATEDIFF(MAX(i.invoice_date), MIN(i.invoice_date)) 
      AS Days_Between_First_and_Last_Purchase
FROM repeated_customers AS rc
INNER JOIN invoices AS i
ON rc.customer_id = i.customer_id
GROUP BY rc.customer_id
ORDER BY Days_Between_First_and_Last_Purchase DESC
),
loyal_customers_details AS (
SELECT        
       lc.customer_id,
       c.customer_full_name, 
       c.age,
       c.mobile,
       lc.First_Purchase_Date,
       lc.Last_Purchase_Date,
       lc.Days_Between_First_and_Last_Purchase
FROM loyal_customers AS lc
INNER JOIN customers_details as c
ON lc.customer_id=c.customer_id
)
SELECT lcd.customer_id,
       lcd.customer_full_name, 
       lcd.age,
       lcd.mobile,
       lcd.First_Purchase_Date,
       lcd.Last_Purchase_Date,
       lcd.Days_Between_First_and_Last_Purchase
FROM loyal_customers_details as lcd;


-- 2.4.10) Staff with the Highest Number of Repeated_Customers
WITH repeated_customers_staff_id AS (
SELECT rc.customer_id, c.assigned_staff_id
FROM repeated_customers as rc
INNER JOIN customers_details as c
ON rc.customer_id=c.customer_id
),
repeated_customers_staff_name AS (
SELECT 
       rcsi.customer_id, rcsi.assigned_staff_id, 
       s.staff_full_name
       FROM repeated_customers_staff_id as rcsi
       INNER JOIN staff as s
       ON s.staff_id=rcsi.assigned_staff_id
),
repeated_customers_staff_invoices as (
SELECT 
      rcsn.staff_full_name, 
      rcsn.assigned_staff_id, 
      rcsn.customer_id, i.invoice_id
      FROM repeated_customers_staff_name as rcsn
      INNER JOIN invoices as i
      ON rcsn.customer_id=i.customer_id
)
SELECT 
      rcsni.staff_full_name, 
      COUNT(rcsni.customer_id) AS Repeated_Customers
      FROM repeated_customers_staff_invoices as rcsni
      GROUP BY rcsni.staff_full_name WITH ROLLUP
	  ORDER BY COUNT(rcsni.customer_id) DESC;
 

-- ================= END OF Repeated Customers ====================== --
 


-- Summary Queries 
-- Creating a SQL pipeline for full customer jounrney summary analysis 

-- Query 1) 
-- Age group summary of Customers
WITH customers AS (
SELECT DISTINCT customer_id as all_customers_id
FROM customers_details as c
),
cd_details AS (
SELECT 
      c.all_customers_id, cc.age, 
      cc.customer_type, 
      cc.referred_by_id
FROM customers as c
INNER JOIN customers_details as cc
ON c.all_customers_id=cc.customer_id
),
cd_prescriptions AS (
SELECT 
	  cd.all_customers_id, cd.age, 
      cd.customer_type, cd.referred_by_id,  
	  p.vision_type
FROM cd_details as cd
INNER JOIN prescriptions as p
ON cd.all_customers_id=p.customer_id
),
cdp_buyers AS (
SELECT 
	  cdp.all_customers_id, cdp.age, 
      cdp.customer_type, cdp.vision_type,
      cdp.referred_by_id, 
      i.customer_id as buyer_customers_id, 
      i.final_bill_amount
FROM cd_prescriptions as cdp
LEFT JOIN invoices as i
ON cdp.all_customers_id=i.customer_id
),
cdpb_repeated AS (
SELECT 
	  cdpb.all_customers_id, cdpb.age, 
      cdpb.customer_type, cdpb.vision_type,
      cdpb.referred_by_id, 
      cdpb.buyer_customers_id as buyer_customers_id, 
      cdpb.final_bill_amount,
      rc.customer_id as repeated_customers_id
FROM cdp_buyers as cdpb
LEFT JOIN repeated_customers as rc
ON cdpb.all_customers_id=rc.customer_id
),
cdpbr_churn AS (
SELECT 
	  cdpbr.all_customers_id, cdpbr.age, 
      cdpbr.customer_type, cdpbr.vision_type,
      cdpbr.referred_by_id, 
      cdpbr.buyer_customers_id, 
      cdpbr.final_bill_amount,
      cdpbr.repeated_customers_id,
      ccc.customer_id as churn_customers_id
FROM cdpb_repeated as cdpbr
LEFT JOIN churn_customers as ccc
ON ccc.customer_id=cdpbr.all_customers_id
),
-- referrers_details CTE query
referrers AS (
SELECT DISTINCT c.referred_by_id 
FROM customers_details as c
WHERE c.referred_by_id IS NOT NULL
),
cdpbrc_referrers AS (
SELECT 
	  cdpbr.all_customers_id, cdpbr.age, 
      cdpbr.customer_type, cdpbr.vision_type,
      cdpbr.referred_by_id, 
      cdpbr.buyer_customers_id, 
      cdpbr.final_bill_amount,
      cdpbr.repeated_customers_id,
      cdpbr.customer_id as churn_customers_id,
      r.referred_by_id 
FROM cdpbr_churn as cdpbrc
LEFT JOIN referrers as r
ON r.referred_by_id=cdpbr.all_customers_id
)
SELECT 
      CASE 
	WHEN cdpbrcr.age < 20 THEN "Teenage_Customer"
    WHEN cdpbrcr.age BETWEEN 20 AND 30 THEN "20's Customer"
    WHEN cdpbrcr.age BETWEEN 31 AND 40 THEN "30's Customer"
    WHEN cdpbrcr.age BETWEEN 41 AND 50 THEN "40's Customer"
    WHEN cdpbrcr.age BETWEEN 51 AND 60 THEN "50's Customer"
    WHEN cdpbrcr.age > 60 THEN "Old_Age Customers"
  END AS Age_group,
-- visited customers
COUNT( DISTINCT cdpbrcr.all_customers_id) AS Visited_Customers,
-- buyer customers 
COUNT( DISTINCT cdpbrcr.buyer_customers_id) AS Buyer_Customers,
ROUND( COUNT( DISTINCT cdpbrcr.buyer_customers_id)*100 / 
	    COUNT( DISTINCT cdpbrcr.all_customers_id), 2) AS Conversion_Rate,
-- referral_customers
COUNT( DISTINCT CASE WHEN cdpbrcr.referred_by_id IS NOT NULL THEN cdpbrcr.buyer_customers_id END)
AS Referral_Customers,
-- repeated_customers 
COUNT( DISTINCT cdpbrcr.repeated_customers_id) AS Repeated_Customers,
ROUND( COUNT( DISTINCT cdpbrcr.repeated_customers_id)*100/
	 COUNT( DISTINCT cdpbrcr.buyer_customers_id), 2) AS Retention_Rate,
-- churn_customers 
COUNT( DISTINCT cdpbrcr.churn_customers_id) AS Churn_Customers,
ROUND( COUNT( DISTINCT cdpbrcr.churn_customers_id)*100/
       COUNT( DISTINCT cdpbrcr.buyer_customers_id), 2) AS Churn_Rate,
-- referrers count
COUNT(DISTINCT cdpbrcr.referred_by_id ) AS Referrers_Count,
ROUND( COUNT(DISTINCT cdpbrcr.referred_by_id )*100/
       COUNT( DISTINCT cdpbrcr.all_customers_id), 2) AS Referrers_Rate,
-- revenue collection
SUM(cdpbrcr.final_bill_amount) AS Revenue,
ROUND( SUM(cdpbrcr.final_bill_amount)*100/ (SELECT SUM(final_bill_amount) FROM invoices), 2) 
AS Contribution_in_revenue
FROM cdpbr_churn as cdpbrcr
GROUP BY Age_group WITH ROLLUP;

-- Query 2)
-- Vision Type Summary of Customers 
WITH customers AS (
SELECT DISTINCT customer_id as all_customers_id
FROM customers_details as c
),
cd_details AS (
SELECT 
      c.all_customers_id, cc.age, 
      cc.customer_type, 
      cc.referred_by_id
FROM customers as c
INNER JOIN customers_details as cc
ON c.all_customers_id=cc.customer_id
),
cd_prescriptions AS (
SELECT 
	  cd.all_customers_id, cd.age, 
      cd.customer_type, cd.referred_by_id,  
	  p.vision_type
FROM cd_details as cd
INNER JOIN prescriptions as p
ON cd.all_customers_id=p.customer_id
),
cdp_buyers AS (
SELECT 
	  cdp.all_customers_id, cdp.age, 
      cdp.customer_type, cdp.vision_type,
      cdp.referred_by_id, 
      i.customer_id as buyer_customers_id, 
      i.final_bill_amount
FROM cd_prescriptions as cdp
LEFT JOIN invoices as i
ON cdp.all_customers_id=i.customer_id
),
cdpb_repeated AS (
SELECT 
	  cdpb.all_customers_id, cdpb.age, 
      cdpb.customer_type, cdpb.vision_type,
      cdpb.referred_by_id, 
      cdpb.buyer_customers_id as buyer_customers_id, 
      cdpb.final_bill_amount,
      rc.customer_id as repeated_customers_id
FROM cdp_buyers as cdpb
LEFT JOIN repeated_customers as rc
ON cdpb.all_customers_id=rc.customer_id
),
cdpbr_churn AS (
SELECT 
	  cdpbr.all_customers_id, cdpbr.age, 
      cdpbr.customer_type, cdpbr.vision_type,
      cdpbr.referred_by_id, 
      cdpbr.buyer_customers_id, 
      cdpbr.final_bill_amount,
      cdpbr.repeated_customers_id,
      ccc.customer_id as churn_customers_id
FROM cdpb_repeated as cdpbr
LEFT JOIN churn_customers as ccc
ON ccc.customer_id=cdpbr.all_customers_id
),
-- referrers_details CTE query
referrers AS (
SELECT DISTINCT c.referred_by_id 
FROM customers_details as c
WHERE c.referred_by_id IS NOT NULL
),
cdpbrc_referrers AS (
SELECT 
	  cdpbr.all_customers_id, cdpbr.age, 
      cdpbr.customer_type, cdpbr.vision_type,
      cdpbr.referred_by_id, 
      cdpbr.buyer_customers_id, 
      cdpbr.final_bill_amount,
      cdpbr.repeated_customers_id,
      cdpbr.customer_id as churn_customers_id,
      r.referred_by_id 
FROM cdpbr_churn as cdpbrc
LEFT JOIN referrers as r
ON r.referred_by_id=cdpbr.all_customers_id
)
SELECT 
	  cdpbrcr.vision_type,
      COUNT( DISTINCT cdpbrcr.all_customers_id) AS Visited_Customers,
-- buyer customers 
COUNT( DISTINCT cdpbrcr.buyer_customers_id) AS Buyer_Customers,
ROUND( COUNT( DISTINCT cdpbrcr.buyer_customers_id)*100 / 
	    COUNT( DISTINCT cdpbrcr.all_customers_id), 2) AS Conversion_Rate,
-- referral_customers
COUNT( DISTINCT CASE WHEN cdpbrcr.referred_by_id IS NOT NULL THEN cdpbrcr.buyer_customers_id END)
AS Referral_Customers,
-- repeated_customers 
COUNT( DISTINCT cdpbrcr.repeated_customers_id) AS Repeated_Customers,
ROUND( COUNT( DISTINCT cdpbrcr.repeated_customers_id)*100/
	 COUNT( DISTINCT cdpbrcr.buyer_customers_id), 2) AS Retention_Rate,
-- churn_customers 
COUNT( DISTINCT cdpbrcr.churn_customers_id) AS Churn_Customers,
ROUND( COUNT( DISTINCT cdpbrcr.churn_customers_id)*100/
       COUNT( DISTINCT cdpbrcr.buyer_customers_id), 2) AS Churn_Rate,
-- referrers count
COUNT(DISTINCT cdpbrcr.referred_by_id ) AS Referrers_Count,
ROUND( COUNT(DISTINCT cdpbrcr.referred_by_id )*100/
       COUNT( DISTINCT cdpbrcr.all_customers_id), 2) AS Referrers_Rate,
-- revenue collection
SUM(cdpbrcr.final_bill_amount) AS Revenue,
ROUND( SUM(cdpbrcr.final_bill_amount)*100/ (SELECT SUM(final_bill_amount) FROM invoices), 2) 
AS Contribution_in_revenue
FROM cdpbr_churn as cdpbrcr
GROUP BY cdpbrcr.vision_type WITH ROLLUP;

-- Query 3)
-- Customer_Type Summary 
WITH customers AS (
SELECT DISTINCT customer_id as all_customers_id
FROM customers_details as c
),
cd_details AS (
SELECT 
      c.all_customers_id, cc.age, 
      cc.customer_type, 
      cc.referred_by_id
FROM customers as c
INNER JOIN customers_details as cc
ON c.all_customers_id=cc.customer_id
),
cd_prescriptions AS (
SELECT 
	  cd.all_customers_id, cd.age, 
      cd.customer_type, cd.referred_by_id,  
	  p.vision_type
FROM cd_details as cd
INNER JOIN prescriptions as p
ON cd.all_customers_id=p.customer_id
),
cdp_buyers AS (
SELECT 
	  cdp.all_customers_id, cdp.age, 
      cdp.customer_type, cdp.vision_type,
      cdp.referred_by_id, 
      i.customer_id as buyer_customers_id, 
      i.final_bill_amount
FROM cd_prescriptions as cdp
LEFT JOIN invoices as i
ON cdp.all_customers_id=i.customer_id
),
cdpb_repeated AS (
SELECT 
	  cdpb.all_customers_id, cdpb.age, 
      cdpb.customer_type, cdpb.vision_type,
      cdpb.referred_by_id, 
      cdpb.buyer_customers_id as buyer_customers_id, 
      cdpb.final_bill_amount,
      rc.customer_id as repeated_customers_id
FROM cdp_buyers as cdpb
LEFT JOIN repeated_customers as rc
ON cdpb.all_customers_id=rc.customer_id
),
cdpbr_churn AS (
SELECT 
	  cdpbr.all_customers_id, cdpbr.age, 
      cdpbr.customer_type, cdpbr.vision_type,
      cdpbr.referred_by_id, 
      cdpbr.buyer_customers_id, 
      cdpbr.final_bill_amount,
      cdpbr.repeated_customers_id,
      ccc.customer_id as churn_customers_id
FROM cdpb_repeated as cdpbr
LEFT JOIN churn_customers as ccc
ON ccc.customer_id=cdpbr.all_customers_id
),
-- referrers_details CTE query
referrers AS (
SELECT DISTINCT c.referred_by_id 
FROM customers_details as c
WHERE c.referred_by_id IS NOT NULL
),
cdpbrc_referrers AS (
SELECT 
	  cdpbr.all_customers_id, cdpbr.age, 
      cdpbr.customer_type, cdpbr.vision_type,
      cdpbr.referred_by_id, 
      cdpbr.buyer_customers_id, 
      cdpbr.final_bill_amount,
      cdpbr.repeated_customers_id,
      cdpbr.customer_id as churn_customers_id,
      r.referred_by_id 
FROM cdpbr_churn as cdpbrc
LEFT JOIN referrers as r
ON r.referred_by_id=cdpbr.all_customers_id
)
SELECT 
	  cdpbrcr.customer_type,
      COUNT( DISTINCT cdpbrcr.all_customers_id) AS Visited_Customers,
-- buyer customers 
COUNT( DISTINCT cdpbrcr.buyer_customers_id) AS Buyer_Customers,
ROUND( COUNT( DISTINCT cdpbrcr.buyer_customers_id)*100 / 
	    COUNT( DISTINCT cdpbrcr.all_customers_id), 2) AS Conversion_Rate,
-- referral_customers
COUNT( DISTINCT CASE WHEN cdpbrcr.referred_by_id IS NOT NULL THEN cdpbrcr.buyer_customers_id END)
AS Referral_Customers,
-- repeated_customers 
COUNT( DISTINCT cdpbrcr.repeated_customers_id) AS Repeated_Customers,
ROUND( COUNT( DISTINCT cdpbrcr.repeated_customers_id)*100/
	 COUNT( DISTINCT cdpbrcr.buyer_customers_id), 2) AS Retention_Rate,
-- churn_customers 
COUNT( DISTINCT cdpbrcr.churn_customers_id) AS Churn_Customers,
ROUND( COUNT( DISTINCT cdpbrcr.churn_customers_id)*100/
       COUNT( DISTINCT cdpbrcr.buyer_customers_id), 2) AS Churn_Rate,
-- referrers count
COUNT(DISTINCT cdpbrcr.referred_by_id ) AS Referrers_Count,
ROUND( COUNT(DISTINCT cdpbrcr.referred_by_id )*100/
       COUNT( DISTINCT cdpbrcr.all_customers_id), 2) AS Referrers_Rate,
-- revenue collection
SUM(cdpbrcr.final_bill_amount) AS Revenue,
ROUND( SUM(cdpbrcr.final_bill_amount)*100/ (SELECT SUM(final_bill_amount) FROM invoices), 2) 
AS Contribution_in_revenue
FROM cdpbr_churn as cdpbrcr
GROUP BY cdpbrcr.customer_type WITH ROLLUP;

-- Query 4)
-- staff summary 
WITH customers AS (
SELECT DISTINCT customer_id as all_customers_id
FROM customers_details as c
),
cd_details AS (
SELECT 
      c.all_customers_id, cc.age, 
      cc.customer_type, cc.assigned_staff_id,
      cc.referred_by_id
FROM customers as c
INNER JOIN customers_details as cc
ON c.all_customers_id=cc.customer_id
),
cd_prescriptions AS (
SELECT 
	  cd.all_customers_id, cd.age, 
      cd.customer_type, cd.referred_by_id,  
      cd.assigned_staff_id,
	  p.vision_type
FROM cd_details as cd
INNER JOIN prescriptions as p
ON cd.all_customers_id=p.customer_id
),
cdp_buyers AS (
SELECT 
	  cdp.all_customers_id, cdp.age, 
      cdp.customer_type, cdp.vision_type,
      cdp.referred_by_id, cdp.assigned_staff_id,
      i.customer_id as buyer_customers_id, 
      i.final_bill_amount
FROM cd_prescriptions as cdp
LEFT JOIN invoices as i
ON cdp.all_customers_id=i.customer_id
),
cdpb_repeated AS (
SELECT 
	  cdpb.all_customers_id, cdpb.age, 
      cdpb.customer_type, cdpb.vision_type,
      cdpb.referred_by_id, cdpb.assigned_staff_id,
      cdpb.buyer_customers_id as buyer_customers_id, 
      cdpb.final_bill_amount,
      rc.customer_id as repeated_customers_id
FROM cdp_buyers as cdpb
LEFT JOIN repeated_customers as rc
ON cdpb.all_customers_id=rc.customer_id
),
cdpbr_churn AS (
SELECT 
	  cdpbr.all_customers_id, cdpbr.age, 
      cdpbr.customer_type, cdpbr.vision_type,
      cdpbr.referred_by_id, cdpbr.assigned_staff_id,
      cdpbr.buyer_customers_id, 
      cdpbr.final_bill_amount,
      cdpbr.repeated_customers_id,
      ccc.customer_id as churn_customers_id
FROM cdpb_repeated as cdpbr
LEFT JOIN repeated_churn_customers as ccc
ON ccc.customer_id=cdpbr.all_customers_id
),
-- referrers_details CTE query
referrers AS (
SELECT DISTINCT c.referred_by_id 
FROM customers_details as c
WHERE c.referred_by_id IS NOT NULL
),
cdpbrc_referrers AS (
SELECT 
	  cdpbrc.all_customers_id, cdpbrc.age, 
      cdpbrc.customer_type, cdpbrc.vision_type,
      cdpbrc.referred_by_id, cdpbrc.assigned_staff_id,
      cdpbrc.buyer_customers_id, 
      cdpbrc.final_bill_amount,
      cdpbrc.repeated_customers_id,
      cdpbrc.churn_customers_id
FROM cdpbr_churn as cdpbrc
LEFT JOIN referrers as r
ON r.referred_by_id=cdpbrc.all_customers_id
),
cdpbrcr_staff AS (
SELECT 
	  cdpbrcr.all_customers_id, cdpbrcr.age, 
      cdpbrcr.customer_type, cdpbrcr.vision_type,
      cdpbrcr.referred_by_id, cdpbrcr.assigned_staff_id,
      cdpbrcr.buyer_customers_id, s.staff_full_name,
      cdpbrcr.final_bill_amount,
      cdpbrcr.repeated_customers_id,
      cdpbrcr.churn_customers_id
FROM cdpbrc_referrers as cdpbrcr 
LEFT JOIN staff as s
ON s.staff_id=cdpbrcr.assigned_staff_id
)
SELECT 
       cdpbrcrs.assigned_staff_id, cdpbrcrs.staff_full_name,
       
      COUNT( DISTINCT cdpbrcrs.all_customers_id) AS Visited_Customers,
-- buyer customers 
COUNT( DISTINCT cdpbrcrs.buyer_customers_id) AS Buyer_Customers,
ROUND( COUNT( DISTINCT cdpbrcrs.buyer_customers_id)*100 / 
	    COUNT( DISTINCT cdpbrcrs.all_customers_id), 2) AS Conversion_Rate,
-- referral_customers
COUNT( DISTINCT CASE WHEN cdpbrcrs.referred_by_id IS NOT NULL THEN cdpbrcrs.buyer_customers_id END)
AS Referral_Customers,
-- repeated_customers 
COUNT( DISTINCT cdpbrcrs.repeated_customers_id) AS Repeated_Customers,
ROUND( COUNT( DISTINCT cdpbrcrs.repeated_customers_id)*100/
	 COUNT( DISTINCT cdpbrcrs.buyer_customers_id), 2) AS Retention_Rate,
-- churn_customers 
COUNT( DISTINCT cdpbrcrs.churn_customers_id) AS Churn_Customers,
ROUND( COUNT( DISTINCT cdpbrcrs.churn_customers_id)*100/
       COUNT( DISTINCT cdpbrcrs.buyer_customers_id), 2) AS Churn_Rate,
-- referrers count
COUNT(DISTINCT cdpbrcrs.referred_by_id ) AS Referrers_Count,
ROUND( COUNT(DISTINCT cdpbrcrs.referred_by_id )*100/
       COUNT( DISTINCT cdpbrcrs.all_customers_id), 2) AS Referrers_Rate,
-- -- revenue collection
SUM(cdpbrcrs.final_bill_amount) AS Revenue,
ROUND( SUM(cdpbrcrs.final_bill_amount)*100/ (SELECT SUM(final_bill_amount) FROM invoices), 2) 
AS Contribution_in_revenue
FROM cdpbrcr_staff as cdpbrcrs
GROUP BY cdpbrcrs.assigned_staff_id, cdpbrcrs.staff_full_name;
 
-- VIEW for summary analysis 

CREATE VIEW summary_analysis AS 
WITH customers AS (
SELECT DISTINCT customer_id as all_customers_id
FROM customers_details as c
),
cd_details AS (
SELECT 
      c.all_customers_id, cc.age, 
      cc.customer_type, cc.assigned_staff_id,
      cc.referred_by_id
FROM customers as c
INNER JOIN customers_details as cc
ON c.all_customers_id=cc.customer_id
),
cd_prescriptions AS (
SELECT 
	  cd.all_customers_id, cd.age, 
      cd.customer_type, cd.referred_by_id,  
      cd.assigned_staff_id,
	  p.vision_type
FROM cd_details as cd
INNER JOIN prescriptions as p
ON cd.all_customers_id=p.customer_id
),
cdp_buyers AS (
SELECT 
	  cdp.all_customers_id, cdp.age, 
      cdp.customer_type, cdp.vision_type,
      cdp.referred_by_id, cdp.assigned_staff_id,
      i.customer_id as buyer_customers_id, 
      i.final_bill_amount
FROM cd_prescriptions as cdp
LEFT JOIN invoices as i
ON cdp.all_customers_id=i.customer_id
),
cdpb_repeated AS (
SELECT 
	  cdpb.all_customers_id, cdpb.age, 
      cdpb.customer_type, cdpb.vision_type,
      cdpb.referred_by_id, cdpb.assigned_staff_id,
      cdpb.buyer_customers_id as buyer_customers_id, 
      cdpb.final_bill_amount,
      rc.customer_id as repeated_customers_id
FROM cdp_buyers as cdpb
LEFT JOIN repeated_customers as rc
ON cdpb.all_customers_id=rc.customer_id
),
cdpbr_churn AS (
SELECT 
	  cdpbr.all_customers_id, cdpbr.age, 
      cdpbr.customer_type, cdpbr.vision_type,
      cdpbr.referred_by_id, cdpbr.assigned_staff_id,
      cdpbr.buyer_customers_id, 
      cdpbr.final_bill_amount,
      cdpbr.repeated_customers_id,
      ccc.customer_id as churn_customers_id
FROM cdpb_repeated as cdpbr
LEFT JOIN repeated_churn_customers as ccc
ON ccc.customer_id=cdpbr.all_customers_id
),
-- referrers_details CTE query
referrers AS (
SELECT DISTINCT c.referred_by_id 
FROM customers_details as c
WHERE c.referred_by_id IS NOT NULL
),
cdpbrc_referrers AS (
SELECT 
	  cdpbrc.all_customers_id, cdpbrc.age, 
      cdpbrc.customer_type, cdpbrc.vision_type,
      cdpbrc.referred_by_id, cdpbrc.assigned_staff_id,
      cdpbrc.buyer_customers_id, 
      cdpbrc.final_bill_amount,
      cdpbrc.repeated_customers_id,
      cdpbrc.churn_customers_id
FROM cdpbr_churn as cdpbrc
LEFT JOIN referrers as r
ON r.referred_by_id=cdpbrc.all_customers_id
),
cdpbrcr_staff AS (
SELECT 
	  cdpbrcr.all_customers_id, cdpbrcr.age, 
      cdpbrcr.customer_type, cdpbrcr.vision_type,
      cdpbrcr.referred_by_id, cdpbrcr.assigned_staff_id,
      cdpbrcr.buyer_customers_id, s.staff_full_name,
      cdpbrcr.final_bill_amount,
      cdpbrcr.repeated_customers_id,
      cdpbrcr.churn_customers_id
FROM cdpbrc_referrers as cdpbrcr 
LEFT JOIN staff as s
ON s.staff_id=cdpbrcr.assigned_staff_id
)
SELECT 
	  cdpbrcrs.all_customers_id, cdpbrcrs.age, 
      cdpbrcrs.customer_type, cdpbrcrs.vision_type,
      cdpbrcrs.referred_by_id, cdpbrcrs.assigned_staff_id,
      cdpbrcrs.buyer_customers_id, cdpbrcrs.staff_full_name,
      cdpbrcrs.final_bill_amount,
      cdpbrcrs.repeated_customers_id,
      cdpbrcrs.churn_customers_id
FROM cdpbrcr_staff as cdpbrcrs;


