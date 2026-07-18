-- =========================================================
-- =========  Referrers Analysis ============== 
-- =========================================================

-- Extracted the Referrers
SELECT DISTINCT c.referred_by_id FROM customers_details as c
WHERE c.referred_by_id IS NOT NULL;

-- COUNT of Referrers = 721 Referrers are their in our dataset;
-- out of 721 some are our buyers 
-- and interestingly there are Non_buyers too who gave our referral
-- summary of referrers and referrals  

WITH unique_referrers AS (
SELECT DISTINCT c.referred_by_id 
FROM customers_details as c
),
unique_referrers_referrals AS (
SELECT ur.referred_by_id, c.customer_id as all_customers_id
FROM customers_details as c
INNER JOIN unique_referrers as ur
ON ur.referred_by_id=c.referred_by_id
),
ur_referral_buyers AS (
SELECT urr.referred_by_id, urr.all_customers_id,
       i.customer_id as buyer_customer_id,
       i.final_bill_amount
FROM unique_referrers_referrals as urr
LEFT JOIN invoices as i
ON urr.all_customers_id=i.customer_id
),
urrb_repeated_referrals AS (
SELECT
       urrb.referred_by_id,  
	   urrb.all_customers_id,
       urrb.buyer_customer_id,
       urrb.final_bill_amount,
       rc.customer_id as repeated_customers_id
FROM ur_referral_buyers as urrb
LEFT JOIN repeated_customers as rc
ON rc.customer_id=urrb.all_customers_id
)
SELECT 
       '8000' AS Total_Visited_Customers,
       COUNT(DISTINCT urrbrr.referred_by_id) 
       AS Total_Referrers,
       ROUND( COUNT(DISTINCT urrbrr.referred_by_id)*100/
       (SELECT COUNT(DISTINCT customer_id) FROM customers_details), 2)
       AS Percentage_of_referrers,
       COUNT(DISTINCT urrbrr.all_customers_id) 
       AS Total_Referrals,
       COUNT(DISTINCT urrbrr.buyer_customer_id) 
       AS Buyer_referrals,
       ROUND( COUNT(DISTINCT urrbrr.buyer_customer_id)*100/
       COUNT(DISTINCT urrbrr.all_customers_id), 2) 
       AS Referral_Conversion_rate,
       SUM(urrbrr.final_bill_amount) 
       AS Revenue_from_referrals,
       ROUND( SUM(urrbrr.final_bill_amount)*100/
       (SELECT SUM(final_bill_amount) FROM invoices), 2)
       AS Contribution_of_referrals_in_Revenue,
       COUNT(DISTINCT urrbrr.repeated_customers_id) 
       AS Repeated_Referral,
       ROUND(COUNT(DISTINCT urrbrr.repeated_customers_id)*100/
       COUNT(DISTINCT urrbrr.buyer_customer_id), 2)
       AS Referral_Retention_Rate
FROM urrb_repeated_referrals as urrbrr;


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
-- % wise referral customers in the visited customers
SELECT
      COUNT(DISTINCT c.customer_id) 
      AS Total_Visited_Customers,
      COUNT(DISTINCT CASE WHEN c.referred_by_id IS NOT NULL THEN c.customer_id END) 
      AS Referral_Customers,
      ROUND( COUNT(DISTINCT CASE WHEN c.referred_by_id IS NOT NULL THEN c.customer_id END) * 100 /
      COUNT(DISTINCT c.customer_id), 2) 
      AS Percentage_of_referraL_Customers_in_total_visited_customers
FROM customers_details as c;

-- Percentage of buyer referral customers out of the buyer customers
-- 10.24% customers are referral customers out of 3721 buyer customers
SELECT 
   COUNT( DISTINCT c.customer_id ) AS Visited_Customers,
   COUNT(DISTINCT c.referred_by_id) AS Referrers_Customers,
   ROUND( COUNT(DISTINCT c.referred_by_id)*100/
    COUNT( DISTINCT c.customer_id ), 2) AS Percetage_of_Referrers_Customers,   
   COUNT(DISTINCT i.customer_id) AS Buyer_Customers,
   COUNT( DISTINCT CASE WHEN c.referred_by_id IS NOT NULL 
   AND
   i.customer_id IS NOT NULL THEN i.customer_id END) 
   AS Buyer_referrals,
   ROUND( COUNT( DISTINCT CASE WHEN c.referred_by_id IS NOT NULL 
   AND
   i.customer_id IS NOT NULL THEN i.customer_id END) * 100 / 
   COUNT( DISTINCT i.customer_id ), 2) 
   AS Percentage_of_referral_customers_in_buyers,
   ROUND( (COUNT( DISTINCT CASE WHEN c.referred_by_id IS NOT NULL
   AND
   i.customer_id IS NOT NULL THEN i.customer_id END))*100/ 
   COUNT( DISTINCT c.customer_id ), 2) 
   AS Referral_Conversion_Rate
