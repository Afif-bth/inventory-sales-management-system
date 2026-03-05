USE inventory_sales;

-- ============================================
-- VIEW 1: Product overview with category and supplier
-- This view stores a joined version of Product, Category and Supplier
-- ============================================

CREATE OR REPLACE VIEW product_overview AS
SELECT
   Product.product_id,
   Product.name AS product_name,
   Product.price,
   Product.stock_qty,
   
   Category.name AS category_name,
   Supplier.name AS supplier_name
FROM Product
JOIN Category
ON Product.category_id = Category.category_id
JOIN Supplier
ON Product.supplier_id = Supplier.supplier_id;

-- ============================================
-- QUERY 2: Calculate total amount per sale
-- This query calculates the total revenue for each sale.
-- It joins Sale with SaleItem and groups the result by sale.
-- ============================================
CREATE OR REPLACE VIEW  sale_totals AS
SELECT 
    Sale.sale_id,                      -- The unique ID of the sale
    Sale.sale_date,                    -- The date when the sale was created
    SUM(SaleItem.quantity * SaleItem.unit_price) 
        AS total_amount                -- Total amount for each sale
FROM Sale                              -- Start from the Sale table
JOIN SaleItem                          -- Join SaleItem to get sold products
ON Sale.sale_id = SaleItem.sale_id     -- Match rows using the common sale_id
GROUP BY 
    Sale.sale_id, 
    Sale.sale_date;                    -- Group rows by each sale
    
/*This query calculates the total revenue for each sale.
It joins the Sale and SaleItem tables using the foreign key relationship.
The SUM function calculates the total amount by multiplying quantity and unit price for each item.
The GROUP BY clause ensures that the calculation is performed separately for each sale.*/

/* pipeline:
		
FROM					1. FROM Sale
JOIN					2. JOIN SaleItem
ON						3. ON Sale.sale_id = SaleItem.sale_id
WHERE (if exists)
GROUP BY				4. GROUP BY Sale.sale_id, Sale.sale_date
HAVING (if exists)
(Aggregation: SUM, COUNT, AVG...)are calculated per group		5. Aggregation (SUM) is calculated within each group
SELECT					6. SELECT (display the result)
ORDER BY (if exists)

Note: Aggregation functions are written in SELECT
but executed after GROUP BY.

(Aggregation functions such as SUM, COUNT, and AVG):
1-Are written in the SELECT clause.
2-Are logically executed after FROM, JOIN, and WHERE.
3-If a GROUP BY clause exists → they are calculated within each group.
4-If no GROUP BY clause exists → they are calculated over all selected rows as a single group.
*/

-- ============================================
-- QUERY 3: Calculate total spending per customer
-- This query calculates the total amount spent by each customer
-- across all their sales.
-- ============================================

CREATE OR REPLACE VIEW customer_totals AS
SELECT 
    Customer.customer_id,
    Customer.name AS customer_name,
    SUM(SaleItem.quantity * SaleItem.unit_price) AS total_spent
FROM Customer
JOIN Sale
ON Customer.customer_id = Sale.customer_id
JOIN SaleItem
ON Sale.sale_id = SaleItem.sale_id
GROUP BY 
    Customer.customer_id,
    Customer.name;
/*This query calculates how much each customer has spent in total.
It joins the Customer, Sale, and SaleItem tables using foreign key relationships.
The SUM function calculates the total amount spent by multiplying quantity and unit price.
The GROUP BY clause ensures that the calculation is performed separately for each customer.
1. FROM Customer
2. JOIN Sale
3. JOIN SaleItem
4. GROUP BY customer
5. SUM calculated per customer
6. SELECT displays the result
*/

-- ============================================
-- VIEW 4: Total spending by gender and category
-- This view shows how much each gender spends
-- on each product category.
-- ============================================

CREATE OR REPLACE VIEW gender_category_totals AS
SELECT
    Customer.gender,
    Category.name AS category_name,
    SUM(SaleItem.quantity * SaleItem.unit_price) AS total_spent
FROM Customer
JOIN Sale
ON Customer.customer_id = Sale.customer_id
JOIN SaleItem
ON Sale.sale_id = SaleItem.sale_id
JOIN Product
ON SaleItem.product_id = Product.product_id
JOIN Category
ON Product.category_id = Category.category_id
GROUP BY
    Customer.gender,
    Category.name;
    
    
