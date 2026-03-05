# ============================================
# Inventory Sales System
# Python Console Application
# This program connects to MySQL database
# and uses:
# - Views
# - Stored Procedure
# - Triggers (automatically)
# Data is displayed using the tabulate library.
# ============================================

import mysql.connector
from tabulate import tabulate


# ============================================
# Function: Connect to the database
# This function creates and returns a new
# connection to the MySQL database.
# ============================================

def connect_db():
    return mysql.connector.connect(
        host="localhost",
        user="root",
        password="Mohammed1998",
        database="inventory_sales"
    )


# ============================================
# Function: Run SELECT query and display result
# This function executes a SELECT query and
# prints the result as a formatted table.
# ============================================

def run_query(query):
    connection = connect_db()
    cursor = connection.cursor()

    cursor.execute(query)
    results = cursor.fetchall()

    # Get column names dynamically
    columns = [column[0] for column in cursor.description]

    print()
    print(tabulate(results, headers=columns, tablefmt="grid"))
    print()

    connection.close()


# ============================================
# Function: Show all products
# Uses the view "product_overview"
# ============================================

def show_products():
    run_query("SELECT * FROM product_overview")


# ============================================
# Function: Show total amount per sale
# Uses the view "sale_totals"
# ============================================

def show_sale_totals():
    run_query("SELECT * FROM sale_totals")


# ============================================
# Function: Show total spending per customer
# Uses the view "customer_totals"
# ============================================

def show_customer_totals():
    run_query("SELECT * FROM customer_totals")


# ============================================
# Function: Show most purchased category per gender
# Uses the correlated subquery view
# "most_purchased_category_per_gender"
# ============================================

def show_most_purchased_category_per_gender():
    run_query("SELECT * FROM most_purchased_category_per_gender")


# ============================================
# Function: Create a new sale
# Calls the stored procedure "create_sale"
# Triggers will automatically:
# - Check stock before insert
# - Reduce stock after insert
# ============================================

def create_sale():
    connection = connect_db()
    cursor = connection.cursor()

    try:
        customer_id = input("Enter customer ID: ")
        product_id = input("Enter product ID: ")
        quantity = input("Enter quantity: ")

        # Call stored procedure
        cursor.execute(
            "CALL create_sale(%s, %s, %s)",
            (customer_id, product_id, quantity)
        )

        # Commit transaction
        connection.commit()

        print("\nSale created successfully!\n")

    except mysql.connector.Error as err:
        print("\nDatabase Error:", err)

    connection.close()


# ============================================
# Main Program Loop
# This loop keeps running until user exits
# ============================================

while True:
    print("\n=== Inventory Sales System ===")
    print("1 - Show Products")
    print("2 - Create Sale")
    print("3 - Show Sale Totals")
    print("4 - Show Customer Totals")
    print("5 - Show Most Purchased Category per Gender")
    print("6 - Exit")

    choice = input("Select option: ")

    if choice == "1":
        show_products()

    elif choice == "2":
        create_sale()

    elif choice == "3":
        show_sale_totals()

    elif choice == "4":
        show_customer_totals()

    elif choice == "5":
        show_most_purchased_category_per_gender()

    elif choice == "6":
        print("Exiting program...")
        break

    else:
        print("Invalid option. Please try again.")