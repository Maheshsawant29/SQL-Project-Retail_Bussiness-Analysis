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
    ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(product_id)
    ON DELETE CASCADE,
    FOREIGN KEY (brand_id) REFERENCES product_brand(brand_id)
    ON DELETE CASCADE,
    FOREIGN KEY (product_type_id) REFERENCES product_type(product_type_id)
    ON DELETE CASCADE
);