FROM customers_details as c
LEFT JOIN invoices as i
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

-- Referrer_Age_group Pipeline
WITH referrers AS (
SELECT
      DISTINCT c.referred_by_id
FROM customers_details as c    
),
referrers_age AS (
SELECT 
      r.referred_by_id, cc.age
FROM referrers as r
INNER JOIN customers_details as cc
ON r.referred_by_id=cc.customer_id
),
referrers_referrals AS (
SELECT 
      ra.referred_by_id, ra.age, ccc.customer_id as referrals_id
FROM referrers_age as ra
INNER JOIN customers_details as ccc
ON ccc.referred_by_id=ra.referred_by_id
),
rr_buyer_referrals AS (
SELECT 
      rr.referred_by_id, rr.age, rr.referrals_id, 
	  i.customer_id AS buyer_referral_id,
      i.final_bill_amount
FROM referrers_referrals as rr
LEFT JOIN invoices as i
ON i.customer_id=rr.referrals_id
),
rrbr_repeated AS (
SELECT 
      rrbr.referred_by_id, rrbr.age, rrbr.referrals_id, 
	  rrbr.buyer_referral_id, rc.customer_id as repeated_referrals,
      rrbr.final_bill_amount
FROM rr_buyer_referrals as rrbr
LEFT JOIN repeated_customers as rc
ON rc.customer_id=rrbr.referrals_id
)
SELECT 
	CASE 
    WHEN rrbrr.age < 20 THEN "Teenage_Customer"
    WHEN rrbrr.age BETWEEN 20 AND 30 THEN "20's Customer"
    WHEN rrbrr.age BETWEEN 31 AND 40 THEN "30's Customer"
    WHEN rrbrr.age BETWEEN 41 AND 50 THEN "40's Customer"
    WHEN rrbrr.age BETWEEN 51 AND 60 THEN "50's Customer"
    WHEN rrbrr.age > 60 THEN "Old_Age Customers (age>60)"
  END AS Referrers_Age_group,
COUNT(DISTINCT rrbrr.referred_by_id ) AS COUNT_Referrers,
COUNT(DISTINCT rrbrr.referrals_id) AS Referrals,
ROUND(COUNT(DISTINCT rrbrr.referrals_id)/COUNT(DISTINCT rrbrr.referred_by_id ), 2)
AS Rate_of_Referrals,
COUNT(DISTINCT rrbrr.buyer_referral_id) AS Buyer_Referrals,
ROUND( COUNT(DISTINCT rrbrr.buyer_referral_id)*100/
COUNT(DISTINCT rrbrr.referrals_id), 2) AS Referral_Buyer_Rate,
COUNT(DISTINCT rrbrr.repeated_referrals) AS Retain_Buyer_Referrals,
ROUND( COUNT(DISTINCT rrbrr.repeated_referrals)*100/
COUNT(DISTINCT rrbrr.buyer_referral_id), 2) AS Buyer_Referrals_Retention_Rate,
SUM(rrbrr.final_bill_amount) AS Revenue_Collected
FROM rrbr_repeated as rrbrr
GROUP BY Referrers_Age_group WITH ROLLUP;

-- age group of referral customers 
SELECT 
	CASE 
    WHEN c.age < 20 THEN "Teenage_Customer"
    WHEN c.age BETWEEN 20 AND 30 THEN "20's Customer"
    WHEN c.age BETWEEN 31 AND 40 THEN "30's Customer"
    WHEN c.age BETWEEN 41 AND 50 THEN "40's Customer"
    WHEN c.age BETWEEN 51 AND 60 THEN "50's Customer"
    WHEN c.age > 60 THEN "Old_Age Customers (age>60)"
  END AS Age_group_Referrals,
	COUNT(DISTINCT c.customer_id) 
    AS Count_Referral_Customers,
    COUNT(DISTINCT i.customer_id) 
    AS Buyer_Referrals,
    ROUND( COUNT(DISTINCT i.customer_id)*100/
    COUNT(DISTINCT c.customer_id), 2) 
    AS Referral_Conversion_Rate,
    COUNT(DISTINCT rc.customer_id) AS repeated_referrals,
    ROUND( COUNT(DISTINCT rc.customer_id)*100/
    COUNT(DISTINCT i.customer_id), 2) AS Referrals_Retention_Rate,
    SUM(i.final_bill_amount) AS Revenue_Collected
FROM customers_details as c
LEFT JOIN invoices as i
ON c.customer_id=i.customer_id
LEFT JOIN repeated_customers as rc
ON rc.customer_id=c.customer_id
WHERE c.referred_by_id IS NOT NULL
GROUP BY Age_group_Referrals WITH ROLLUP;

