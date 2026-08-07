
-- ======================================================
--     =========== 3) Staff Analysis ============
-- ======================================================

-- 3.1) Extracting the Staff from the staff_tabele - we have a total of 20 Staffs
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

-- 3.6) COUNT of Repeated Customers Handle by each staff

WITH repeated_customers AS (
SELECT i.customer_id 
FROM invoices as i
GROUP BY i.customer_id
HAVING COUNT(i.customer_id) > 1
)
SELECT c.assigned_staff_id, COUNT(DISTINCT rc.customer_id) AS COUNT_Repeated_Customers
FROM customers_details as c
INNER JOIN repeated_customers as rc
ON rc.customer_id=c.customer_id
GROUP BY c.assigned_staff_id WITH ROLLUP
ORDER BY COUNT_Repeated_Customers DESC;

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

-- 3.11) COUNT of different Age_group Repeated_Customers handle by each staff
SELECT 
       s.staff_id, s.staff_full_name,
      COUNT(rc.customer_id) AS Total_Repeated_Customers, 
	  SUM( CASE WHEN c.age BETWEEN 13 AND 19 THEN 1 ELSE 0 END) AS Teenage,
      SUM( CASE WHEN c.age BETWEEN 20 AND 29 THEN 1 ELSE 0 END) AS 20s_Customer,
      SUM( CASE WHEN c.age BETWEEN 30 AND 39 THEN 1 ELSE 0 END) AS 30s_Customer,
      SUM( CASE WHEN c.age BETWEEN 40 AND 49 THEN 1 ELSE 0 END) AS 40s_Customer,
      SUM( CASE WHEN c.age BETWEEN 50 AND 59 THEN 1 ELSE 0 END) AS 50s_Customer,
      SUM( CASE WHEN c.age > 60 THEN 1 ELSE 0 END) AS Above_60_Old_Age_Customers
FROM staff as s
INNER JOIN customers_details as c
ON s.staff_id=assigned_staff_id
INNER JOIN repeated_customers as rc
ON rc.customer_id=c.customer_id
GROUP BY s.staff_id, s.staff_full_name;

-- 3.13) Products Sales by each Type

SELECT 
      s.staff_id, s.staff_full_name,
      SUM(CASE WHEN pd.product_id=1 THEN ii.quantity END) AS Frame,
      SUM(CASE WHEN pd.product_id=2 THEN ii.quantity END) AS Glass,
      SUM(CASE WHEN pd.product_id=3 THEN ii.quantity END) AS Sunglass,
      SUM(CASE WHEN pd.product_id=4 THEN ii.quantity END) AS Contact_Lens,
      SUM(CASE WHEN pd.product_id=6 THEN ii.quantity END) AS Lens_Solution
FROM staff as s
INNER JOIN customers_details as c
ON s.staff_id=assigned_staff_id
INNER JOIN invoices as i
ON c.customer_id=i.customer_id
INNER JOIN invoice_items as ii
ON i.invoice_id=ii.invoice_id
INNER JOIN products as pd
ON ii.product_id=pd.product_id
GROUP BY s.staff_id, s.staff_full_name;

-- verifying the Query
SELECT COUNT(*) FROM invoice_items;

-- New Staff Analysis Queries 
-- 1) How wide is the performance gap between our highest and lowest revenue generating staff, 
-- and is the business overly dependent on a small group of top performers?
-- ( Basically Staff who is generating the highest revenue )

SELECT  
      
      i.staff_id, s.staff_full_name,
      SUM(i.final_bill_amount) AS Revenue_by_Staff,
      ROUND(SUM(i.final_bill_amount) * 100 / 46811413.00, 2) 
      AS Percentage_of_Revenue
FROM invoices as i
INNER JOIN staff as s
ON s.staff_id=i.staff_id
GROUP BY i.staff_id, s.staff_full_name 
ORDER BY Revenue_by_Staff DESC;

-- 2) Which staff members deviate most significantly from the store-wide conversion rate benchmark, 
-- and are they flagged as above or below expectation? 
-- ( Basically the staff based on their customers conversion rate )

