-- ==========================================
-- NAME: Afif Al Mohammed
-- COURSE: Database Techniques
-- EXAM TEMPLATE
-- ==========================================


-- ==========================================
-- CREATE DATABASE
-- creates database if not exists
-- ==========================================

CREATE DATABASE IF NOT EXISTS exam_db;
USE exam_db;



-- ==========================================
-- CREATE TABLES
-- PK = unique id
-- FK = relation between tables
-- ==========================================

CREATE TABLE Category(
    category_id INT AUTO_INCREMENT PRIMARY KEY, -- unique id
    name VARCHAR(100) UNIQUE
);

CREATE TABLE Product(
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100),
    price DECIMAL(10,2),
    stock_qty INT,

    category_id INT,

    -- foreign key linking category
    FOREIGN KEY(category_id) REFERENCES Category(category_id)
);

CREATE TABLE Customer(
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100),
    city VARCHAR(100)
);

CREATE TABLE Sale(
    sale_id INT AUTO_INCREMENT PRIMARY KEY,
    sale_date DATETIME DEFAULT CURRENT_TIMESTAMP,

    customer_id INT,

    FOREIGN KEY(customer_id) REFERENCES Customer(customer_id)
);

CREATE TABLE SaleItem(
    sale_item_id INT AUTO_INCREMENT PRIMARY KEY,

    quantity INT,
    unit_price DECIMAL(10,2),

    sale_id INT,
    product_id INT,

    FOREIGN KEY(sale_id) REFERENCES Sale(sale_id),
    FOREIGN KEY(product_id) REFERENCES Product(product_id)
);



-- ==========================================
-- INSERT EXAMPLE DATA
-- used to test queries
-- ==========================================

INSERT INTO Category(name)
VALUES ('Food'), ('Electronics');

INSERT INTO Product(name,price,stock_qty,category_id)
VALUES
('Laptop',1200,10,2),
('Apple',10,50,1);

INSERT INTO Customer(name,city)
VALUES
('Afif','Karlskrona'),
('Sara','Stockholm');



-- ==========================================
-- ALTER TABLE
-- used to modify table structure
-- ==========================================

ALTER TABLE Customer
ADD email VARCHAR(100);



-- ==========================================
-- SELECT + JOIN
-- JOIN connects rows between tables
-- ==========================================

SELECT
Product.name,
Category.name AS category

FROM Product

JOIN Category
ON Product.category_id = Category.category_id;



-- ==========================================
-- AGGREGATION
-- GROUP BY groups rows
-- SUM calculates totals
-- ==========================================

SELECT
Sale.sale_id,

SUM(SaleItem.quantity * SaleItem.unit_price) AS total_sale

FROM Sale

JOIN SaleItem
ON Sale.sale_id = SaleItem.sale_id

GROUP BY Sale.sale_id;



-- ==========================================
-- VIEW
-- view stores a SELECT query
-- ==========================================

CREATE OR REPLACE VIEW product_overview AS

SELECT
Product.name,
Product.price,
Category.name AS category

FROM Product

JOIN Category
ON Product.category_id = Category.category_id;

SELECT * FROM product_overview;



-- ==========================================
-- TRIGGER
-- trigger runs automatically when event occurs
-- ==========================================

DELIMITER //

CREATE TRIGGER reduce_stock_after_sale

AFTER INSERT ON SaleItem

FOR EACH ROW

BEGIN

-- reduce stock automatically
UPDATE Product
SET stock_qty = stock_qty - NEW.quantity

WHERE product_id = NEW.product_id;

END //

DELIMITER ;



-- ==========================================
-- PROCEDURE
-- procedure executes multiple SQL statements
-- ==========================================

DELIMITER //

CREATE PROCEDURE create_sale(

IN input_customer INT,   -- customer id
IN input_product INT,    -- product id
IN input_quantity INT    -- quantity sold

)

BEGIN

-- variable storing new sale id
DECLARE new_sale INT;

-- variable storing product price
DECLARE product_price DECIMAL(10,2);

-- get product price
SELECT price
INTO product_price
FROM Product
WHERE product_id = input_product;

-- create new sale
INSERT INTO Sale(customer_id)
VALUES(input_customer);

-- save id of created sale
SET new_sale = LAST_INSERT_ID();

-- insert item into sale
INSERT INTO SaleItem(quantity,unit_price,sale_id,product_id)

VALUES(input_quantity,product_price,new_sale,input_product);

END //

DELIMITER ;



-- test procedure
CALL create_sale(1,1,2);



-- ==========================================
-- FUNCTION
-- function returns one value
-- ==========================================

DELIMITER //

CREATE FUNCTION calculate_revenue(price DECIMAL)

RETURNS DECIMAL(10,2)

DETERMINISTIC

BEGIN

-- variable storing result
DECLARE revenue DECIMAL(10,2);

-- check price
IF price < 1000 THEN

-- company takes 20%
SET revenue = price * 0.20;

ELSE

-- company takes 10%
SET revenue = price * 0.10;

END IF;

-- return calculated value
RETURN revenue;

END //

DELIMITER ;



-- test function
SELECT calculate_revenue(800);



-- ==========================================
-- SUBQUERY
-- query inside another query
-- ==========================================

SELECT name, price

FROM Product

WHERE price =

(
SELECT MAX(price)
FROM Product
);



-- ==========================================
-- LEFT JOIN
-- shows ALL rows from left table
-- ==========================================

SELECT
Customer.name,
Sale.sale_id

FROM Customer

LEFT JOIN Sale
ON Customer.customer_id = Sale.customer_id;



-- ==========================================
-- RIGHT JOIN
-- shows ALL rows from right table
-- ==========================================

SELECT
Customer.name,
Sale.sale_id

FROM Customer

RIGHT JOIN Sale
ON Customer.customer_id = Sale.customer_id;