-- which age groups does the diferrent age groups referrers refers

-- The Referral Network Matrix: Who Refers Whom?
WITH referrers AS (
SELECT
      DISTINCT c.referred_by_id
FROM customers_details as c    
),
referrers_age AS (
SELECT 
      r.referred_by_id, cc.age
FROM referrers as r
INNER JOIN customers_details as cc
ON r.referred_by_id=cc.customer_id
),
referrers_referrals AS (
SELECT 
      ra.referred_by_id, ra.age, ccc.customer_id as referrals_id,
      ccc.age as referrals_age
FROM referrers_age as ra
INNER JOIN customers_details as ccc
ON ccc.referred_by_id=ra.referred_by_id
)
SELECT 
      CASE 
    WHEN rr.age < 20 THEN "Teenage_Customer"
    WHEN rr.age BETWEEN 20 AND 30 THEN "20's Customer"
    WHEN rr.age BETWEEN 31 AND 40 THEN "30's Customer"
    WHEN rr.age BETWEEN 41 AND 50 THEN "40's Customer"
    WHEN rr.age BETWEEN 51 AND 60 THEN "50's Customer"
    WHEN rr.age > 60 THEN "Old_Age Customers (age>60)"
  END AS Referrers_Age_group,
COUNT( CASE WHEN rr.referrals_age <20 THEN rr.referrals_id END) AS Teenage_Customers,
COUNT( CASE WHEN rr.referrals_age BETWEEN 20 AND 30 THEN rr.referrals_id END) AS 20s_Customers,
COUNT( CASE WHEN rr.referrals_age BETWEEN 31 AND 40 THEN rr.referrals_id END) AS 30s_Customers,      
COUNT( CASE WHEN rr.referrals_age BETWEEN 41 AND 50 THEN rr.referrals_id END) AS 40s_Customers,
COUNT( CASE WHEN rr.referrals_age BETWEEN 51 AND 60 THEN rr.referrals_id END) AS 50s_Customers,
COUNT( CASE WHEN rr.referrals_age >60 THEN rr.referrals_id END) AS Old_Age_Customers
FROM referrers_referrals as rr
GROUP BY Referrers_Age_group WITH ROLLUP;


