USE retail_optical_bussiness;

-- EDA (Exploratoty Data Analysis)

-- 1) Show the Tables in the Database
SHOW TABLES;

-- 2) Counting Number of rows in each table

SELECT 'customers_details' AS TABLE_NAME, COUNT(*) AS Number_of_Rows FROM customers_details 
UNION ALL
SELECT 'additional_customer_details', COUNT(*) AS Number_of_Rows FROM additional_customer_details
UNION ALL
SELECT 'invoices', COUNT(*) AS Number_of_Rows FROM invoices
UNION ALL
SELECT 'invoice_items', COUNT(*) AS Number_of_Rows FROM invoice_items
UNION ALL
SELECT 'prescriptions', COUNT(*) AS Number_of_Rows FROM prescriptions
UNION ALL
SELECT 'product_brand', COUNT(*) AS Number_of_Rows FROM product_brand
UNION ALL
SELECT 'product_brand', COUNT(*) AS Number_of_Rows FROM product_brand
UNION ALL
SELECT 'products', COUNT(*) AS Number_of_Rows FROM products
UNION ALL
SELECT 'staff', COUNT(*) AS Number_of_Rows FROM staff
ORDER BY Number_of_Rows DESC;

-- 3) DESCRIBE Command to get the metadata about the tables

DESCRIBE customers_details;
DESCRIBE prescriptions;
DESCRIBE additional_customer_details;
DESCRIBE invoices;
DESCRIBE invoice_items;
DESCRIBE products;
DESCRIBE product_type;
DESCRIBE product_brand;
DESCRIBE staff;

-- 4) Identifying the null values in each column of the Table

-- customer_details
SELECT 
    SUM(CASE WHEN customer_full_name IS NULL THEN 1 ELSE 0 END) AS missing_names,
    SUM(CASE WHEN mobile IS NULL THEN 1 ELSE 0 END) AS missing_mobile,
    SUM(CASE WHEN customer_type IS NULL THEN 1 ELSE 0 END) AS missing_type,
    SUM(CASE WHEN assigned_staff_id IS NULL THEN 1 ELSE 0 END) AS missing_staff_assignment
FROM customers_details;

-- invoices table
SELECT 
	  SUM(CASE WHEN customer_id IS NULL THEN 1 ELSE 0 END) AS missing_customers,
      SUM(CASE WHEN staff_id IS NULL THEN 1 ELSE 0 END) AS missing_staff,
      SUM(CASE WHEN invoice_date IS NULL THEN 1 ELSE 0 END) AS missing_dates,
      SUM( CASE WHEN payment_mode IS NULL THEN 1 ELSE 0 END) AS missing_payment_mode,
      SUM( CASE WHEN total_amount_items IS NULL THEN 1 ELSE 0 END) AS null_total_amount_items,
      SUM( CASE WHEN total_tax IS NULL THEN 1 ELSE 0 END) AS null_tax,
      SUM( CASE WHEN discount_amount IS NULL THEN 1 ELSE 0 END) AS mull_discount_amount,
      SUM( CASE WHEN final_bill_amount IS NULL THEN 1 ELSE 0 END) AS final_bill_amount
FROM invoices;

-- prescription table
SELECT 
      SUM( CASE WHEN customer_id IS NULL THEN 1 ELSE 0 END) AS Null_customer_id,
      SUM( CASE WHEN visit_date IS NULL THEN 1 ELSE 0 END) AS Null_visit_dates,
      SUM( CASE WHEN r_sph IS NULL THEN 1 ELSE 0 END) AS null_r_sph,
      SUM( CASE WHEN r_cyl IS NULL THEN 1 ELSE 0 END) AS null_r_cyl,
      SUM( CASE WHEN r_axis IS NULL THEN 1 ELSE 0 END) AS null_r_axix,
      SUM( CASE WHEN l_sph IS NULL THEN 1 ELSE 0 END) AS null_l_sph,
      SUM( CASE WHEN l_cyl IS NULL THEN 1 ELSE 0 END) AS null_l_cyl,
      SUM( CASE WHEN l_axis IS NULL THEN 1 ELSE 0 END) AS null_l_axix,
      SUM( CASE WHEN vision_type IS NULL THEN 1 ELSE 0 END) AS null_vision_type
