-- ================================================================= --
-- ================ 6) Customers Churn Analysis ==================== --
-- ================================================================= --

-- 1) Non Repeated Churn Customers / First time buyer Churn Customers

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

-- One time buyer churn customers across age groups 

SELECT 
     CASE 
	 WHEN age < 20 THEN "Teenage_Customer"
     WHEN age BETWEEN 20 AND 30 THEN "20's Customer"
     WHEN age BETWEEN 31 AND 40 THEN "30's Customer"
     WHEN age BETWEEN 41 AND 50 THEN "40's Customer"
     WHEN age BETWEEN 51 AND 60 THEN "50's Customer"
     WHEN age > 60 THEN "Old_Age Customers"
END AS Age_group,
COUNT(DISTINCT customer_id) AS Churn_Customers
FROM non_repeated_churn_customers
GROUP BY Age_group WITH ROLLUP
ORDER BY Churn_Customers DESC;

-- 1) Non Repeated Churn Customers / First time buyer Churn Customers
-- Age group Analysis 
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
buyer_non_repeated_customer_details AS (
SELECT enrc.customer_id, enrc.repeated_customers, enrc.age, enrc.mobile, 
       enrc.customer_type, enrc.referred_by_id, 
       enrc.assigned_staff_id, i.invoice_id, 
       i.invoice_date, i.total_amount_items,
       i.total_tax,
       i.final_bill_amount
FROM customers_with_repeated_customers as enrc
INNER JOIN invoices as i
ON enrc.customer_id=i.customer_id
),
churn_customer AS (
SELECT 
       bnrcd.customer_id, bnrcd.repeated_customers, bnrcd.age, bnrcd.mobile, 
       bnrcd.customer_type, bnrcd.referred_by_id, 
       bnrcd.assigned_staff_id,
       DATE(MAX(bnrcd.invoice_date)) AS Last_visit_date,
       DATEDIFF( (SELECT MAX(invoice_date) FROM invoices), MAX(bnrcd.invoice_date))
       AS Number_of_days_from_last_visit
FROM buyer_non_repeated_customer_details as bnrcd
GROUP BY bnrcd.customer_id, bnrcd.repeated_customers, bnrcd.age, bnrcd.mobile, 
       bnrcd.customer_type, bnrcd.referred_by_id, 
       bnrcd.assigned_staff_id
HAVING  DATEDIFF( (SELECT MAX(invoice_date) FROM invoices), MAX(bnrcd.invoice_date)) > 180
)
SELECT 
	CASE 
	WHEN ccc.age < 20 THEN "Teenage_Customer"
    WHEN ccc.age BETWEEN 20 AND 30 THEN "20's Customer"
    WHEN ccc.age BETWEEN 31 AND 40 THEN "30's Customer"
    WHEN ccc.age BETWEEN 41 AND 50 THEN "40's Customer"
    WHEN ccc.age BETWEEN 51 AND 60 THEN "50's Customer"
    WHEN ccc.age > 60 THEN "Old_Age Customers"
END AS Age_group,
COUNT(DISTINCT ccc.repeated_customers) AS Repeated_Churn_Customers,
COUNT(DISTINCT CASE WHEN ccc.repeated_customers IS NULL THEN ccc.customer_id END) 
AS Non_Repeated_Customers
FROM churn_customer as ccc
GROUP BY Age_group WITH ROLLUP;