-- 2.6.13) Comparison of Regular Customers v/s Referral Customers 
SELECT 
   'Regular_Customers' AS Type_Customers,
    COUNT(DISTINCT c.customer_id) AS Visited_Customers,
	COUNT(DISTINCT i.customer_id) AS Buyer_Customers,
	ROUND( COUNT(DISTINCT i.customer_id) * 100 /
	COUNT(DISTINCT c.customer_id), 2) 
    AS Conversion_rate_of_non_referral_customers,
	COUNT( DISTINCT rc.customer_id) AS Repeated_Customers,
	ROUND( COUNT( DISTINCT rc.customer_id) *100 /
	COUNT(DISTINCT i.customer_id), 2) AS Retention_rate,
	ROUND(AVG(i.final_bill_amount), 2) 
    AS Average_Revenue_per_invoice
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
	COUNT(DISTINCT c.customer_id), 2) 
    AS Conversion_rate_of_non_referral_customers,
    COUNT(DISTINCT rc.customer_id) AS Repeated_referral_customers,
	ROUND( COUNT(DISTINCT rc.customer_id)*100/ 
    COUNT(DISTINCT i.customer_id), 2)
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
SELECT br.buyer_referrers_id, c.customer_id as all_customer_id 
FROM buyer_referrers as br 
INNER JOIN customers_details as c 
ON buyer_referrers_id=c.referred_by_id 
), 
buyer_referrers_referrals_analysis AS ( 
SELECT 
      brr.buyer_referrers_id, 
      brr.all_customer_id, 
      i.customer_id AS buyer_referrals_id, 
      i.final_bill_amount FROM buyer_referrers_referrals as brr 
      LEFT JOIN invoices as i ON brr.all_customer_id=i.customer_id 
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
    nbrbr.final_bill_amount, rcc.customer_id as repeated_buyer_referral_from_non_buyer_referrers 
    FROM non_buyer_referrers_buyer_referrals as nbrbr 
    LEFT JOIN repeated_customers as rcc 
    ON rcc.customer_id=nbrbr.all_visited_customers_referral_from_non_buyer_referrers 
),
final_summary AS ( 
SELECT 'Buyer_Referrers' AS Type_of_Referrers, 
        COUNT(DISTINCT brrarr.buyer_referrers_id) AS Buyer_Referrers, 
        COUNT(DISTINCT brrarr.all_customer_id) AS Total_Referral_given, 
        ROUND(COUNT(DISTINCT brrarr.all_customer_id)/
        COUNT(DISTINCT brrarr.buyer_referrers_id), 2) AS Referrals_Rate,
        COUNT(DISTINCT brrarr.buyer_referrals_id) AS Buyer_Referrals, 
        ROUND( COUNT(DISTINCT brrarr.buyer_referrals_id)*100/ 
        COUNT(DISTINCT brrarr.all_customer_id), 2) 
        AS Referrals_Conversion_Rate, 
        COUNT(DISTINCT brrarr.repeated_customer_id) 
        AS Repeated_referrals, 
        ROUND( COUNT(DISTINCT brrarr.repeated_customer_id)*100/ 
        COUNT(DISTINCT brrarr.buyer_referrals_id), 2) 
        AS Referrals_retention_rate, 
        SUM(brrarr.final_bill_amount) AS Revenue_from_referrals, 
        ROUND( SUM(brrarr.final_bill_amount)*100/ (SELECT SUM(final_bill_amount) FROM invoices), 2) 
        AS Contribution_in_Revenue 
FROM buyer_referrers_referrals_analysis_repeated_referrals as brrarr 
UNION ALL 
SELECT 'Non_Buyer_Referrers', 
        COUNT( DISTINCT nbrbrr.non_buyer_referrers_id) 
        AS Non_Buyer_Referrers, 
        COUNT( DISTINCT nbrbrr.all_visited_customers_referral_from_non_buyer_referrers) 
        AS Total_Referral_given, 
        ROUND( COUNT( DISTINCT nbrbrr.all_visited_customers_referral_from_non_buyer_referrers)/
        COUNT( DISTINCT nbrbrr.non_buyer_referrers_id), 2) AS Referrals_Rate,
        COUNT(DISTINCT Buyer_referral_from_non_buyer_referrers) 
        AS Buyer_Referrals, 
        ROUND( COUNT(DISTINCT Buyer_referral_from_non_buyer_referrers)*100/ 
        COUNT( DISTINCT nbrbrr.all_visited_customers_referral_from_non_buyer_referrers), 2) 
        AS Referrals_Conversion_Rate, 
        COUNT(DISTINCT nbrbrr.repeated_buyer_referral_from_non_buyer_referrers), 
        ROUND( COUNT(DISTINCT nbrbrr.repeated_buyer_referral_from_non_buyer_referrers)*100/ 
        COUNT(DISTINCT Buyer_referral_from_non_buyer_referrers), 2) 
        AS Referrals_retention_rate, 
        SUM( nbrbrr.final_bill_amount) 
        AS Revenue_from_referrals, 
        ROUND( SUM( nbrbrr.final_bill_amount)*100/ 
        (SELECT SUM(final_bill_amount) FROM invoices), 2) 
        AS Contribution_in_Revenue 
FROM non_buyer_referrers_buyer_repeated_referrals as nbrbrr
)
SELECT *
FROM final_summary
UNION ALL
SELECT
    'Total',
    SUM(Buyer_Referrers),
    SUM(Total_Referral_given),
    ROUND(SUM(Total_Referral_given)/SUM(Buyer_Referrers), 2),
    SUM(Buyer_Referrals),
    ROUND(SUM(Buyer_Referrals)*100/
	SUM(Total_Referral_given),2
    ),
    SUM(Repeated_referrals),
    ROUND(SUM(Repeated_referrals)*100/
	SUM(Buyer_Referrals),2
    ),
	SUM(Revenue_from_referrals),
    SUM(Contribution_in_Revenue)
FROM final_summary;

-- ==================== END OF Referrer Analysis ===================== --


-- ===============================================================
-- ============ 2.6) 3) Analysis on Buyer_Referrers===============
-- ===============================================================

-- 1) Extracting the Referrer Buyers 
SELECT DISTINCT c.referred_by_id
FROM customers_details as c
INNER JOIN invoices as i
On c.referred_by_id=i.customer_id;

-- COUNT of Referrers Buyers 
-- Out of 721 referrers; 333 referrers are our Uniuqe buyers 
WITH referrer_buyers AS (
SELECT DISTINCT c.referred_by_id
FROM customers_details as c
INNER JOIN invoices as i
On c.referred_by_id=i.customer_id
)
SELECT COUNT(*) AS COUNT_Unique_Buyers
FROM referrer_buyers;

-- Lets Check COUNT the Repeated Buyer_Referrers 
-- Out of 333 buyer_referrer 97 referrer are our repeated_customers
WITH unique_referrer_buyers AS (
SELECT DISTINCT c.referred_by_id 
FROM customers_details as c
INNER JOIN invoices as i
ON c.referred_by_id=i.customer_id
),
unique_repeated__buyer_referrer AS (
SELECT urb.referred_by_id, COUNT(i.customer_id) AS Number_of_times_Buyer_referrers_repeated
FROM unique_referrer_buyers AS urb
INNER JOIN invoices as i
On urb.referred_by_id=i.customer_id
GROUP BY urb.referred_by_id 
HAVING COUNT(i.customer_id) > 1
ORDER BY COUNT(i.customer_id) DESC
)
SELECT COUNT(*) AS Total_Repeated_Buyer_Referrers
FROM unique_repeated__buyer_referrer;