SELECT 
	c.assigned_staff_id, s.staff_full_name,
	COUNT(DISTINCT c.customer_id) AS Visited_Customers,
	COUNT(DISTINCT i.customer_id) AS Buyer_Customers,
	ROUND( COUNT(DISTINCT i.customer_id) * 100 / 
	COUNT(DISTINCT c.customer_id), 2 )
      AS Customer_Conversion_Rate
FROM customers_details as c
INNER JOIN staff as s
ON c.assigned_staff_id=s.staff_id
LEFT JOIN invoices as i
ON c.customer_id=i.customer_id
GROUP BY c.assigned_staff_id, s.staff_full_name
ORDER BY Customer_Conversion_Rate DESC;

-- 3) What percentage of each staff member's customer base eventually becomes a loyal, 
-- repeated customer identifying who builds long-term relationships versus one-time transactions?
-- ( Basically Customers with the Highest number of repeated Customers )

WITH staff_customers AS (
SELECT 
      DISTINCT i.customer_id,
      i.staff_id, s.staff_full_name
FROM staff as s
INNER JOIN invoices as i
ON s.staff_id=i.staff_id
),
staff_customers_loyalty AS (
SELECT  
      sc.staff_id, sc.staff_full_name,
      sc.customer_id, 
      rc.customer_id AS repeated_customers_id
FROM staff_customers as sc
LEFT JOIN repeated_customers as rc
ON rc.customer_id=sc.customer_id
)
SELECT 
      scl.staff_id, scl.staff_full_name,
      COUNT( DISTINCT scl.customer_id) 
      AS Buyer_Customers,
      COUNT( DISTINCT scl.repeated_customers_id) 
      AS Repeated_Customers_Base,
	  COUNT( DISTINCT CASE WHEN scl.repeated_customers_id IS NULL THEN scl.customer_id END)
      AS Non_Repeated_Customers, 
      ROUND( COUNT( DISTINCT scl.repeated_customers_id) * 100 /
      COUNT( DISTINCT scl.customer_id), 2) AS Loyalty_Conversion_Rate,
      ROUND( COUNT( DISTINCT CASE WHEN scl.repeated_customers_id IS NULL THEN scl.customer_id END) * 100 /
      COUNT( DISTINCT scl.customer_id), 2) AS Customer_Churn_Rate
FROM staff_customers_loyalty as scl
GROUP BY scl.staff_id, scl.staff_full_name 
ORDER BY Loyalty_Conversion_Rate DESC;

-- Just an Optional Query,
-- Customers handled by each staff based on customer age

WITH customers_age AS (
SELECT c.customer_id, c.age
FROM customers_details as c
),
buyer_customers_age AS (
SELECT DISTINCT i.customer_id as buyer_customers, ca.age, 
       i.staff_id
FROM customers_age as ca
INNER JOIN invoices as i
ON ca.customer_id=i.customer_id
),
buyer_customers_age_staff AS (
SELECT bca.buyer_customers, bca.age,
       bca.staff_id, s.staff_full_name
FROM buyer_customers_age as bca
INNER JOIN staff as s
ON s.staff_id=bca.staff_id
)
SELECT bcas.staff_id, bcas.staff_full_name,
       COUNT(DISTINCT bcas.buyer_customers) AS Total_Buyer_Customers,
       COUNT(DISTINCT CASE WHEN bcas.age < 20 THEN bcas.buyer_customers END ) 
       AS Teenage_Customers,
       COUNT( DISTINCT CASE WHEN bcas.age BETWEEN 20 AND 30 THEN bcas.buyer_customers END)
       AS 20s_Customers,
       COUNT( DISTINCT CASE WHEN bcas.age BETWEEN 31 AND 40 THEN bcas.buyer_customers END)
       AS 30s_Customers,
       COUNT( DISTINCT CASE WHEN bcas.age BETWEEN 41 AND 50 THEN bcas.buyer_customers END)
       AS 40s_Customers,
       COUNT( DISTINCT CASE WHEN bcas.age BETWEEN 51 AND 60 THEN bcas.buyer_customers END)
       AS 50s_Customers,
       COUNT( DISTINCT CASE WHEN bcas.age > 60  THEN bcas.buyer_customers END)
       AS Old_Age_Customers
FROM buyer_customers_age_staff AS bcas
GROUP BY bcas.staff_id, bcas.staff_full_name;

