-- =========================================================
-- =========  Referrers Analysis ============== 
-- =========================================================

-- Extracted the Referrers
SELECT DISTINCT c.referred_by_id FROM customers_details as c
WHERE c.referred_by_id IS NOT NULL;

-- COUNT of Referrers = 721 Referrers are their in our dataset;
-- out of 721 some are our buyers 
-- and interestingly there are Non_buyers too who gave our referral
SELECT COUNT(DISTINCT c.referred_by_id) 
AS COUNT_Referring_Person FROM customers_details as c
WHERE c.referred_by_id IS NOT NULL;

-- Number of referrals given by each Referrer = 
SELECT 
      c.referred_by_id, 
	 COUNT(DISTINCT c.customer_id) AS Number_of_Referrals
FROM customers_details as c
GROUP BY c.referred_by_id 
HAVING c.referred_by_id IS NOT NULL 
ORDER BY Number_of_Referrals DESC;

-- COUNT of Customers Visited by referrals = 810 Customers 
-- Out of 8000 Visited Customers 7190 Customers are Non-referral Customers
-- It means 8000-7190 = 810 Customers are our referrals Customers
-- Out of 8000 Visited Customers 810 Customers are our Referral Customers

SELECT
	  COUNT(DISTINCT c.customer_id) 
      AS COUNT_of_Referral_customer
FROM customers_details as c
WHERE c.referred_by_id IS NOT NULL;

-- % wise referral customers in the visited customers
SELECT
      COUNT(DISTINCT c.customer_id) AS Total_Visited_Customers,
      COUNT(DISTINCT CASE WHEN c.referred_by_id IS NULL THEN c.customer_id END) 
      AS Non_referral_Customers,
	  COUNT(DISTINCT CASE WHEN c.referred_by_id IS NOT NULL THEN c.customer_id END) 
      AS Referral_Customers,
      ROUND( COUNT(DISTINCT CASE WHEN c.referred_by_id IS NOT NULL THEN c.customer_id END) * 100 /
      COUNT(DISTINCT c.customer_id), 2) 
      AS Percentage_of_referraL_Customers_in_total_visited_customers
FROM customers_details as c;

-- Out of all the 810 referral customer, how much are buyers 
WITH referred_details AS (
SELECT 
      c.referred_by_id, c.customer_id, 
      i.customer_id as buyers, i.final_bill_amount
FROM customers_details as c
LEFT JOIN invoices as i
ON c.customer_id=i.customer_id
WHERE c.referred_by_id IS NOT NULL
)
SELECT 
      COUNT( DISTINCT rd.customer_id) AS Total_Visited_Referral_Customers,
      COUNT(DISTINCT rd.buyers) AS referral_buyers,
      ROUND( COUNT(DISTINCT rd.buyers) * 100 /
	  COUNT( DISTINCT rd.customer_id), 2)
      AS Referral_Conversion_rate 
FROM referred_details as rd;

-- Percentage of buyer referral customers out of the buyer customers
-- 10.24% customers are referral customers out of 3721 buyer customers
SELECT 
      COUNT( DISTINCT c.customer_id ) AS Visited_Customers,
      COUNT(DISTINCT i.customer_id) AS Buyer_Customers,
      COUNT( DISTINCT CASE WHEN c.referred_by_id IS NOT NULL 
      AND
      i.customer_id IS NOT NULL THEN i.customer_id END) AS Buyer_referrals,
      
      ROUND( COUNT( DISTINCT CASE WHEN c.referred_by_id IS NOT NULL 
      AND
      i.customer_id IS NOT NULL THEN i.customer_id END) * 100 / 
      COUNT( DISTINCT i.customer_id ), 2) AS Percentage_of_referral_customers_in_buyers,
      
      ROUND( (COUNT( DISTINCT CASE WHEN c.referred_by_id IS NOT NULL
      AND
      i.customer_id IS NOT NULL THEN i.customer_id END))*100/ 
      COUNT( DISTINCT c.customer_id ), 2) 
      AS Referral_Conversion_Rate
FROM customers_details as c
LEFT JOIN invoices as i
ON c.customer_id=i.customer_id;

