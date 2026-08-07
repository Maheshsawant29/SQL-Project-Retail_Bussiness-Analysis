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