-- 4) Does each staff member sell a balanced mix of products, or are they overly reliant 
-- on a single product category and what risk does this concentration pose?
-- Products Sales by each Type
-- 4.1) Products sold by staff
SELECT 
	s.staff_id, s.staff_full_name,
	SUM(CASE WHEN pd.product_id=1 THEN ii.quantity END) AS Frame,
	SUM(CASE WHEN pd.product_id=2 THEN ii.quantity END) AS Glass,
	SUM(CASE WHEN pd.product_id=3 THEN ii.quantity END) AS Sunglass,
	SUM(CASE WHEN pd.product_id=4 THEN ii.quantity END) AS Contact_Lens,
	SUM(CASE WHEN pd.product_id=6 THEN ii.quantity END) AS Lens_Solution
FROM staff as s
INNER JOIN customers_details as c
ON s.staff_id=assigned_staff_id
INNER JOIN invoices as i
ON c.customer_id=i.customer_id
INNER JOIN invoice_items as ii
ON i.invoice_id=ii.invoice_id
INNER JOIN products as pd
ON ii.product_id=pd.product_id
GROUP BY s.staff_id, s.staff_full_name;

-- 4.2) 
WITH brand AS (
SELECT i.staff_id, s.staff_full_name, 
       i.invoice_id, 
       ii.quantity,
       ii.product_id,
       pb.brand_id,
       pb.brand_name
FROM staff as s
INNER JOIN invoices as i
ON s.staff_id=i.staff_id
INNER JOIN invoice_items as ii
ON ii.invoice_id=i.invoice_id
INNER JOIN product_brand as pb
ON pb.brand_id=ii.brand_id
)
SELECT 
       b.staff_id, b.staff_full_name,
       COUNT( CASE WHEN b.product_id=1 AND brand_id=1 THEN b.quantity END) AS Frame_Local_Brand,
       COUNT( CASE WHEN b.product_id=1 AND brand_id=2 THEN b.quantity END) AS Frame_K_D,
       COUNT( CASE WHEN b.product_id=1 AND brand_id=3 THEN b.quantity END) AS Frame_NOVA,
       COUNT( CASE WHEN b.product_id=1 AND brand_id=4 THEN b.quantity END) AS Frame_Rayban,
       COUNT( CASE WHEN b.product_id=1 AND brand_id=5 THEN b.quantity END) AS Frame_Prada,
       COUNT( CASE WHEN b.product_id=1 AND brand_id=6 THEN b.quantity END) AS Frame_Oakley,
       COUNT( CASE WHEN b.product_id=1 AND brand_id=7 THEN b.quantity END) AS Frame_Carrera,
       COUNT( CASE WHEN b.product_id=1 AND brand_id=8 THEN b.quantity END) AS Frame_Tommy_Hilfiger,
       COUNT( CASE WHEN b.product_id=1 AND brand_id=9 THEN b.quantity END) AS Frame_Calvin_Klien,
       COUNT( CASE WHEN b.product_id=1 AND brand_id=10 THEN b.quantity END) AS Essilor,
       
       COUNT( CASE WHEN b.product_id=2 AND brand_id=11 THEN b.quantity END) AS Glass_Essilor,
       COUNT( CASE WHEN b.product_id=2 AND brand_id=12 THEN b.quantity END) AS Glass_NOVA,
       COUNT( CASE WHEN b.product_id=2 AND brand_id=13 THEN b.quantity END) AS Glass_Prime_Lens,
       COUNT( CASE WHEN b.product_id=2 AND brand_id=14 THEN b.quantity END) AS Glass_Rode_And_Stock,
       COUNT( CASE WHEN b.product_id=2 AND brand_id=15 THEN b.quantity END) AS Glass_Bonzer_Lens,
       COUNT( CASE WHEN b.product_id=2 AND brand_id=16 THEN b.quantity END) AS Glass_Ziess,
       COUNT( CASE WHEN b.product_id=2 AND brand_id=17 THEN b.quantity END) AS Glass_Crizal,
       
       COUNT( CASE WHEN b.product_id=3 AND brand_id=18 THEN b.quantity END) AS Sunglass_Ray_Ban,
       COUNT( CASE WHEN b.product_id=3 AND brand_id=19 THEN b.quantity END) AS Sunglass_Local_Brand,
       
       COUNT( CASE WHEN b.product_id=4 AND brand_id=20 THEN b.quantity END) AS Contact_lens_Baush_Lomb,
       COUNT( CASE WHEN b.product_id=4 AND brand_id=21 THEN b.quantity END) AS Contact_lens_Acme,
       COUNT( CASE WHEN b.product_id=4 AND brand_id=22 THEN b.quantity END) AS Contact_lens_Eye_art,
       
       COUNT( CASE WHEN b.product_id=4 AND brand_id=22 THEN b.quantity END) AS Contact_lens_Eye_art,
       COUNT( CASE WHEN b.product_id=4 AND brand_id=22 THEN b.quantity END) AS Contact_lens_Eye_art,
       COUNT( CASE WHEN b.product_id=4 AND brand_id=22 THEN b.quantity END) AS Contact_lens_Eye_art,
       
       COUNT( CASE WHEN b.product_id=5 AND brand_id=23 THEN b.quantity END) AS Accessories,
       COUNT( CASE WHEN b.product_id=6 AND brand_id=24 THEN b.quantity END) AS Renu_Fresh,
       COUNT( CASE WHEN b.product_id=6 AND brand_id=25 THEN b.quantity END) AS Aqua_soft_bio