-- ============================================
-- VIEW 5: Most purchased category per gender
-- This view returns the category with the highest
-- total spending for each gender.
-- It is built on the view "gender_category_totals".
-- this type calls //Correlated Subquery//
-- ============================================

CREATE OR REPLACE VIEW most_purchased_category_per_gender AS

SELECT
    gender_category_totals.gender,          -- Gender (Male or Female)
    gender_category_totals.category_name,   -- Category name
    gender_category_totals.total_spent      -- Total spending for that category

FROM gender_category_totals                 -- Start from the aggregated view

WHERE gender_category_totals.total_spent =  -- Keep only rows where spending equals
(
    SELECT MAX(gender_category_totals_inner.total_spent)
    FROM gender_category_totals AS gender_category_totals_inner
    -- Calculate the maximum spending per gender
    WHERE gender_category_totals_inner.gender =
          gender_category_totals.gender
    -- Ensure that the comparison is done for the same gender
);

/*
This view identifies the most purchased category for each gender.
It is based on the view gender_category_totals, which contains the total spending per gender and category.
The subquery calculates the maximum total_spent value for each gender.
The outer query then selects only the rows where the total_spent equals that maximum value.
This ensures that the highest spending category per gender is returned.
*/



-- ============================================
-- Drop triggers if they already exist
-- ============================================

DROP TRIGGER IF EXISTS check_stock_before_sale;
DROP TRIGGER IF EXISTS reduce_stock_after_sale;
-- ============================================
-- TRIGGER 1: Check stock before inserting a sale item
-- This trigger prevents inserting a SaleItem if
-- there is not enough stock available.
-- It runs BEFORE INSERT on the SaleItem table.
-- ============================================

DELIMITER //

CREATE TRIGGER check_stock_before_sale
BEFORE INSERT ON SaleItem
FOR EACH ROW
BEGIN

    -- Declare a variable to store current stock
    DECLARE current_stock INT;

    -- Retrieve the current stock of the selected product
    SELECT stock_qty
    INTO current_stock
    FROM Product
    WHERE product_id = NEW.product_id;

    -- Check if the requested quantity is greater than available stock
    IF current_stock < NEW.quantity THEN

        -- Raise an error and stop the insertion
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Not enough stock available';

    END IF;

END //

DELIMITER ;

-- ============================================
-- TRIGGER 2: Reduce stock after inserting a sale item
-- This trigger automatically decreases the stock quantity
-- in the Product table after a SaleItem is successfully inserted.
-- It runs AFTER INSERT on the SaleItem table.
-- ============================================

DELIMITER //

CREATE TRIGGER reduce_stock_after_sale
AFTER INSERT ON SaleItem
FOR EACH ROW
BEGIN

    -- Decrease the product stock by the sold quantity
    UPDATE Product
    SET stock_qty = stock_qty - NEW.quantity
    WHERE product_id = NEW.product_id;

END //

DELIMITER ;


-- ============================================
-- PROCEDURE: Create a sale with one product
-- This procedure creates a new sale for a customer
-- and inserts a SaleItem automatically.
-- ============================================

DROP PROCEDURE IF EXISTS create_sale;

DELIMITER //

CREATE PROCEDURE create_sale(
    IN input_customer_id INT,
    IN input_product_id INT,
    IN input_quantity INT
)
BEGIN

    DECLARE new_sale_id INT;
    DECLARE product_price DECIMAL(10,2);

    -- Get product price
    SELECT price
    INTO product_price
    FROM Product
    WHERE product_id = input_product_id;

    -- Create a new Sale
    INSERT INTO Sale (customer_id)
    VALUES (input_customer_id);

    -- Store the new sale id
    SET new_sale_id = LAST_INSERT_ID();

    -- Insert SaleItem
    INSERT INTO SaleItem (quantity, unit_price, sale_id, product_id)
    VALUES (input_quantity, product_price, new_sale_id, input_product_id);

END //

DELIMITER ;


CALL create_sale(1, 1, 2);
SELECT * FROM Sale;
SELECT * FROM SaleItem;
SELECT * FROM Product;
SELECT * FROM product_overview;
SELECT * FROM sale_totals;
SELECT * FROM customer_totals;
SELECT * FROM gender_category_totals;
SELECT * FROM most_purchased_category_per_gender;