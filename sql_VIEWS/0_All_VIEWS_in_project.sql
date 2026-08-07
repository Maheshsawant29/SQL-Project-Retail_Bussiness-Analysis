-- ================ All Views used in the Project =====================--


-- ================= 1) Repeated Customers View ======================--

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



-- =================== 2) Repeated Customers Churn Analysis ==========================

CREATE VIEW repeated_churn_customers AS 
SELECT 
      rc.customer_id,
      c.customer_full_name,
      c.mobile,
      c.age,
      c.assigned_staff_id,
      DATE(MIN(i.invoice_date)) 
      AS first_visit_date,
      DATEDIFF( (SELECT MAX(invoice_date) FROM invoices), MIN(i.invoice_date))
      AS Number_of_days_customer_associated_with_us,
      DATE(MAX(i.invoice_date)) 
      AS last_visited_date,
      DATEDIFF( (SELECT MAX(invoice_date) FROM invoices), 
      MAX(i.invoice_date)) 
      AS Number_of_days_from_last_visit
FROM repeated_customers as rc
INNER JOIN customers_details as c
ON rc.customer_id=c.customer_id
INNER JOIN invoices as i
ON rc.customer_id=i.customer_id
GROUP BY rc.customer_id
HAVING Number_of_days_from_last_visit > 180
ORDER BY Number_of_days_from_last_visit DESC; 




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



-- =================== 5) Summary Analysis ======================== --


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





