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
