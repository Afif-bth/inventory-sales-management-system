USE inventory_sales;

-- Insert Categories
INSERT INTO Category (name) 
VALUES
	('Food'),
	('Clothing'),
	('Books'),
	('Electronics');

-- Insert Suppliers
INSERT INTO Supplier (name, email)
 VALUES
	('Ica Store AB', 'ica@supplier.com'),
	('FashionGroup AB', 'fashion@supplier.com'),
	('BookWorld AB', 'books@supplier.com'),
    ('TechSupplier AB', 'tech@supplier.com');

-- Insert Products

INSERT INTO Product (name, price, stock_qty, category_id, supplier_id)
VALUES
	('apple', 10, 50,
	 (SELECT category_id FROM Category WHERE name='Food'),
	 (SELECT supplier_id FROM Supplier WHERE name='Ica Store AB')
	),

	('Laptop', 1200.00, 50,
	 (SELECT category_id FROM Category WHERE name='Electronics'),
	 (SELECT supplier_id FROM Supplier WHERE name='TechSupplier AB')
	),

	('T-Shirt', 25.00, 100,
	 (SELECT category_id FROM Category WHERE name='Clothing'),
	 (SELECT supplier_id FROM Supplier WHERE name='FashionGroup AB')
	),

	('Book', 60.00, 40,
	 (SELECT category_id FROM Category WHERE name='Books'),
	 (SELECT supplier_id FROM Supplier WHERE name='BookWorld AB')
);

-- Insert Customers
INSERT INTO Customer (name, city, gender) VALUES
('Afif', 'Karlskrona', 'Male'),
('Rana Lind', 'Gothenburg', 'Female');


-- ============================================
-- Insert Sales
-- ============================================

--  create Sale 1: Afif buys Apple and Laptop
INSERT INTO Sale (customer_id)
VALUES (1);
-- Store last auto-generated id
SET @sale_id = LAST_INSERT_ID();

-- Add items to Sale 1
INSERT INTO SaleItem (quantity, unit_price, sale_id, product_id)
VALUES
(
    2,
    (SELECT price FROM Product WHERE name='apple'),
    @sale_id,
    (SELECT product_id FROM Product WHERE name='apple')
),
(
    1,
    (SELECT price FROM Product WHERE name='Laptop'),
    @sale_id,
    (SELECT product_id FROM Product WHERE name='Laptop')
);


-- ============================================
-- Sale 2: Rana buys T-Shirt and Database Book
-- ============================================

INSERT INTO Sale (customer_id)
VALUES (2);
-- Store last auto-generated id
SET @sale_id = LAST_INSERT_ID();

-- Add items to Sale 2
INSERT INTO SaleItem (quantity, unit_price, sale_id, product_id)
VALUES
(
    3,
    (SELECT price FROM Product WHERE name='T-Shirt'),
    @sale_id,
    (SELECT product_id FROM Product WHERE name='T-Shirt')
),
(
    1,
    (SELECT price FROM Product WHERE name='Book'),
    @sale_id,
    (SELECT product_id FROM Product WHERE name='Book')
);


-- ============================================
-- Sale 3: Afif buys another product
-- ============================================

INSERT INTO Sale (customer_id)
VALUES (1);
-- Store last auto-generated id
SET @sale_id = LAST_INSERT_ID();

INSERT INTO SaleItem (quantity, unit_price, sale_id, product_id)
VALUES
(
    1,
    (SELECT price FROM Product WHERE name='Book'),
    @sale_id,
    (SELECT product_id FROM Product WHERE name='Book')
);