-- Here are those repeated buyer_referrer and their count of how many times they are repeated
-- Lets Check COUNT the Repeated Buyer_Referrers 
-- Out of 333 buyer_referrer 97 referrer are our repeated_customers
WITH unique_referrer_buyers AS (
SELECT DISTINCT c.referred_by_id 
FROM customers_details as c
INNER JOIN invoices as i
ON c.referred_by_id=i.customer_id
)
SELECT urb.referred_by_id, COUNT(i.customer_id) AS Number_of_times_Buyer_referrers_repeated
FROM unique_referrer_buyers AS urb
INNER JOIN invoices as i
On urb.referred_by_id=i.customer_id
GROUP BY urb.referred_by_id 
HAVING COUNT(i.customer_id) > 1
ORDER BY COUNT(i.customer_id) DESC;

-- Total Revenue Collected From Buyer_referrer  (Note this the revenue we have collected from the buyer_referrer when they made a purchase; and not the the revenue collected from their referrrals) 
-- Hence the total revenue collected from this buyer_referrer is 4304354.00
WITH unique_buyer_referrer AS (
SELECT DISTINCT c.referred_by_id
FROM customers_details as c
INNER JOIN invoices as i
ON c.referred_by_id=i.customer_id
)
SELECT SUM(i.final_bill_amount)
FROM unique_buyer_referrer as ubr
INNER JOIN invoices as i
ON ubr.referred_by_id=i.customer_id;

-- Percentage Calculation of referrers who are our buyers out of all the referrers

SELECT c.referred_by_id, c.customer_id, i.customer_id
FROM customers_details as c
LEFT JOIN invoices as i
ON c.referred_by_id=i.customer_id;

-- Percentage Calculation of Buyer_Referrers      
-- 46.19% of referrers out of 721 referrers are buyer_referrers 
SELECT 
      COUNT(DISTINCT c.referred_by_id) AS Total_COUNT_of_Referrers,
      COUNT(DISTINCT  CASE WHEN i.customer_id IS NOT NULL AND c.referred_by_id IS NOT NULL THEN c.referred_by_id END) AS COUNT_Buyer_Referrers,
      COUNT(DISTINCT CASE WHEN i.customer_id IS NULL AND c.referred_by_id IS NOT NULL THEN c.referred_by_id END) AS COUNT_Non_Buyer_Referrers,
-- Percentage Calculation of Buyer_Referrers      
      ROUND( COUNT(DISTINCT  CASE WHEN i.customer_id IS NOT NULL AND c.referred_by_id IS NOT NULL THEN c.referred_by_id END) * 100 / 
      COUNT(DISTINCT c.referred_by_id), 2) AS Percentage_of_Referrer_Buyers
FROM customers_details as c
LEFT JOIN invoices as i
ON c.referred_by_id=i.customer_id;

-- Revenue Generated by Buyer referrers referrals
-- -- Result : 2110932.00

WITH buyer_referrers AS (
SELECT DISTINCT c.referred_by_id, c.customer_id
FROM customers_details as c
INNER JOIN invoices as i
ON c.referred_by_id=i.customer_id
)
SELECT SUM(i.final_bill_amount)
FROM invoices as i
INNER JOIN buyer_referrers as br
ON br.customer_id=i.customer_id;

-- COUNT of referrals given by the buyer_referrers
-- That as total pf 374 referrals are given by the buyer_referrer
WITH buyer_referrer AS (
SELECT c.referred_by_id, c.customer_id
FROM customers_details as c
INNER JOIN invoices as i
ON c.referred_by_id=i.customer_id
)
SELECT COUNT(DISTINCT br.customer_id) AS COUNT_Referrals_by_Buyer_referrers
FROM buyer_referrer as br;

-- Count of buyer_referrals given by the Buyer referrer
-- 168 referral are buyers out of all the referrals 
WITH buyer_referrer AS (
SELECT c.referred_by_id, c.customer_id
FROM customers_details as c
INNER JOIN invoices as i
ON c.referred_by_id=i.customer_id
)
SELECT COUNT(DISTINCT br.customer_id) AS COUNT_Referral_Buyers
FROM buyer_referrer as br
INNER JOIN invoices as i
ON br.customer_id=i.customer_id;