-- Final Summary of Referers, Referral_buyers and Comparison of their Revenue and Percentage 
SELECT 
      SUM(i.final_bill_amount) AS Total_Revenue_Generated,
      SUM(CASE WHEN c.referred_by_id IS NULL THEN i.final_bill_amount ELSE 0 END) 
      AS Revenue_Genertaed_by_Non_Referrals,
      SUM(CASE WHEN c.referred_by_id IS NOT NULL THEN i.final_bill_amount ELSE 0 END) 
      AS Revenue_Generated_by_Referrals,
      ROUND( SUM(CASE WHEN c.referred_by_id IS NOT NULL THEN i.final_bill_amount ELSE 0 END) * 100 / 
      SUM(i.final_bill_amount), 2) 
      AS Percentage_Contribution_of_Referrals_in_Revenue
FROM customers_details as c
INNER JOIN invoices as i
ON c.customer_id=i.customer_id;

-- Top Referrers (Who has given more than 2 Referrals buyers)
WITH buyer_referrals AS (
SELECT 
       c.referred_by_id, c.customer_id, 
       i.customer_id AS buyers
FROM customers_details as c
INNER JOIN invoices as i
ON c.customer_id=i.customer_id
WHERE c.referred_by_id IS NOT NULL
)
SELECT 
      br.referred_by_id, 
      COUNT( DISTINCT br.customer_id) AS Buyer_referrals
FROM buyer_referrals as br
GROUP BY br.referred_by_id
HAVING Buyer_referrals > 2;

-- Referrer_Age_group 
WITH referrers AS (
SELECT
      c.referred_by_id
FROM customers_details as c
GROUP BY c.referred_by_id      
)
SELECT
CASE 
    WHEN c.age < 20 THEN "Teenage_Customer"
    WHEN c.age BETWEEN 20 AND 30 THEN "20's Customer"
    WHEN c.age BETWEEN 31 AND 40 THEN "30's Customer"
    WHEN c.age BETWEEN 41 AND 50 THEN "40's Customer"
    WHEN c.age BETWEEN 51 AND 60 THEN "50's Customer"
    WHEN c.age > 60 THEN "Old_Age Customers (age>60)"
  END AS Referrer_Age_group,
COUNT(DISTINCT referrers.referred_by_id ) AS COUNT_Referrals
FROM customers_details as c  
INNER JOIN referrers
ON referrers.referred_by_id=c.customer_id
GROUP BY Referrer_Age_group 
ORDER BY COUNT_Referrals DESC;
-- OR --
SELECT 
CASE 
    WHEN c.age < 20 THEN "Teenage_Customer"
    WHEN c.age BETWEEN 20 AND 30 THEN "20's Customer"
    WHEN c.age BETWEEN 31 AND 40 THEN "30's Customer"
    WHEN c.age BETWEEN 41 AND 50 THEN "40's Customer"
    WHEN c.age BETWEEN 51 AND 60 THEN "50's Customer"
    WHEN c.age > 60 THEN "Old_Age Customers (age>60)"
  END AS Referrer_Age_group,
COUNT(DISTINCT referrers.referred_by_id) AS COUNT_Unique_Referrers
FROM customers_details as c
INNER JOIN customers_details as referrers
ON referrers.referred_by_id=c.customer_id
GROUP BY Referrer_Age_group WITH ROLLUP
ORDER BY COUNT_Unique_Referrers DESC;

-- age group of referral customers 
SELECT 
	COUNT( DISTINCT c.customer_id) AS Count_Referral_Customers,
	CASE 
    WHEN c.age < 20 THEN "Teenage_Customer"
    WHEN c.age BETWEEN 20 AND 30 THEN "20's Customer"
    WHEN c.age BETWEEN 31 AND 40 THEN "30's Customer"
    WHEN c.age BETWEEN 41 AND 50 THEN "40's Customer"
    WHEN c.age BETWEEN 51 AND 60 THEN "50's Customer"
    WHEN c.age > 60 THEN "Old_Age Customers (age>60)"
  END AS Age_group
FROM customers_details as c
WHERE c.referred_by_id IS NOT NULL
GROUP BY Age_group WITH ROLLUP;