-- 2) Non Repeated Churn Customers / First time buyer Churn Customers
-- Vision Type Analysis 
-- 1) Non Repeated Churn Customers / First time buyer Churn Customers
-- Age group Analysis 
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
buyer_non_repeated_customer_details AS (
SELECT enrc.customer_id, enrc.repeated_customers, enrc.age, enrc.mobile, 
       enrc.customer_type, enrc.referred_by_id, 
       enrc.assigned_staff_id, i.invoice_id, 
       i.invoice_date, i.total_amount_items,
       i.total_tax,
       i.final_bill_amount
FROM customers_with_repeated_customers as enrc
INNER JOIN invoices as i
ON enrc.customer_id=i.customer_id
),
churn_customer AS (
SELECT 
       bnrcd.customer_id, bnrcd.repeated_customers, bnrcd.age, bnrcd.mobile, 
       bnrcd.customer_type, bnrcd.referred_by_id, 
       bnrcd.assigned_staff_id,
       DATE(MAX(bnrcd.invoice_date)) AS Last_visit_date,
       DATEDIFF( (SELECT MAX(invoice_date) FROM invoices), MAX(bnrcd.invoice_date))
       AS Number_of_days_from_last_visit
FROM buyer_non_repeated_customer_details as bnrcd
GROUP BY bnrcd.customer_id, bnrcd.repeated_customers, bnrcd.age, bnrcd.mobile, 
       bnrcd.customer_type, bnrcd.referred_by_id, 
       bnrcd.assigned_staff_id
HAVING  DATEDIFF( (SELECT MAX(invoice_date) FROM invoices), MAX(bnrcd.invoice_date)) > 180
)
SELECT p.vision_type,
       COUNT(DISTINCT ccc.repeated_customers) AS Repeated_Churn_Customers,
COUNT(DISTINCT CASE WHEN ccc.repeated_customers IS NULL THEN ccc.customer_id END) AS Non_Repeated_Customers
FROM churn_customer as ccc
INNER JOIN prescriptions as p
ON p.customer_id=ccc.customer_id
GROUP BY p.vision_type WITH ROLLUP;

-- Rate of Churn Customers
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
buyer_non_repeated_customer_details AS (
SELECT enrc.customer_id, enrc.repeated_customers, enrc.age, enrc.mobile, 
       enrc.customer_type, enrc.referred_by_id, 
       enrc.assigned_staff_id, i.invoice_id, 
       i.invoice_date, i.total_amount_items,
       i.total_tax,
       i.final_bill_amount
FROM customers_with_repeated_customers as enrc
INNER JOIN invoices as i
ON enrc.customer_id=i.customer_id
),
churn_customer AS (
SELECT 
       bnrcd.customer_id, bnrcd.repeated_customers, bnrcd.age, bnrcd.mobile, 
       bnrcd.customer_type, bnrcd.referred_by_id, 
       bnrcd.assigned_staff_id,
       DATE(MAX(bnrcd.invoice_date)) AS Last_visit_date,
       DATEDIFF( (SELECT MAX(invoice_date) FROM invoices), MAX(bnrcd.invoice_date))
       AS Number_of_days_from_last_visit
FROM buyer_non_repeated_customer_details as bnrcd
GROUP BY  bnrcd.customer_id, bnrcd.repeated_customers, bnrcd.age, bnrcd.mobile, 
       bnrcd.customer_type, bnrcd.referred_by_id, 
       bnrcd.assigned_staff_id
),
-- First Time Purchase Customers / Non-Repeated Customers Churn Analysis 
final_summary AS (
SELECT 
     'First Time Purchase' AS Churn_Customer_Type,
     
     COUNT(DISTINCT CASE WHEN ccc.repeated_customers IS NULL THEN ccc.customer_id END)
     AS Total_Customers,
     
     ROUND( COUNT(DISTINCT CASE WHEN ccc.repeated_customers IS NULL THEN ccc.customer_id END)*100/
	 COUNT(DISTINCT ccc.customer_id), 2) AS Share_in_Buyers,
     
     COUNT(DISTINCT CASE WHEN ccc.repeated_customers IS NULL 
     AND 
     ccc.Number_of_days_from_last_visit > 180 
     THEN ccc.customer_id END) 
     AS Churn_Customers,
     
     ROUND( COUNT(DISTINCT CASE WHEN ccc.repeated_customers IS NULL 
     AND 
     ccc.Number_of_days_from_last_visit > 180 
     THEN ccc.customer_id END)*100 / 
     COUNT(DISTINCT CASE WHEN ccc.repeated_customers IS NULL THEN ccc.customer_id END), 2) 
     AS Churn_Rate
FROM churn_customer as ccc
UNION ALL
SELECT
	  'Repeated_Customers' AS Churn_Customer_Type,
      
      COUNT(DISTINCT ccc.repeated_customers) 
      AS Total_Customers,
      
      ROUND( COUNT(DISTINCT ccc.repeated_customers)*100/
      COUNT(DISTINCT ccc.customer_id), 2) 
      AS Share_in_Buyers,
      
      COUNT(DISTINCT CASE WHEN ccc.repeated_customers IS NOT NULL 
      AND 
	  ccc.Number_of_days_from_last_visit > 180 
     THEN ccc.customer_id END)
     AS Churn_Customers,
     
     ROUND(  COUNT(DISTINCT CASE WHEN ccc.repeated_customers IS NOT NULL 
      AND 
	  ccc.Number_of_days_from_last_visit > 180 
     THEN ccc.customer_id END)*100/
     COUNT(DISTINCT ccc.repeated_customers), 2) 
     AS Churn_Rate
FROM churn_customer as ccc
)
SELECT * FROM final_summary
UNION ALL 
SELECT 
       'Total' AS Churn_Customer_Type,
       SUM(Total_Customers),
       SUM(Share_in_buyers),
       SUM(Churn_Customers),
       SUM(Churn_rate)
