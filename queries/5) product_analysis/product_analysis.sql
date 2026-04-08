-- ===================================================
--  ============= 4.0) Product Analysis =============
-- ===================================================

-- 4.0) PRODUCT ANALYSIS NOTE:
-- All revenue in this section is calculated using Net Product Price (Excluding Tax).
-- This ensures that product performance metrics are not skewed by tax variations.

-- 4.1.1) exploring the products
SELECT * FROM products;

-- 4.1.2) exploring the type of products we sell
SELECT * FROM product_type;

-- 4.1.3) exploring the brands we sell
SELECT * FROM product_brand;

-- 4.1.4) Overall Checking the types of product, product_type and brand we sell
SELECT p.product_id, p.product_name, pt.product_type_id, pt.product_type_name, pb.brand_id, pb.brand_name
FROM products as p
INNER JOIN product_type as pt
ON p.product_id=pt.product_id
INNER JOIN product_brand as pb
ON p.product_id=pb.product_id;

-- COUNT OF all the types of products we sell=201
SELECT COUNT(*) AS COUNT_All_Types_of_Products_we_Sell
FROM products as p
INNER JOIN product_type as pt
ON p.product_id=pt.product_id
INNER JOIN product_brand as pb
ON p.product_id=pb.product_id;

-- 4.2.1) Revenue By each product we sell 
SELECT ii.product_id, pd.product_name, SUM(ii.final_product_price) AS Revenue_Each_Product
FROM invoice_items as ii
INNER JOIN products as pd
ON ii.product_id=pd.product_id
GROUP BY ii.product_id, pd.product_name
ORDER BY Revenue_Each_Product DESC;

-- verifying the query  45185294.00
SELECT SUM(ii.final_product_price) FROM invoice_items as ii;

-- 4.2.2) Quantity of Products Solds by each Product

SELECT ii.product_id, pd.product_name, SUM(ii.quantity) AS Quantity_Sold
FROM invoice_items as ii
INNER JOIN products as pd
ON pd.product_id=ii.product_id
GROUP BY ii.product_id, pd.product_name 
ORDER BY Quantity_Sold DESC;

-- OR

WITH products AS (
SELECT p.product_id, p.product_name
FROM products as p
)
SELECT ii.product_id, p.product_name, SUM(ii.quantity) AS Quantity_Sold
FROM invoice_items as ii
INNER JOIN products as p
ON p.product_id=ii.product_id
GROUP BY ii.product_id, p.product_name 
ORDER BY Quantity_Sold DESC;

-- 4.2.3) Products V/S Customer_Type

WITH products AS (
SELECT p.product_id, p.product_name
FROM products as p
)
SELECT ii.product_id, pd.product_name,
	   SUM( CASE WHEN customer_type="New" THEN ii.quantity ELSE 0 END) AS New,
       SUM( CASE WHEN customer_type="Referral" THEN ii.quantity ELSE 0 END) AS Referral
FROM invoice_items as ii
INNER JOIN invoices as i
ON ii.invoice_id=i.invoice_id
INNER JOIN customers_details as c
ON c.customer_id=i.customer_id
INNER JOIN products as pd
ON pd.product_id=ii.product_id
GROUP BY ii.product_id, pd.product_name;

-- verifying the query
SELECT SUM(ii.quantity) AS Total_Quantities_Sold FROM invoice_items as ii;
 
-- 4.2.4) Revenue Comparison with Tax and without Tax

-- Revenue_without_Tax = 45185294.00
SELECT SUM(final_product_price) AS Revenue_without_Tax FROM invoice_items;

-- Revenue_with_Tax = 46811413.00
SELECT SUM(final_bill_amount) AS Revenue_with_Tax FROM invoices;

-- Amount_Tax_Collected = 1626119 Tax Collected from the 
SELECT (ROUND( (SELECT SUM(final_bill_amount) FROM invoices) - (SELECT SUM(final_product_price) FROM invoice_items))) AS Tax_Collected;

-- 4.2.5) Revenue Collected from each brand
SELECT pb.brand_id, pb.brand_name, SUM(ii.final_product_price) AS Revenue_Collected_Brand
FROM product_brand as pb
INNER JOIN invoice_items as ii
ON pb.brand_id=ii.brand_id
GROUP BY pb.brand_id, pb.brand_name
ORDER BY Revenue_Collected_Brand DESC;

-- 4.2.6) Revenue by each type of product 
SELECT pt.product_id, pd.product_name, ii.product_type_id, pt.product_type_name, SUM(ii.final_product_price) AS Revenue_each_product_type
FROM invoice_items as ii
INNER JOIN products as pd
ON pd.product_id=ii.product_id
INNER JOIN product_type as pt
ON ii.product_type_id=pt.product_type_id
GROUP BY pt.product_id, pd.product_name, ii.product_type_id, pt.product_type_name 
ORDER BY ii.product_type_id DESC;

