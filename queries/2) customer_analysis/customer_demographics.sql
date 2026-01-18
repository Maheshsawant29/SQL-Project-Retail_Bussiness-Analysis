-- 2) Customer_Analysis

-- 2.1) Customer_Demographics ( Who they are, what they buy, how they buy, where we can improve ourselves)

-- 2.1.1) Customer Age Analysis

-- 1)
SELECT DISTINCT age FROM customers_details 
ORDER BY age;
-- hence we have customers from 18 to 85 of age

-- 2) Lets segregate the customer based on the age groups and their Count in each age group

SELECT
CASE 
    WHEN age < 20 THEN "Teenage_Customer"
    WHEN age BETWEEN 20 AND 30 THEN "20's Customer"
    WHEN age BETWEEN 31 AND 40 THEN "30's Customer"
    WHEN age BETWEEN 41 AND 50 THEN "40's Customer"
    WHEN age BETWEEN 51 AND 60 THEN "50's Customer"
    WHEN age > 60 THEN "Old_Age Customers"
  END AS Age_group,
COUNT(*) AS Count_of_Customers
FROM customers_details  
GROUP BY Age_group
ORDER BY Count_of_Customers DESC;

-- Age_group V/S Conversion rate

SELECT
CASE 
    WHEN age < 20 THEN "Teenage_Customer"
    WHEN age BETWEEN 20 AND 30 THEN "20's Customer"
    WHEN age BETWEEN 31 AND 40 THEN "30's Customer"
    WHEN age BETWEEN 41 AND 50 THEN "40's Customer"
    WHEN age BETWEEN 51 AND 60 THEN "50's Customer"
    WHEN age > 60 THEN "Old_Age Customers"
  END AS Age_group,
COUNT( DISTINCT c.customer_id) AS Visited_customers,
COUNT( DISTINCT i.customer_id) AS Actual_Buyers,
ROUND( COUNT( DISTINCT i.customer_id)*100 / COUNT( DISTINCT c.customer_id), 2) AS Conversion_Rate,
SUM(final_bill_amount) AS Revenue
FROM customers_details as c
LEFT JOIN invoices as i
ON c.customer_id=i.customer_id
GROUP BY Age_group
ORDER BY Conversion_Rate DESC;

-- Age_group V/S Revenue

SELECT
CASE 
    WHEN age < 20 THEN "Teenage_Customer"
    WHEN age BETWEEN 20 AND 30 THEN "20's Customer"
    WHEN age BETWEEN 31 AND 40 THEN "30's Customer"
    WHEN age BETWEEN 41 AND 50 THEN "40's Customer"
    WHEN age BETWEEN 51 AND 60 THEN "50's Customer"
    WHEN age > 60 THEN "Old_Age Customers"
  END AS Age_group,
SUM(final_bill_amount) AS Revenue
FROM customers_details as c
INNER JOIN invoices as i
ON c.customer_id=i.customer_id
GROUP BY Age_group
ORDER BY Revenue DESC;

-- Age_group V/S Average Time_spend

SELECT
CASE 
    WHEN age < 20 THEN "Teenage_Customer"
    WHEN age BETWEEN 20 AND 30 THEN "20's Customer"
    WHEN age BETWEEN 31 AND 40 THEN "30's Customer"
    WHEN age BETWEEN 41 AND 50 THEN "40's Customer"
    WHEN age BETWEEN 51 AND 60 THEN "50's Customer"
    WHEN age > 60 THEN "Old_Age Customers"
  END AS Age_group,
ROUND( AVG(time_spend_by_customer_in_shop), 0) AS Average_Time_Spend
FROM customers_details as c
LEFT JOIN additional_customer_details as a
ON c.customer_id=a.customer_id
GROUP BY Age_group
ORDER BY Average_Time_Spend DESC;

-- Age Group V/S Vision Type

SELECT
CASE 
    WHEN age < 20 THEN "Teenage_Customer"
    WHEN age BETWEEN 20 AND 30 THEN "20's Customer"
    WHEN age BETWEEN 31 AND 40 THEN "30's Customer"
    WHEN age BETWEEN 41 AND 50 THEN "40's Customer"
    WHEN age BETWEEN 51 AND 60 THEN "50's Customer"
    WHEN age > 60 THEN "Old_Age Customers"
  END AS Age_group,
