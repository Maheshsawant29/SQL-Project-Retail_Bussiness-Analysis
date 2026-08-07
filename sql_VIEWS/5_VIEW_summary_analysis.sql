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