--  Summary of Referrals
-- 810 Visited referrals ---> 381 become buyers ----> 113 Stayed loyal and repeated
WITH unique_buyers AS (
SELECT DISTINCT i.customer_id 
FROM invoices as i
)
SELECT 
      COUNT(DISTINCT c.customer_id) AS Visited_referral_customers,
      COUNT( DISTINCT ub.customer_id) AS Buyer_Customers,
      COUNT(DISTINCT CASE WHEN rc.customer_id IS NOT NULL THEN c.customer_id END) 
      AS Loyal_Referral_repeated_Customers,
      ROUND( COUNT(DISTINCT CASE WHEN rc.customer_id IS NOT NULL THEN c.customer_id END) * 100/
      COUNT(DISTINCT ub.customer_id), 2) AS Referral_Retention_rate
FROM customers_details as c
LEFT JOIN repeated_customers as rc
ON rc.customer_id=c.customer_id
LEFT JOIN unique_buyers as ub
ON ub.customer_id=c.customer_id
WHERE c.referred_by_id IS NOT NULL;

-- 2.6.13) Regular Customers v/s Referral Customers 
SELECT 
      'Regular_Customers' AS Type_Customers,
      COUNT(DISTINCT c.customer_id) AS Visited_Customers,
      COUNT(DISTINCT i.customer_id) AS Buyer_Customers,
      ROUND( COUNT(DISTINCT i.customer_id) * 100 /
	  COUNT(DISTINCT c.customer_id), 2) AS Conversion_rate_of_non_referral_customers,
      
      COUNT( DISTINCT rc.customer_id) AS Repeated_Customers,
      ROUND( COUNT( DISTINCT rc.customer_id) *100 /
      COUNT(DISTINCT i.customer_id), 2) AS Retention_rate,
      
      ROUND(AVG(i.final_bill_amount), 2) AS Average_Revenue_per_invoice
FROM customers_details as c
LEFT JOIN invoices as i
On c.customer_id=i.customer_id
LEFT JOIN repeated_customers as rc
ON rc.customer_id=c.customer_id
WHERE c.referred_by_id IS NULL
UNION ALL
SELECT
      'Referral_Customers',
      COUNT(DISTINCT c.customer_id) AS Visited_Customers,
      COUNT(DISTINCT i.customer_id) AS Buyer_Customers,
      ROUND( COUNT(DISTINCT i.customer_id) * 100 /
	  COUNT(DISTINCT c.customer_id), 2) AS Conversion_rate_of_non_referral_customers,
      
      COUNT(DISTINCT rc.customer_id) AS Repeated_referral_customers,
      ROUND( COUNT(DISTINCT rc.customer_id)*100/ COUNT(DISTINCT i.customer_id), 2)
      AS Retention_rate,
      
      ROUND(AVG(i.final_bill_amount), 2) AS Average_Revenue_per_invoice
      
FROM customers_details as c
LEFT JOIN invoices as i
On c.customer_id=i.customer_id
LEFT JOIN repeated_customers as rc
ON rc.customer_id=c.customer_id
WHERE c.referred_by_id IS NOT NULL;
      

-- ============= Quick Sort summary on Buyer and Non Buyer referrers =========== --

