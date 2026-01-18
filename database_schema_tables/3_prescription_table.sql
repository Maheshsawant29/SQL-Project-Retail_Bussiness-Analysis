-- Table 3 : Prescription Table
-- Note: Prescriptions change over time. We store them as a history.
CREATE TABLE prescriptions (
    prescription_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT NOT NULL,
    visit_date DATE DEFAULT (CURRENT_DATE),
    r_sph DECIMAL(4,2), r_cyl DECIMAL(4,2), r_axis INT,
    l_sph DECIMAL(4,2), l_cyl DECIMAL(4,2), l_axis INT,
    vision_type ENUM('Near', 'Distance', 'Bifocal', 'Progressive'),
    FOREIGN KEY (customer_id) REFERENCES customers_details (customer_id) 
    ON DELETE CASCADE
);
