-- Create Database
CREATE DATABASE IF NOT EXISTS inventory_sales
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;

-- Use Database
USE inventory_sales;

-- =====================
-- Category
-- =====================
CREATE TABLE Category (
    category_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE
);

-- =====================
-- Supplier
-- =====================
CREATE TABLE Supplier (
   supplier_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
   name VARCHAR(100) NOT NULL UNIQUE,
   email VARCHAR(100)
);

-- =====================
-- Product
-- =====================
CREATE TABLE Product (
  product_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  price DECIMAL(10,2) NOT NULL,
  stock_qty INT NOT NULL DEFAULT 0,
  category_id INT NOT NULL,
  supplier_id INT NOT NULL,
  FOREIGN KEY(category_id)REFERENCES Category(category_id),
  FOREIGN KEY(supplier_id)REFERENCES Supplier(supplier_id)
  
);

-- =====================
-- Customer
-- =====================
CREATE TABLE Customer (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    city VARCHAR(100),
    gender ENUM('Male', 'Female') NOT NULL,
    UNIQUE(name, city) -- prevents duplicate same person in same city
);

-- =====================
-- Sale
-- =====================
CREATE TABLE Sale (
    sale_id INT AUTO_INCREMENT PRIMARY KEY,
    sale_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    customer_id INT,
    FOREIGN KEY (customer_id) REFERENCES Customer(customer_id)
);

-- =====================
-- SaleItem
-- =====================
CREATE TABLE SaleItem (
    sale_item_id INT AUTO_INCREMENT PRIMARY KEY,
    quantity INT NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    sale_id INT NOT NULL,
    product_id INT NOT NULL,
    FOREIGN KEY (sale_id) REFERENCES Sale(sale_id),
    FOREIGN KEY (product_id) REFERENCES Product(product_id)
);