FROM prescriptions;     

-- additional_customer_details
SELECT 
      SUM( CASE WHEN  date_of_customer_visit IS NULL THEN 1 ELSE 0 END) AS Null_visit_date,
      SUM( CASE WHEN number_of_days_to_deliver_Product IS NULL THEN 1 ELSE 0 END) AS null_delivery_days,
      SUM( CASE WHEN fiter_name IS NULL THEN 1 ELSE 0 END) AS null_fiter_name,
      SUM( CASE WHEN glass_distributor_name IS NULL THEN 1 ELSE 0 END) AS null_glass_distributor_name,
      SUM( CASE WHEN time_spend_by_customer_in_shop IS NULL THEN 1 ELSE 0 END) AS null_time_spend
FROM additional_customer_details;

-- 5) Checking the duplicates in the table

SELECT COUNT(customer_id) AS number_of_duplicates FROM customers_details 
GROUP BY customer_id
HAVING COUNT(customer_id) > 2;

SELECT COUNT(invoice_id) AS number_of_duplicates FROM invoices
GROUP BY invoice_id 
HAVING COUNT(invoice_id) >1;

SELECT COUNT(prescription_id) AS number_of_duplicates FROM prescriptions
GROUP BY prescription_id 
HAVING COUNT(prescription_id) > 1;

SELECT COUNT(staff_id) AS number_of_duplicates FROM staff
GROUP BY staff_id
HAVING COUNT(staff_id)>1;

-- 6) EDA For each table

-- 6.1) EDA for customer_details

SELECT COUNT( DISTINCT customer_id) AS Unique_customers FROM customers_details;

SELECT DISTINCT Age FROM customers_details
ORDER BY Age DESC;

SELECT MAX(Age), MIN(age) FROM customers_details;


SELECT DISTINCT customer_type FROM customers_details;

SELECT COUNT(DISTINCT referred_by_id) AS COUNT_reffered FROM customers_details;

SELECT COUNT(DISTINCT assigned_staff_id) AS COUNT_staff FROM customers_details;


-- 6.2) EDA for prescriptions
SELECT COUNT( DISTINCT prescription_id) AS Unique_prescription FROM prescriptions;

SELECT COUNT(DISTINCT customer_id) AS COUNT_unique_customers FROM prescription;

SELECT MAX(visit_date), MIN(visit_date) FROM prescriptions;

SELECT DISTINCT vision_type FROM prescriptions;

-- 6.3) EDA for invoices

SELECT COUNT( DISTINCT invoice_id) AS Unique_Invoices FROM invoices;

SELECT COUNT(DISTINCT staff_id) FROM invoices;

SELECT MAX(invoice_date), MIN(invoice_date) FROM invoices;

SELECT DISTINCT payment_mode FROM invoices;

SELECT SUM(total_tax) FROM invoices;

SELECT SUM(discount_amount) FROM invoices;

SELECT SUM(final_bill_amount) FROM invoices;

SELECT DISTINCT YEAR(invoice_date) AS Year, SUM(final_bill_amount) FROM invoices
GROUP BY Year;

SELECT DISTINCT YEAR(invoice_date) AS Year, MONTH(invoice_date) AS Month, SUM(final_bill_amount) FROM invoices
GROUP BY Year, month
ORDER BY Year, month;

SELECT DISTINCT payment_mode, SUM(final_bill_amount) FROM invoices
GROUP BY payment_mode
ORDER BY SUM(final_bill_amount) DESC;

-- 6.4) EDA for invoice_items
SELECT COUNT(DISTINCT item_id) AS Unqiue_item FROM invoice_items;

SELECT SUM(quantity) AS Total_Qunatity_sold FROM invoice_items;

SELECT SUM(final_product_price) FROM invoice_items;

