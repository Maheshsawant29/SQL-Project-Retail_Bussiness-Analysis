-- Table 7 : Invoice Table

CREATE TABLE invoices (
    invoice_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT NOT NULL,
    staff_id INT NOT NULL,
    invoice_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    payment_mode ENUM('Cash', 'UPI', 'Card'),
    total_amount_items DECIMAL(10,2),   -- SUM of all item prices
    total_tax DECIMAL(10,2) DEFAULT 0.00,
    discount_amount DECIMAL(10,2) DEFAULT 0.00,
    final_bill_amount DECIMAL(10,2) GENERATED ALWAYS AS (COALESCE(total_amount_items,0) + COALESCE(total_tax,0) - COALESCE(discount_amount,0) ) STORED,
    FOREIGN KEY (customer_id) REFERENCES customers_details(customer_id),
    FOREIGN KEY (staff_id) REFERENCES staff(staff_id)
);