SUM( CASE WHEN vision_type="Distance" THEN 1 ELSE 0 END) AS Distnace,
SUM( CASE WHEN vision_type="Near" THEN 1 ELSE 0 END) AS Near,
SUM( CASE WHEN vision_type="Bifocal" THEN 1 ELSE 0 END) AS Bifocal,
SUM( CASE WHEN vision_type="Progressive" THEN 1 ELSE 0 END) AS Progressive
FROM customers_details as c
INNER JOIN prescriptions as p
ON c.customer_id=p.customer_id
GROUP BY Age_group;

-- 2.1.2) Customer_Type V/S Age group

SELECT
CASE 
    WHEN age < 20 THEN "Teenage_Customer"
    WHEN age BETWEEN 20 AND 30 THEN "20's Customer"
    WHEN age BETWEEN 31 AND 40 THEN "30's Customer"
    WHEN age BETWEEN 41 AND 50 THEN "40's Customer"
    WHEN age BETWEEN 51 AND 60 THEN "50's Customer"
    WHEN age > 60 THEN "Old_Age Customers"
  END AS Age_group,
  SUM(CASE WHEN customer_type="New" THEN 1 ELSE 0 END) AS Count_New,
  SUM(CASE WHEN customer_type="Referral" THEN 1 ELSE 0 END) AS Count_Refferal
  FROM customers_details 
GROUP BY Age_group;

-- Customer_type v/s Revenue

SELECT c.customer_type, SUM(i.final_bill_amount) AS Revenue
FROM customers_details as c
INNER JOIN invoices as i
ON c.customer_id=i.customer_id
GROUP BY customer_type
ORDER BY Revenue DESC;

-- Customer_type v/s Count per year

SELECT c.customer_type,
       SUM(CASE WHEN YEAR(invoice_date)=2024 THEN 1 ELSE 0 END) AS Count_2024,
       SUM(CASE WHEN YEAR(invoice_date)=2025 THEN 1 ELSE 0 END) AS Count_2025,
       SUM(CASE WHEN YEAR(invoice_date)=2026 THEN 1 ELSE 0 END) AS Count_2026
FROM customers_details as c
LEFT JOIN invoices as i
ON c.customer_id=i.invoice_id
GROUP BY c.customer_type;

-- customer_type v/s Average time spend

SELECT c.customer_type, AVG(time_spend_by_customer_in_shop) 
FROM customers_details as c
INNER JOIN additional_customer_details as ad
ON c.customer_id=ad.customer_id
GROUP BY c.customer_type;

-- customer_type v/s payment_mode

SELECT c.customer_type,
       SUM(CASE WHEN payment_mode="UPI" THEN 1 ELSE 0 END) AS Count_UPI,
       SUM(CASE WHEN payment_mode="Cash" THEN 1 ELSE 0 END) AS Count_cash,
       SUM(CASE WHEN payment_mode="Card" THEN 1 ELSE 0 END) AS Count_card
FROM customers_details as c
INNER JOIN invoices as i
ON c.customer_id=i.customer_id
GROUP BY c.customer_type;

-- 2.1.3)  Vision Type

-- Vision Type COUNT
SELECT p.vision_type, COUNT(customer_id) AS COUNT_Vision_Type FROM prescriptions as p
GROUP BY p.vision_type
ORDER BY COUNT_Vision_Type DESC;

-- Vision type V/S customer_type

SELECT p.vision_type,
       SUM(CASE WHEN c.customer_type="New" THEN 1 ELSE 0 END) AS COUNT_New,
       SUM(CASE WHEN c.customer_type="Referral" THEN 1 ELSE 0 END) AS COUNT_Referral
FROM prescriptions as p
LEFT JOIN customers_details as c
ON c.customer_id=p.customer_id
GROUP BY p.vision_type;

-- vision_type v/s Age_group (already in Age_group Analysis)