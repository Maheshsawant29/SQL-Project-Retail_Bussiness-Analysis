-- Table 2 : Customer_details (Stores the Customer_data)

CREATE TABLE customers_details (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_full_name VARCHAR(100) NOT NULL,
    age INT CHECK (age > 0 AND age < 120),
    mobile VARCHAR(15) UNIQUE NOT NULL,
    customer_type ENUM('New', 'Repeated', 'Referral'),
    referred_by_id INT, -- Links to another customer_id
    assigned_staff_id INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (referred_by_id) REFERENCES customers_details(customer_id),
    FOREIGN KEY (assigned_staff_id) REFERENCES staff(staff_id)
);
