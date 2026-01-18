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
( 1, 2, "K & D"),
( 1, 3, "NOVA"),
( 1, 4, "Ray Ban"),
( 1, 5, "Prada"),
( 1, 6, "OAKLEY"),
( 1, 7, "Carrera"),
( 1, 8, "Tommy Hilfiger"),
( 1, 9, "Calvin Klien"),
( 1, 10, "Essilor"),
( 2, 11, "Essilor"),
( 2, 12, "NOVA"),
( 2, 13, "Prime Lens"),
( 2, 14, "Rode & Stock"),
( 2, 15, "Bonzer Lens"),
( 2, 16, "Ziess"),
( 2, 17, "Crizal Lens"),
( 3, 18, "Ray Ban"),
( 3, 19, "Local Brand"),
( 4, 20, "Bausch + Lomb"),
( 4, 21, "Acme"),
( 4, 22, "Eye-art"),
( 5, 23, "Accessories"),
( 6, 24, "Renu Fresh"),
( 6, 25, "Aqua Soft Bio");