-- 4.2.7) Revenue by each product brand 
SELECT ii.product_id, ii.brand_id, SUM(ii.final_product_price) AS Revenue_brand
FROM invoice_items as ii
GROUP BY ii.brand_id, ii.product_id 
ORDER BY Revenue_brand DESC;
-- OR
WITH product_name_brand_name AS (
SELECT pd.product_id, pd.product_name, pb.brand_id, pb.brand_name
FROM products as pd
INNER JOIN product_brand as pb
ON pd.product_id=pb.product_id
)
SELECT pnbn.product_id, pnbn.product_name, pnbn.brand_id, pnbn.brand_name, SUM(ii.final_product_price) AS Revenue_Brand
FROM product_name_brand_name as pnbn
INNER JOIN invoice_items as ii
ON pnbn.brand_id=ii.brand_id
GROUP BY pnbn.product_id, pnbn.product_name, pnbn.brand_id, pnbn.brand_name 
ORDER BY Revenue_Brand DESC;

-- 4.2.8) Products + Customer_Age V/S Quantity of Products Sold
WITH unique_customers AS (
SELECT DISTINCT c.customer_id
FROM customers_details as c
INNER JOIN invoices as i
ON c.customer_id=i.customer_id
),
customer_age AS (
SELECT uc.customer_id, c.age
FROM unique_customers as uc
INNER JOIN customers_details as c
ON c.customer_id=uc.customer_id
),
customer_age_invoice AS (
SELECT ca.customer_id, ca.age, i.invoice_id
FROM customer_age as ca
INNER JOIN invoices as i
ON ca.customer_id=i.customer_id
),
customer_age_invoice_items AS (
SELECT cai.customer_id, cai.age, cai.invoice_id, ii.item_id, ii.product_id, ii.product_type_id, ii.brand_id, ii.final_product_price
FROM customer_age_invoice AS cai
INNER JOIN invoice_items as ii
ON cai.invoice_id=ii.invoice_id
)
SELECT 
CASE
    WHEN caii.age < 20 THEN "Teenage_Customer"
    WHEN caii.age BETWEEN 20 AND 30 THEN "20's Customer"
    WHEN caii.age BETWEEN 31 AND 40 THEN "30's Customer"
    WHEN caii.age BETWEEN 41 AND 50 THEN "40's Customer"
    WHEN caii.age BETWEEN 51 AND 60 THEN "50's Customer"
    WHEN caii.age > 60 THEN "Old_Age Customers"
  END AS Age_group,
SUM(CASE WHEN caii.product_id=1 THEN 1 END) AS QTY_Frames_SOLD,
SUM(CASE WHEN caii.product_id=2 THEN 1 END) AS QTY_Glass_SOLD,
SUM(CASE WHEN caii.product_id=3 THEN 1 END) AS QTY_Sunglass_SOLD,
SUM(CASE WHEN caii.product_id=4 THEN 1 END) AS QTY_Contact_Lens_SOLD,
SUM(CASE WHEN caii.product_id=6 THEN 1 END) AS QTY_Lens_SolutionS_SOLD,
SUM(CASE WHEN caii.product_id=5 THEN 1 END) AS QTY_Acessories_SOLD
FROM customer_age_invoice_items AS caii  
GROUP BY Age_group WITH ROLLUP;

-- Repeated Customers V/S Products

WITH unique_customers_from_invoices AS (
SELECT DISTINCT i.customer_id FROM invoices as i
),
repeated_customers AS (
SELECT DISTINCT rc.customer_id 
FROM repeated_customers as rc
INNER JOIN unique_customers_from_invoices as ucfi
ON rc.customer_id=ucfi.customer_id
),
repeated_customers_invoices AS (
SELECT rc.customer_id, i.invoice_id 
FROM repeated_customers as rc
INNER JOIN invoices as i
ON rc.customer_id=i.customer_id
),
repeated_customers_invoices_items AS (
SELECT rci.customer_id, rci.invoice_id, ii.item_id, ii.product_id, ii.brand_id, ii.product_type_id
FROM repeated_customers_invoices as rci
INNER JOIN invoice_items as ii
ON rci.invoice_id=ii.invoice_id
)
SELECT rcii.product_id, COUNT(rcii.customer_id)
FROM repeated_customers_invoices_items as rcii
GROUP BY rcii.product_id WITH ROLLUP
ORDER BY COUNT(rcii.customer_id) DESC;