-- Final Summary about the buyer_referrers
-- COUNT of referrals from referrer buyers, segregating them on the basis of buyer referral and non_buyer referral
-- Total 374 Referrals
-- 168 are buyers
-- 206 are Non_Buyers
-- 44.92 is the Conversion_Rate of the referrals to buyers
WITH buyer_referrer AS (
SELECT c.referred_by_id, c.customer_id
FROM customers_details as c
INNER JOIN invoices as i
ON c.referred_by_id=i.customer_id
)
SELECT 
      COUNT(DISTINCT br.customer_id) AS Total_Referrals_from_Buyer_referrers,
      COUNT(DISTINCT CASE WHEN i.customer_id IS NOT NULL THEN br.customer_id END) AS COUNT_Buyer_referrals_from_buyer_referrers,
      COUNT(DISTINCT CASE WHEN i.customer_id IS NULL THEN br.customer_id END) AS COUNT_Non_buyers_from_buyer_referrers,
-- calculating the conversion rate 
      ROUND(  COUNT(DISTINCT CASE WHEN i.customer_id IS NOT NULL THEN br.customer_id END) * 100 /  COUNT(DISTINCT br.customer_id), 2) AS Conversion_Rate_to_buyers,
      COUNT(DISTINCT CASE WHEN i.customer_id IS NULL THEN br.customer_id END) AS COUNT_Non_Buyer_referrals_from_buyer_referrers
FROM buyer_referrer as br
LEFT JOIN invoices as i
ON br.customer_id=i.customer_id;

-- Buyer Referrer Age group
-- So our Highest referrer are from the Old_Age_Groups
WITH unique_referrer_buyer AS (
SELECT DISTINCT c.referred_by_id 
FROM customers_details as c
INNER JOIN invoices as i
ON c.referred_by_id=i.customer_id
),
unique_referrer_buyer_age AS (
SELECT urb.referred_by_id, c.age
FROM unique_referrer_buyer as urb
INNER JOIN customers_details as c
ON urb.referred_by_id=c.customer_id
)
SELECT
CASE 
    WHEN urba.age < 20 THEN "Teenage_Customer"
    WHEN urba.age BETWEEN 20 AND 30 THEN "20's Customer"
    WHEN urba.age BETWEEN 31 AND 40 THEN "30's Customer"
    WHEN urba.age BETWEEN 41 AND 50 THEN "40's Customer"
    WHEN urba.age BETWEEN 51 AND 60 THEN "50's Customer"
    WHEN urba.age > 60 THEN "Old_Age Customers"
  END AS Age_group,
COUNT(DISTINCT urba.referred_by_id) AS COUNT_Referrer_Buyer
FROM unique_referrer_buyer_age as urba
GROUP BY Age_group WITH ROLLUP
ORDER BY COUNT_Referrer_Buyer DESC;

-- ========================= END OF Buyer Referrer Analysis =============================== --

-- ===================================================================================
-- ================ 2.6) 2) Non_Buyers_Referrers_Analysis  ===========================
-- ===================================================================================

-- 2.6.4.2) Audit Query 
-- Out of 721 Referrers how many Referrers actually is our customers / Buyers and their conversion rate
-- I observe one thing; that is, only 333 referring persons are our buyers out of 721 Total referrals 
-- The Thing is Notable because this is very abnormal thing ( how can someone who is not our buyer/customer can referrer us?)

-- 2.6.4.2.1) 
-- This Query get us the Referrers who are our Buyers / Customers
SELECT c.referred_by_id, i.customer_id
FROM customers_details as c
INNER JOIN invoices as i
ON c.referred_by_id=i.customer_id;

-- This Query Gives us the Count of Referrers who are our Buyers / Customers
-- Only 333 Referring People are our Customers/Buyers out of 721; rest 388 are not our customers / buyers
SELECT 
	  COUNT(DISTINCT i.customer_id) AS COUNT_Buyer_Referrers
FROM customers_details as c
INNER JOIN invoices as i
ON c.referred_by_id=i.customer_id;

-- This Query will get you the referrers who are not buyers /customers
-- -- That is 388 Referrers out of 721 are not even our Buyers / Customers
SELECT c.referred_by_id, i.customer_id
FROM customers_details as c
LEFT JOIN invoices as i
ON c.referred_by_id=i.customer_id
WHERE i.customer_id IS NULL AND c.referred_by_id IS NOT NULL;

-- Follow Up Query to COUNT the Non_Buyer_Referrers

SELECT COUNT(DISTINCT c.referred_by_id) AS COUNT_Non_Buyers_Referrers
FROM customers_details as c
LEFT JOIN invoices as i
ON c.referred_by_id=i.customer_id
WHERE i.customer_id IS NULL AND c.referred_by_id IS NOT NULL;