FROM final_summary;

-- Age Group Summary across One Time Buyers v/s Repeated Customers 

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
buyer_non_repeated_customer_details AS (
SELECT enrc.customer_id, enrc.repeated_customers, enrc.age, enrc.mobile, 
       enrc.customer_type, enrc.referred_by_id, 
       enrc.assigned_staff_id, i.invoice_id, 
       i.invoice_date, i.total_amount_items,
       i.total_tax,
       i.final_bill_amount
FROM customers_with_repeated_customers as enrc
INNER JOIN invoices as i
ON enrc.customer_id=i.customer_id
),
churn_customer AS (
SELECT 
       bnrcd.customer_id, bnrcd.repeated_customers, bnrcd.age, bnrcd.mobile, 
       bnrcd.customer_type, bnrcd.referred_by_id, 
       bnrcd.assigned_staff_id,
       DATE(MAX(bnrcd.invoice_date)) AS Last_visit_date,
       DATEDIFF( (SELECT MAX(invoice_date) FROM invoices), MAX(bnrcd.invoice_date))
       AS Number_of_days_from_last_visit
FROM buyer_non_repeated_customer_details as bnrcd
GROUP BY  bnrcd.customer_id, bnrcd.repeated_customers, bnrcd.age, bnrcd.mobile, 
       bnrcd.customer_type, bnrcd.referred_by_id, 
       bnrcd.assigned_staff_id
)
SELECT 
     CASE 
    WHEN ccc.age < 20 THEN "Teenage_Customer"
    WHEN ccc.age BETWEEN 20 AND 30 THEN "20's Customer"
    WHEN ccc.age BETWEEN 31 AND 40 THEN "30's Customer"
    WHEN ccc.age BETWEEN 41 AND 50 THEN "40's Customer"
    WHEN ccc.age BETWEEN 51 AND 60 THEN "50's Customer"
    WHEN ccc.age > 60 THEN "Old_Age Customers"
  END AS Age_group,
     COUNT(DISTINCT CASE WHEN ccc.repeated_customers IS NULL THEN ccc.customer_id END)
     AS First_time_buyers,
     
     COUNT(DISTINCT CASE WHEN ccc.repeated_customers IS NULL 
     AND 
     ccc.Number_of_days_from_last_visit > 180 
     THEN ccc.customer_id END) 
     AS Churn_Customers,
     
     ROUND( COUNT(DISTINCT CASE WHEN ccc.repeated_customers IS NULL 
     AND 
     ccc.Number_of_days_from_last_visit > 180 
     THEN ccc.customer_id END)*100 / 
     COUNT(DISTINCT CASE WHEN ccc.repeated_customers IS NULL THEN ccc.customer_id END), 2) 
     AS Churn_Rate,
     
      COUNT(DISTINCT ccc.repeated_customers) 
      AS repeated_customers,
      
      COUNT(DISTINCT CASE WHEN ccc.repeated_customers IS NOT NULL 
      AND 
	  ccc.Number_of_days_from_last_visit > 180 
     THEN ccc.customer_id END)
     AS Churn_Customers,
     
     ROUND(  COUNT(DISTINCT CASE WHEN ccc.repeated_customers IS NOT NULL 
      AND 
	  ccc.Number_of_days_from_last_visit > 180 
     THEN ccc.customer_id END)*100/
     COUNT(DISTINCT ccc.repeated_customers), 2) 
     AS Churn_Rate
