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

-- Table 4 : Products Table 

CREATE TABLE products (
    product_id INT PRIMARY KEY AUTO_INCREMENT,
    product_name VARCHAR(100) NOT NULL
); 

INSERT INTO products
( product_id, product_name)
VALUES 
( 1, "Frame"),
( 2, "Glass"),
( 3, "Sunglass"),
( 4, "Contact_Lens"),
( 5, "Accessories"),
( 6, "Lens Solution");

-- Table 5: Product_Brand

CREATE TABLE product_brand (
       product_id INT NOT NULL,
       brand_id INT PRIMARY KEY AUTO_INCREMENT,
       brand_name VARCHAR(100),
       FOREIGN KEY(product_id) REFERENCES products(product_id)
);       

INSERT INTO product_brand
( product_id, brand_id, brand_name)
VALUES 
( 1, 1, "Local Brand"),
( 1, 2, "U Eyewear"),
( 1, 3, "K & D"),
( 1, 4, "NOVA"),
( 1, 5, "Ray Ban"),
( 1, 6, "IDEE"),
( 1, 7, "Prada"),
( 1, 8, "Vogue"),
( 1, 9, "Police"),
( 1, 10, "OAKLEY"),
( 1, 11, "Carrera"),
( 1, 12, "Tommy Hilfiger"),
( 1, 13, "Calvin Klien"),
( 1, 15, "Essilor"),
( 2, 16, "Essilor"),
( 2, 17, "NOVA"),
( 2, 18, "Prime Lens"),
( 2, 19, "Rode & Stock"),
( 2, 20, "Bonzer Lens"),
( 2, 21, "Ziess"),
( 2, 22, "Crizal Lens"),
( 3, 23, "Ray Ban"),
( 3, 24, "Local Brand"),
( 4, 25, "Bausch + Lomb"),
( 4, 26, "Acme"),
( 4, 27, "Eye-art"),
( 5, 28, "Accessories"),
( 6, 29, "Renu Fresh"),
( 6, 30, "Aqua Soft Bio");

-- Table 6: Product Type Table

CREATE TABLE product_type (
     product_id INT NOT NULL,
     product_type_id INT PRIMARY KEY,
     product_type_name VARCHAR(100) NOT NULL,
     FOREIGN KEY(product_id) REFERENCES products(product_id)
); 

INSERT INTO product_type
( product_id, product_type_id, product_type_name)
VALUES 
( 1,1, "Metal+Square"),
( 1,2, "Metal+Rectangle"),
( 1,3, "Metal+Round"),
( 1,4, "Metal+Hexagon"),
( 1,5, "Metal+Pilot"),
( 1,6, "Metal+Oval"),
( 1,7, "Plastic+Square"),
( 1,8, "Plastic+Rectangle"),
( 1,9, "Plastic+Round"),
( 1,10, "Plastic+Hexagon"),
( 1,11, "Plastic+Oval"),
( 2,12, "HC"),
( 2,13, "ARC"),
( 2,14, "Blu-Block"),
( 2,15, "Daynite"),
( 2,16, "Daynite + HC"),
( 2,17, "Daynite + ARC"),
( 2,18, "Daynote + Blu-Block"),
( 3,19, "Metal+Square"),
( 3,20, "Metal+Rectangle"),
( 3,21, "Metal+Round"),
( 3,22, "Metal+Hexagon"),
( 3,23, "Metal+Pilot"),
( 3,24, "Metal+Oval"),
( 3,25, "Plastic+Square"),
( 3,26, "Plastic+Rectangle"),
( 3,27, "Plastic+Round"),
( 3,28, "Plastic+Hexagon"),
( 3,29, "Plastic+Oval"),
( 4,30, "One day"),
( 4,31, "Weekly"),
( 4,32, "Monthly"),
( 4,33, "Quaterly"),
( 4,34, "6 Months"),
( 4,35, "Yearly"),
( 6,36, "Liquid");

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

-- Table 8: Item_in_Invoice

CREATE TABLE invoice_items (
    invoice_id INT NOT NULL,
    item_id INT PRIMARY KEY AUTO_INCREMENT,
    product_id INT NOT NULL,
    brand_id INT,
    product_type_id INT,
    quantity INT NOT NULL DEFAULT 1,
    unit_selling_price DECIMAL(10,2) NOT NULL,
	final_product_price DECIMAL(10,2) GENERATED ALWAYS AS (unit_selling_price * quantity) STORED,
    FOREIGN KEY (invoice_id) REFERENCES invoices(invoice_id)
    ON UPDATE CASCADE
    ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(product_id)
    ON UPDATE CASCADE
    ON DELETE CASCADE,
    FOREIGN KEY (brand_id) REFERENCES product_brand(brand_id)
    ON UPDATE CASCADE
    ON DELETE CASCADE,
    FOREIGN KEY (product_type_id) REFERENCES product_type(product_type_id)
    ON UPDATE CASCADE
    ON DELETE CASCADE
);

-- Table 9: Additional Details about the Customer

CREATE TABLE additional_customer_details(
    customer_id INT PRIMARY KEY,
    date_of_customer_visit DATE NOT NULL,
    number_of_days_to_deliver_Product INT NOT NULL,
    fiter_Name VARCHAR(50),
    glass_distributor_name VARCHAR(50),
    time_spend_by_customer_in_shop INT,
    FOREIGN KEY(customer_id) REFERENCES customers_details(customer_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE
);

CREATE INDEX idx_customer_mobile ON customers_details(mobile);

