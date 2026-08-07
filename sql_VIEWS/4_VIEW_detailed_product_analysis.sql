
-- ================= 4) Detailed Product Analysis ================== --

CREATE VIEW Product_Analysis_data AS 
WITH customers AS (
SELECT DISTINCT customer_id
FROM customers_details 
),
customers_detail AS (
SELECT 
       c.customer_id, cd.age, cd.mobile, cd.customer_type,
       cd.assigned_staff_id, cd.referred_by_id
FROM customers as c
INNER JOIN customers_details as cd
ON cd.customer_id=c.customer_id
),
cd_vision AS (
SELECT 
	   cd.customer_id, cd.age, cd.mobile, cd.customer_type,
       cd.assigned_staff_id, cd.referred_by_id,
       p.vision_type
FROM customers_detail as cd
INNER JOIN prescriptions as p
ON p.customer_id=cd.customer_id
),
cdv_staff AS (
SELECT 
       cdv.customer_id, cdv.age, cdv.mobile, cdv.customer_type,
       cdv.assigned_staff_id, cdv.referred_by_id,
       cdv.vision_type, s.staff_full_name
FROM cd_vision as cdv
INNER JOIN staff as s
ON s.staff_id=cdv.assigned_staff_id
),
cdvs_repeated AS (
SELECT 
       cdvs.customer_id, cdvs.age, cdvs.mobile, cdvs.customer_type,
       cdvs.assigned_staff_id, cdvs.referred_by_id,
       cdvs.vision_type, cdvs.staff_full_name,
	   rc.customer_id as repeated_customers
FROM cdv_staff as cdvs
LEFT JOIN repeated_customers as rc
ON rc.customer_id=cdvs.customer_id
),
cdvsr_churn AS (
SELECT 
       cdvsr.customer_id, cdvsr.age, cdvsr.mobile, cdvsr.customer_type,
       cdvsr.assigned_staff_id, cdvsr.referred_by_id,
       cdvsr.vision_type, cdvsr.staff_full_name,
	   cdvsr.repeated_customers,
       rcc.customer_id as repeated_churn_customers
FROM cdvs_repeated as cdvsr
LEFT JOIN repeated_churn_customers as rcc
ON cdvsr.customer_id=rcc.customer_id
),
cdvsrc_top AS (
SELECT 
       cdvsrc.customer_id, cdvsrc.age, cdvsrc.mobile, cdvsrc.customer_type,
       cdvsrc.assigned_staff_id, cdvsrc.referred_by_id,
       cdvsrc.vision_type, cdvsrc.staff_full_name,
	   cdvsrc.repeated_customers,
       cdvsrc.repeated_churn_customers,
       tc.customer_id as top_50_customers
FROM cdvsr_churn as cdvsrc
LEFT JOIN top_50_customers as tc
ON tc.customer_id=cdvsrc.customer_id
),
cdvsrct_invoices AS (
SELECT 
	   cdvsrct.customer_id, cdvsrct.age, cdvsrct.mobile, cdvsrct.customer_type,
       cdvsrct.assigned_staff_id, cdvsrct.referred_by_id,
       cdvsrct.vision_type, cdvsrct.staff_full_name,
	   cdvsrct.repeated_customers,
       cdvsrct.repeated_churn_customers,
       cdvsrct.top_50_customers,
       i.invoice_id
FROM cdvsrc_top as cdvsrct 
INNER JOIN invoices as i
ON i.customer_id=cdvsrct.customer_id
),
cdvsrcti_invoice_items AS (
SELECT 
	   cdvsrcti.customer_id, cdvsrcti.age, cdvsrcti.mobile, cdvsrcti.customer_type,
       cdvsrcti.assigned_staff_id, cdvsrcti.referred_by_id,
       cdvsrcti.vision_type, cdvsrcti.staff_full_name,
	   cdvsrcti.repeated_customers,
       cdvsrcti.repeated_churn_customers,
       cdvsrcti.top_50_customers, 
       cdvsrcti.invoice_id, ii.item_id, ii.product_id, ii.brand_id, ii.product_type_id,
       ii.quantity, ii.final_product_price
FROM cdvsrct_invoices as cdvsrcti
INNER JOIN invoice_items as ii
ON ii.invoice_id=cdvsrcti.invoice_id
)
SELECT 
	   cdvsrctiii.customer_id, cdvsrctiii.age, cdvsrctiii.mobile, cdvsrctiii.customer_type,
       cdvsrctiii.assigned_staff_id, cdvsrctiii.referred_by_id,
       cdvsrctiii.vision_type, cdvsrctiii.staff_full_name,
	   cdvsrctiii.repeated_customers,
       cdvsrctiii.repeated_churn_customers,
       cdvsrctiii.top_50_customers, 
       cdvsrctiii.invoice_id, cdvsrctiii.item_id, 
       cdvsrctiii.product_id, cdvsrctiii.brand_id, 
       cdvsrctiii.product_type_id,
       cdvsrctiii.quantity, cdvsrctiii.final_product_price
FROM cdvsrcti_invoice_items as cdvsrctiii;  