FROM churn_customer as ccc
GROUP BY Age_group WITH ROLLUP;

-- Vision Type across One time buyers and Repeated Customers 

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
buyer_non_repeated_customer_details AS (
SELECT enrc.customer_id, enrc.repeated_customers, enrc.age, enrc.mobile, 
       enrc.customer_type, enrc.referred_by_id, 
       enrc.assigned_staff_id, i.invoice_id, 
       i.invoice_date, i.total_amount_items,
       i.total_tax,
       i.final_bill_amount
FROM customers_with_repeated_customers as enrc
INNER JOIN invoices as i
ON enrc.customer_id=i.customer_id
),
churn_customer AS (
SELECT 
       bnrcd.customer_id, bnrcd.repeated_customers, bnrcd.age, bnrcd.mobile, 
       bnrcd.customer_type, bnrcd.referred_by_id, 
       bnrcd.assigned_staff_id,
       DATE(MAX(bnrcd.invoice_date)) AS Last_visit_date,
       DATEDIFF( (SELECT MAX(invoice_date) FROM invoices), MAX(bnrcd.invoice_date))
       AS Number_of_days_from_last_visit
FROM buyer_non_repeated_customer_details as bnrcd
GROUP BY  bnrcd.customer_id, bnrcd.repeated_customers, bnrcd.age, bnrcd.mobile, 
       bnrcd.customer_type, bnrcd.referred_by_id, 
       bnrcd.assigned_staff_id
)
SELECT 
      p.vision_type,
           COUNT(DISTINCT CASE WHEN ccc.repeated_customers IS NULL THEN ccc.customer_id END)
     AS First_time_buyers,
     
     COUNT(DISTINCT CASE WHEN ccc.repeated_customers IS NULL 
     AND 
     ccc.Number_of_days_from_last_visit > 180 
     THEN ccc.customer_id END) 
     AS Churn_Customers,
     
     ROUND( COUNT(DISTINCT CASE WHEN ccc.repeated_customers IS NULL 
     AND 
     ccc.Number_of_days_from_last_visit > 180 
     THEN ccc.customer_id END)*100 / 
     COUNT(DISTINCT CASE WHEN ccc.repeated_customers IS NULL THEN ccc.customer_id END), 2) 
     AS Churn_Rate,
     
      COUNT(DISTINCT ccc.repeated_customers) 
      AS repeated_customers,
      
      COUNT(DISTINCT CASE WHEN ccc.repeated_customers IS NOT NULL 
      AND 
	  ccc.Number_of_days_from_last_visit > 180 
     THEN ccc.customer_id END)
     AS Churn_Customers,
     
     ROUND(  COUNT(DISTINCT CASE WHEN ccc.repeated_customers IS NOT NULL 
      AND 
	  ccc.Number_of_days_from_last_visit > 180 
     THEN ccc.customer_id END)*100/
     COUNT(DISTINCT ccc.repeated_customers), 2) 
     AS Churn_Rate
FROM churn_customer as ccc
INNER JOIN prescriptions as p
ON p.customer_id=ccc.customer_id
GROUP BY p.vision_type WITH ROLLUP;
      