-- Summary of Referrers who are Buyers V/S ; and their Conversion Rate
SELECT 
      COUNT(DISTINCT c.referred_by_id) AS Total_Referrers,
      COUNT(DISTINCT CASE WHEN c.referred_by_id IS NOT NULL AND i.customer_id IS NOT NULL THEN c.referred_by_id END) AS COUNT__Buyers_Referrer, 
      COUNT(DISTINCT CASE WHEN c.referred_by_id IS NOT NULL AND i.customer_id IS NULL THEN c.referred_by_id END) AS COUNT_NON_Buyers_Referrer,
      ROUND( COUNT(DISTINCT CASE WHEN c.referred_by_id IS NOT NULL AND i.customer_id IS NOT NULL THEN c.referred_by_id END) * 100 / COUNT(DISTINCT c.referred_by_id), 2) AS Referrers_Conversion_Rate
FROM customers_details as c
LEFT JOIN invoices as i
ON c.referred_by_id=i.customer_id;

-- Revenue Generated from referrals of Non_Buyers_Referrers 
-- 
WITH non_buyer_referrers AS (
SELECT c.referred_by_id, c.customer_id
FROM customers_details as c
LEFT JOIN invoices as i
ON c.referred_by_id=i.customer_id
WHERE i.customer_id IS NULL AND c.referred_by_id IS NOT NULL
)
SELECT 
      SUM(i.final_bill_amount)
FROM non_buyer_referrers as nbr
INNER JOIN invoices as i
ON nbr.customer_id=i.customer_id;

-- Repeated Customers in Buyers_Referrers
SELECT c.referred_by_id, i.customer_id
FROM customers_details as c
INNER JOIN invoices as i
ON c.referred_by_id=i.customer_id;

-- Deep Analysis of Non_Buyers_Referrers ---> Lets Call them as as Ghost_Referrers
-- 2.6.4.2.3) Checking how many overall referrals given by the Non-Buyers-referres
-- Total 436 Referrals has being given by the Non-Buyers-referrers

SELECT c.referred_by_id, c.customer_id, i.customer_id
FROM customers_details as c
LEFT JOIN invoices as i
ON c.referred_by_id=i.customer_id
WHERE i.customer_id IS NULL AND c.referred_by_id IS NOT NULL;

-- Total 436 Referrals has being given by the Non-Buyers-referrers
SELECT 
      COUNT(DISTINCT c.customer_id) AS Total_Unique_Referrals
FROM customers_details as c
LEFT JOIN invoices as i
ON c.referred_by_id=i.customer_id
WHERE i.customer_id IS NULL AND c.referred_by_id IS NOT NULL;

-- 2.6.5) "Do these non-buyer referrals actually result in sales, or are they low-quality leads?"
-- DEEP Analysis of Buyers from Non_Buyer_Referrers
-- Checking whether non-buyers referrers, referred customers has generated sales or not 

WITH non_buyers_referrers AS (
SELECT 
      c.referred_by_id, 
	  c.customer_id AS referral_customers
FROM customers_details as c
LEFT JOIN invoices as i
ON c.referred_by_id=i.customer_id
WHERE i.customer_id IS NULL AND c.referred_by_id IS NOT NULL
) 
SELECT i.customer_id, i.invoice_id 
FROM invoices as i
INNER JOIN non_buyers_referrers as nbr
ON nbr.referral_customers=i.customer_id;

-- 2.6.5.1) COUNT of customers referred by the non buyers referrers
-- Out of the 388 Non-Buyers Referrers they have given a total of 436 referrals out of which-
-- 213 Refferals has become a buyers
WITH non_buyers_referrers AS (
SELECT 
      c.referred_by_id, 
	  c.customer_id AS referral_customers
FROM customers_details as c
LEFT JOIN invoices as i
ON c.referred_by_id=i.customer_id
WHERE i.customer_id IS NULL AND c.referred_by_id IS NOT NULL
) 
SELECT 
      COUNT(i.customer_id) AS Total_Customers,
      COUNT(DISTINCT i.customer_id) AS Unique_Buyer_from_non_buyers_referrers,
      ROUND( COUNT(i.customer_id) - COUNT(DISTINCT i.customer_id), 2) AS Total_Repeated_Customers_By_Non_Referrers_Buyers
FROM invoices as i
INNER JOIN non_buyers_referrers as nbr
ON nbr.referral_customers=i.customer_id;
-- Here the diferrernce between the Unique Customers and DISTINCT Customers is diferrent
-- hence the referral customers by the non_buyers referrers are also the part of the repeating customers (thats a really best thing)
 
-- Extracting the Repeated Customers of referrals bf Non_Buyers_Referrers 
WITH non_buyers_referrers AS (
SELECT 
      c.referred_by_id, 
	  c.customer_id AS referral_customers
FROM customers_details as c
LEFT JOIN invoices as i
ON c.referred_by_id=i.customer_id
WHERE i.customer_id IS NULL AND c.referred_by_id IS NOT NULL
)
SELECT 
     i.customer_id, COUNT(i.customer_id) AS Number_of_Times_Repeated_referrals_of_Non_Buyers_Referrers
