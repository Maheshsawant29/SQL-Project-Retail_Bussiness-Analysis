
-- Table 9: Additional Details about the Customer

CREATE TABLE additional_customer_details(
    customer_id INT PRIMARY KEY,
    date_of_customer_visit DATE NOT NULL,
    number_of_days_to_deliver_Product INT NOT NULL,
    fiter_Name VARCHAR(50),
    glass_distributor_name VARCHAR(50),
    time_spend_by_customer_in_shop INT,
    FOREIGN KEY(customer_id) REFERENCES customers_details(customer_id)
    ON DELETE CASCADE
);