-- 2) Repeated Customers Churn Analysis 
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

-- 6.1 ) Percentage of Churned Customers out of all the visited customers 

SELECT 
      rc.customer_id,
      c.customer_full_name,
      c.mobile,
      c.age,
      DATE(MAX(i.invoice_date)) AS last_visited_date,
      DATEDIFF( CURDATE(), MAX(i.invoice_date)) 
      AS Number_of_days_from_last_visit
FROM repeated_customers as rc
INNER JOIN customers_details as c
ON rc.customer_id=c.customer_id
INNER JOIN invoices as i
ON rc.customer_id=i.customer_id
GROUP BY rc.customer_id
HAVING Number_of_days_from_last_visit > 180
ORDER BY Number_of_days_from_last_visit DESC;
-- OR 
WITH churning_customers AS (
SELECT 
      rc.customer_id,
      DATE(MAX(i.invoice_date)) AS Last_Visit_Date,
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

-- 6.1.2) Percentage of Churning Customers in the Repeated_Customers 

WITH churning_customers AS (
SELECT 
      rc.customer_id,
      DATEDIFF( (SELECT MAX(invoice_date) FROM invoices ),
      MAX(i.invoice_date)) AS Number_of_days_from_last_visits
FROM repeated_customers as rc
INNER JOIN invoices as i
ON rc.customer_id=i.customer_id
GROUP BY rc.customer_id
HAVING Number_of_days_from_last_visits > 180
ORDER BY Number_of_days_from_last_visits DESC
)
SELECT 
      COUNT( DISTINCT rcc.customer_id) 
      AS Total_Repeated_Customers,
      COUNT( DISTINCT CASE WHEN cc.customer_id IS NOT NULL THEN cc.customer_id END) 
      AS Churning_repeated_customers,
      ROUND( COUNT( DISTINCT CASE WHEN cc.customer_id IS NOT NULL THEN cc.customer_id END)* 100 /
      COUNT( DISTINCT rcc.customer_id), 2) AS Percentage_of_Churn_Customers
FROM repeated_customers as rcc
LEFT JOIN churning_customers as cc
ON cc.customer_id=rcc.customer_id;

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

-- 6.2) How much revenue did these churned customers generate before they stopped visiting 
-- and what is the total revenue the business is at risk of losing permanently?

SELECT 
      SUM(i.final_bill_amount) 
      AS Revenue_from_Churn_Customers,
      ROUND( SUM(i.final_bill_amount)*100/
      (SELECT SUM(final_bill_amount) FROM invoices ), 2) 
      AS Percentage_of_revenue_at_lost
FROM repeated_churn_customers as cc
INNER JOIN invoices as i
ON cc.customer_id=i.customer_id;

-- 6.3) Which age group has the highest number of churned customers 
-- and does a particular generation show a stronger tendency to disengage from the store over time?

SELECT 
      CASE 
      WHEN cc.age < 21 THEN "Teenage_Customers"
      WHEN cc.age BETWEEN 21 AND 30 THEN "20's Customers"
	  WHEN cc.age BETWEEN 31 AND 40 THEN "30's Customers"
      WHEN cc.age BETWEEN 41 AND 50 THEN "40's Customers"
      WHEN cc.age BETWEEN 51 AND 60 THEN "50's Customers"
      WHEN cc.age > 60 THEN "Old_Age_Customers"
   END AS Age_Group,
   COUNT(DISTINCT cc.customer_id) AS COUNT_Customers
FROM repeated_churn_customers  as cc
GROUP BY Age_Group WITH ROLLUP
ORDER BY COUNT_Customers DESC;

-- 6.4) Which churned customers were among our top revenue generators 
-- and who should be prioritized first for re-engagement outreach?

SELECT 
      cc.customer_id, 
      cc.customer_full_name, 
      cc.mobile, cc.age,
      SUM(i.final_bill_amount) 
      AS Revenue
