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