FROM invoices as i
INNER JOIN non_buyers_referrers as nbr
ON nbr.referral_customers=i.customer_id
GROUP BY i.customer_id
HAVING Number_of_Times_Repeated_referrals_of_Non_Buyers_Referrers > 1
ORDER BY Number_of_Times_Repeated_referrals_of_Non_Buyers_Referrers DESC;

-- COUNT Repeated Customers of referrals by Non_Buyers_Referrers 
WITH non_buyers_referrers AS (
SELECT 
      c.referred_by_id, 
	  c.customer_id AS referral_customers
FROM customers_details as c
LEFT JOIN invoices as i
ON c.referred_by_id=i.customer_id
WHERE i.customer_id IS NULL AND c.referred_by_id IS NOT NULL
),
Repeated_Customers_of_referrals_of_Non_Buyers_Referrers AS (
SELECT 
     i.customer_id, COUNT(i.customer_id) AS Number_of_Times_Repeated_referrals_of_Non_Buyers_Referrers
FROM invoices as i
INNER JOIN non_buyers_referrers as nbr
ON nbr.referral_customers=i.customer_id
GROUP BY i.customer_id
HAVING Number_of_Times_Repeated_referrals_of_Non_Buyers_Referrers > 1
ORDER BY Number_of_Times_Repeated_referrals_of_Non_Buyers_Referrers DESC
)
SELECT COUNT(Repeated_Customers_of_referrals_of_Non_Buyers_Referrers.customer_id)
FROM Repeated_Customers_of_referrals_of_Non_Buyers_Referrers;

-- Revenue Generated from the buyers of Non_Buyers_Referrers
-- 2653041.00 That is around 26 Lakhs 53 Thousand
-- It means Non_Buyers Referral has also helped us in generating the Sales

-- Revenue Generated from Non_Buyer_referrals -- Result : 2653041.00
WITH non_buyers_referrers AS (
SELECT 
      DISTINCT c.referred_by_id, 
  c.customer_id AS referral_customers
FROM customers_details as c
LEFT JOIN invoices as i
ON c.referred_by_id=i.customer_id
WHERE i.customer_id IS NULL AND c.referred_by_id IS NOT NULL
)
SELECT 
     SUM(i.final_bill_amount) AS Revenue_Generated_from_the_buyers_of_Non_Buyers_Referrers
FROM invoices as i
INNER JOIN non_buyers_referrers as nbr
ON nbr.referral_customers=i.customer_id;

-- DEEP Analysis of Non_Buyers FROm the NON_Buyers_Referrers

-- Out of 436 Referrals from Non_Buyers_Referrers; 223 are Non Buyers

WITH non_buyers_referrers AS (
SELECT 
      c.referred_by_id, 
	  c.customer_id AS referral_customers
FROM customers_details as c
LEFT JOIN invoices as i
ON c.referred_by_id=i.customer_id
WHERE i.customer_id IS NULL AND c.referred_by_id IS NOT NULL
) 
SELECT nbr.referral_customers, i.customer_id 
FROM non_buyers_referrers as nbr
LEFT JOIN invoices as i
ON nbr.referral_customers=i.customer_id
WHERE i.customer_id IS NULL;

-- COUNT of Non_buyers from Non_buyers_referrers
-- Out of 436 Referrals from Non_Buyers_Referrers; 
-- 223 are Non Buyers & 213 Buyers

-- Final Summary of Buyers from Non_Referrer_Buyers
WITH non_buyers_referrers AS (
SELECT 
      c.referred_by_id, 
	  c.customer_id AS referral_customers
FROM customers_details as c
LEFT JOIN invoices as i
ON c.referred_by_id=i.customer_id
WHERE i.customer_id IS NULL AND c.referred_by_id IS NOT NULL
) 
SELECT
      SUM(i.final_bill_amount) AS Revenue_Generated_from_Non_buyers_referrers,
      COUNT(DISTINCT referral_customers) AS Total_referral_from_Non_referrer_buyers,
      COUNT(DISTINCT CASE WHEN i.customer_id IS NULL THEN nbr.referral_customers END) AS Non_Buyers_from_Non_Buyers_Referrers,
      COUNT(DISTINCT CASE WHEN i.customer_id IS NOT NULL THEN nbr.referral_customers END) AS Buyers_from_Non_Buyers_Referrers,
-- Calculating the Conversion Rate of Referrals from Non       
      ROUND(COUNT(DISTINCT CASE WHEN i.customer_id IS NOT NULL THEN nbr.referral_customers END) * 100 / COUNT(DISTINCT referral_customers), 2) AS Conversion_Rate_of_referral_from_Non_buyer_Referrers
FROM non_buyers_referrers as nbr
LEFT JOIN invoices as i
ON nbr.referral_customers=i.customer_id;

-- =========== END OF Non_Buyers_Referrers_Analysis  ==============