FROM repeated_churn_customers  as cc
INNER JOIN invoices as i
ON cc.customer_id=i.customer_id
GROUP BY cc.customer_id, cc.customer_full_name, 
		 cc.mobile, cc.age
ORDER BY Revenue DESC;

-- 6.5) How many repeated customers are currently in the "At Risk" zone 
-- having not visited in 90 to 180 days and can still be recovered before they churn completely?

WITH at_risk_customers AS (
SELECT 
       i.customer_id,
       DATEDIFF( (SELECT MAX(invoice_date) FROM invoices), 
       MAX(i.invoice_date) ) 
       AS Number_of_days_from_last_visit
FROM invoices as i
GROUP BY i.customer_id
HAVING Number_of_days_from_last_visit BETWEEN 90 AND 180
ORDER BY Number_of_days_from_last_visit DESC
),
at_risk_customers_details AS (
SELECT 
      arc.customer_id, c.customer_full_name, 
      c.mobile, c.age, 
      arc.Number_of_days_from_last_visit
FROM customers_details as c
INNER JOIN at_risk_customers as arc
ON arc.customer_id=c.customer_id
)
SELECT arcd.customer_id, arcd.customer_full_name, 
       arcd.mobile, arcd.age, 
       arcd.Number_of_days_from_last_visit
FROM at_risk_customers_details as arcd;

-- 6.6) What is the average number of days since the last purchase across all churned customers 
-- and how long ago did the business begin losing these customers?
   
SELECT 
      COUNT(DISTINCT cc.customer_id) 
      AS Total_Churned_Customers,
      AVG(cc.Number_of_days_from_last_visit) 
      AS Average_days_since_last_purchase,
      MAX(cc.Number_of_days_from_last_visit) 
      AS Longest_Absence,
      MIN(cc.Number_of_days_from_last_visit) 
      AS Shortest_Absence,
      MIN(cc.last_visited_date) 
      AS Earliest_Churn_date,
      MAX(cc.last_visited_date) 
      AS Most_recent_Churn_date 
FROM repeated_churn_customers as cc;  
   
-- 6.7) Which staff members have the highest number of churned customers under 
-- their assignment and does staff performance play a role in customer retention?

WITH staff_revenue AS (
SELECT 
       i.staff_id, s.staff_full_name, 
       SUM(i.final_bill_amount) AS staff_revenue
FROM invoices as i
INNER JOIN staff as s
ON i.staff_id=s.staff_id
GROUP BY i.staff_id, s.staff_full_name 
ORDER BY staff_revenue DESC
)
SELECT 
       cc.assigned_staff_id, sr.staff_full_name, 
       sr.staff_revenue,
       COUNT(DISTINCT cc.customer_id) 
       AS COUNT_Churn_Customers
FROM repeated_churn_customers as cc
INNER JOIN staff_revenue as sr
ON sr.staff_id=cc.assigned_staff_id
GROUP BY cc.assigned_staff_id, sr.staff_full_name, 
         sr.staff_revenue 
ORDER BY COUNT_Churn_Customers DESC;

-- 6.8) Which vision type is most commonly associated with churned customers
-- and does the type of eye condition influence long term loyalty?

SELECT 
	   p.vision_type, 
       COUNT(DISTINCT cc.customer_id) 
       AS Churn_Customers
FROM repeated_churn_customers  as cc
INNER JOIN prescriptions as p
ON cc.customer_id=p.customer_id
GROUP BY p.vision_type 
ORDER BY Churn_Customers DESC;

-- testing query
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

-- Count of churn customers in the repeated one

WITH CTE AS (
SELECT 
      rc.customer_id as repeated_customers, cc.customer_id as churn_customers
FROM repeated_customers as rc
INNER JOIN repeated_churn_customers  as cc
ON rc.customer_id=cc.customer_id
)
SELECT COUNT(*) FROM CTE;

SELECT COUNT(*) FROM churn_customers;


--  =============== END OF Churn Customer Analysis -- ===================== --