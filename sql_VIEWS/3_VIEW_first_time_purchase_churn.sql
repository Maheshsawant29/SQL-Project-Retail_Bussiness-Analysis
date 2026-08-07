
-- =================== 3) First Time Purchase Churn Customers ================== --

CREATE VIEW non_repeated_churn_customers AS 
WITH customers AS (
SELECT DISTINCT customer_id
FROM customers_details 
),
customer_details AS (
SELECT c.customer_id, cc.age, cc.mobile, 
       cc.customer_type, cc.referred_by_id, 
       cc.assigned_staff_id
FROM customers as c
INNER JOIN customers_details as cc
ON c.customer_id=cc.customer_id
),
customers_with_repeated_customers AS (
SELECT cd.customer_id, rc.customer_id as repeated_customers,
       cd.age, cd.mobile, 
       cd.customer_type, cd.referred_by_id, 
       cd.assigned_staff_id
FROM customer_details as cd
LEFT JOIN repeated_customers as rc
ON cd.customer_id=rc.customer_id
),
-- extracting_the_non_repeated_customers
extracting_the_non_repeated_customers AS (
SELECT cwrc.customer_id, cwrc.repeated_customers,
       cwrc.age, cwrc.mobile, 
       cwrc.customer_type, cwrc.referred_by_id, 
       cwrc.assigned_staff_id
FROM customers_with_repeated_customers  as cwrc
WHERE cwrc.repeated_customers IS NULL
),
buyer_non_repeated_customer_details AS (
SELECT enrc.customer_id, enrc.age, enrc.mobile, 
       enrc.customer_type, enrc.referred_by_id, 
       enrc.assigned_staff_id, i.invoice_id, 
       i.invoice_date, i.total_amount_items,
       i.total_tax,
       i.final_bill_amount
FROM extracting_the_non_repeated_customers  as enrc
INNER JOIN invoices as i
ON enrc.customer_id=i.customer_id
)
SELECT 
       bnrcd.customer_id, bnrcd.age, bnrcd.mobile, 
       bnrcd.customer_type, bnrcd.referred_by_id, 
       bnrcd.assigned_staff_id,
       DATE(MAX(bnrcd.invoice_date)) AS Last_visit_date,
       DATEDIFF( (SELECT MAX(invoice_date) FROM invoices), 
       MAX(bnrcd.invoice_date))
       AS Number_of_days_from_last_visit
FROM buyer_non_repeated_customer_details as bnrcd
GROUP BY  bnrcd.customer_id, bnrcd.age, bnrcd.mobile, 
       bnrcd.customer_type, bnrcd.referred_by_id, 
       bnrcd.assigned_staff_id
HAVING Number_of_days_from_last_visit > 180
ORDER BY Number_of_days_from_last_visit DESC;  



