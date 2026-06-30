-- 6) Customers Churn Analysis 
CREATE VIEW churn_customers AS 
SELECT 
      rc.customer_id,
      c.customer_full_name,
      c.mobile,
      c.age,
      c.assigned_staff_id,
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
FROM churn_customers as cc
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
FROM churn_customers as cc
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
FROM churn_customers as cc
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
FROM churn_customers as cc;  
   
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
FROM churn_customers as cc
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
FROM churn_customers as cc
INNER JOIN prescriptions as p
ON cc.customer_id=p.customer_id
GROUP BY p.vision_type 
ORDER BY Churn_Customers DESC;
