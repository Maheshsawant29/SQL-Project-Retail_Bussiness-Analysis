CREATE DATABASE retail_optical_bussiness;

USE retail_optical_bussiness;

-- Table 1 : Staff Table (Stores the Satff data)

CREATE TABLE staff (
    staff_id INT PRIMARY KEY AUTO_INCREMENT,
    staff_full_name VARCHAR(100) NOT NULL,
    designation VARCHAR(50),
    contact_number VARCHAR(15) UNIQUE,
    hire_date DATE DEFAULT (CURRENT_DATE)
);