FROM brand as b
GROUP BY b.staff_id, b.staff_full_name;

-- 5) 5) Which staff members generate the highest revenue per customer handled, 
-- demonstrating greater sales efficiency rather than simply serving a larger number of customers?

WITH customers_invoices AS (
SELECT 
      i.customer_id, i.staff_id, 
      s.staff_full_name,
      i.final_bill_amount
FROM invoices as i
INNER JOIN staff as s
ON i.staff_id=s.staff_id
)
SELECT 
       ci.staff_id, ci.staff_full_name,
       SUM(ci.final_bill_amount) AS Revenue,
       ROUND( SUM(ci.final_bill_amount) / 
       COUNT(DISTINCT ci.customer_id), 2) 
       AS Revenue_per_Customers
FROM customers_invoices as ci
GROUP BY ci.staff_id, ci.staff_id;

-- 6) Overall Summary of staff memebers

WITH customers AS (
SELECT 
      DISTINCT c.customer_id AS all_customers,
	  c.assigned_staff_id
FROM customers_details as c
),
customers_staff AS (
SELECT 
	  cc.all_customers, cc.assigned_staff_id,
      s.staff_full_name
FROM staff as s
INNER JOIN customers as cc
ON cc.assigned_staff_id=s.staff_id
),
customers_invoices AS (
SELECT 
      DISTINCT i.customer_id AS buyer_customers    
FROM invoices as i
),
customers_staff_invoices AS (
SELECT 
      cs.all_customers, ci.buyer_customers, 
      cs.assigned_staff_id, cs.staff_full_name
FROM customers_staff as cs
LEFT JOIN customers_invoices as ci
ON cs.all_customers=ci.buyer_customers
),
customers_staff_invoices_with_repeated_customers AS (
SELECT 
      csi.all_customers, csi.buyer_customers, 
      rc.customer_id AS repeated_customers,
      csi.assigned_staff_id, csi.staff_full_name
FROM customers_staff_invoices as csi
LEFT JOIN repeated_customers as rc
ON rc.customer_id=csi.buyer_customers 
)
SELECT 
	  csiwrc.assigned_staff_id, csiwrc.staff_full_name,
      COUNT(csiwrc.all_customers) AS Assigned_Customers,
      COUNT(csiwrc.buyer_customers) AS Buyer_Customers,
      COUNT(csiwrc.repeated_customers) AS Repeated_Customers,
      ROUND( COUNT(csiwrc.buyer_customers) * 100 /
      COUNT(csiwrc.all_customers), 2) AS Customer_Conversion_Rate,
      ROUND( COUNT(csiwrc.repeated_customers) * 100 /
      COUNT(csiwrc.buyer_customers), 2) AS Loyalty_Conversion_Rate
FROM customers_staff_invoices_with_repeated_customers as csiwrc
GROUP BY csiwrc.assigned_staff_id, csiwrc.staff_full_name;

-- ==================== END OF Staff Analysis ====================== --