WITH referrers AS (
SELECT DISTINCT c.referred_by_id
FROM customers_details as c
WHERE c.referred_by_id IS NOT NULL
),
unique_customer_with_invoices AS (
SELECT DISTINCT ii.customer_id
FROM invoices as ii
),
buyer_referrers AS (
SELECT r.referred_by_id as buyer_referrers_id
FROM referrers as r
INNER JOIN unique_customer_with_invoices as ucwi
ON r.referred_by_id=ucwi.customer_id
),
buyer_referrers_referrals AS (
SELECT 
       br.buyer_referrers_id,
       c.customer_id as all_customer_id
FROM buyer_referrers as br
INNER JOIN customers_details as c
ON buyer_referrers_id=c.referred_by_id
),
buyer_referrers_referrals_analysis AS (
SELECT 
      brr.buyer_referrers_id,
	  brr.all_customer_id, 
      i.customer_id AS buyer_referrals_id,
      i.final_bill_amount
FROM buyer_referrers_referrals as brr
LEFT JOIN invoices as i
ON brr.all_customer_id=i.customer_id
),
buyer_referrers_referrals_analysis_repeated_referrals AS (
SELECT 
      brra.buyer_referrers_id,
	  brra.all_customer_id, 
      brra.buyer_referrals_id,
      brra.final_bill_amount,
      rc.customer_id AS repeated_customer_id
FROM buyer_referrers_referrals_analysis as brra
LEFT JOIN repeated_customers as rc
On rc.customer_id=brra.all_customer_id
),
-- Non Buyer_referrers_CTE
non_buyer_referrers AS (
SELECT r.referred_by_id as non_buyer_referrers_id
FROM referrers as r
LEFT JOIN unique_customer_with_invoices as ucwi 
ON r.referred_by_id=ucwi.customer_id
WHERE ucwi.customer_id IS NULL
),
non_buyer_referrers_referrals AS (
SELECT nbr.non_buyer_referrers_id, 
       c.customer_id as all_visited_customers
FROM customers_details as c
INNER JOIN non_buyer_referrers as nbr
ON nbr.non_buyer_referrers_id=c.referred_by_id
),
non_buyer_referrers_buyer_referrals AS (
SELECT nbrr.non_buyer_referrers_id,
       nbrr.all_visited_customers AS all_visited_customers_referral_from_non_buyer_referrers,
       i.customer_id as Buyer_referral_from_non_buyer_referrers,
       i.final_bill_amount
FROM non_buyer_referrers_referrals as nbrr
LEFT JOIN invoices as i
ON nbrr.all_visited_customers=i.customer_id
),
non_buyer_referrers_buyer_repeated_referrals AS (
SELECT 
      nbrbr.non_buyer_referrers_id,
	  nbrbr.all_visited_customers_referral_from_non_buyer_referrers,
	  nbrbr.Buyer_referral_from_non_buyer_referrers as Buyer_referral_from_non_buyer_referrers,
	  nbrbr.final_bill_amount,
      rcc.customer_id as repeated_buyer_referral_from_non_buyer_referrers
FROM non_buyer_referrers_buyer_referrals as nbrbr
LEFT JOIN repeated_customers as rcc
ON rcc.customer_id=nbrbr.all_visited_customers_referral_from_non_buyer_referrers
)
SELECT 
      'Buyer_Referrers' AS Type_of_Referrers,
      COUNT(DISTINCT brrarr.buyer_referrers_id) AS Buyer_Referrers,
      COUNT(DISTINCT brrarr.all_customer_id) AS Total_Referral_given,
      COUNT(DISTINCT brrarr.buyer_referrals_id) AS Buyer_Referrals,
      ROUND( COUNT(DISTINCT brrarr.buyer_referrals_id)*100/
      COUNT(DISTINCT brrarr.all_customer_id), 2)
      AS Referrals_Conversion_Rate,
      COUNT(DISTINCT brrarr.repeated_customer_id) AS Repeated_referrals,
      ROUND( COUNT(DISTINCT brrarr.repeated_customer_id)*100/
	  COUNT(DISTINCT brrarr.buyer_referrals_id), 2) AS Referrals_retention_rate,
      SUM(brrarr.final_bill_amount) AS Revenue_from_referrals,
      ROUND( SUM(brrarr.final_bill_amount)*100/46811413, 2) AS Contribution_in_Revenue
FROM buyer_referrers_referrals_analysis_repeated_referrals as brrarr
UNION ALL
SELECT 
      'Non_Buyer_Referrers',
      COUNT( DISTINCT nbrbrr.non_buyer_referrers_id) AS Non_Buyer_Referrers,
      COUNT( DISTINCT nbrbrr.all_visited_customers_referral_from_non_buyer_referrers)
      AS Total_Referral_given,
      COUNT(DISTINCT Buyer_referral_from_non_buyer_referrers)
      AS Buyer_Referrals,
      ROUND( COUNT(DISTINCT Buyer_referral_from_non_buyer_referrers)*100/
      COUNT( DISTINCT nbrbrr.all_visited_customers_referral_from_non_buyer_referrers), 2)
      AS Referrals_Conversion_Rate,
      COUNT(DISTINCT nbrbrr.repeated_buyer_referral_from_non_buyer_referrers),
      ROUND( COUNT(DISTINCT nbrbrr.repeated_buyer_referral_from_non_buyer_referrers)*100/
      COUNT(DISTINCT Buyer_referral_from_non_buyer_referrers), 2) 
      AS Referrals_retention_rate,
      SUM( nbrbrr.final_bill_amount) AS Revenue_from_referrals,
      ROUND( SUM( nbrbrr.final_bill_amount)*100/ 46811413, 2) AS Contribution_in_Revenue 
FROM non_buyer_referrers_buyer_repeated_referrals as nbrbrr;


-- ==================== END OF Referrer Analysis ===================== --
