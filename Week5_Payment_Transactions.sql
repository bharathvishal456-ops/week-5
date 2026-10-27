-- Week 5: Payment Transaction Management System (MySQL)
-- Uses the Week 4 Order Management System tables.
CREATE DATABASE IF NOT EXISTS order_management_db;
USE order_management_db;

-- Create Payment table. Orders must already exist in this database.
CREATE TABLE IF NOT EXISTS Payment (
    Payment_ID INT PRIMARY KEY AUTO_INCREMENT,
    Order_ID INT NOT NULL UNIQUE,
    Payment_Date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    Payment_Mode VARCHAR(30) NOT NULL
        CHECK (Payment_Mode IN ('UPI','Credit Card','Debit Card','Net Banking','Cash on Delivery')),
    Payment_Status VARCHAR(20) NOT NULL DEFAULT 'Pending'
        CHECK (Payment_Status IN ('Pending','Success','Failed')),
    Transaction_Amount DECIMAL(10,2) NOT NULL CHECK (Transaction_Amount > 0),
    FOREIGN KEY (Order_ID) REFERENCES Orders(Order_ID) ON DELETE CASCADE
);

-- Sample payment data (Order_ID values must exist in Orders)
INSERT INTO Payment (Order_ID, Payment_Mode, Payment_Status, Transaction_Amount) VALUES
(1,'UPI','Success',1200.00),
(2,'Credit Card','Success',9000.00),
(3,'Debit Card','Failed',1500.00),
(4,'Cash on Delivery','Pending',1650.00);

-- Insert a new payment transaction for an order without a payment record.
-- Change Order_ID and amount to match an existing order.
-- INSERT INTO Payment (Order_ID, Payment_Mode, Payment_Status, Transaction_Amount)
-- VALUES (5, 'Net Banking', 'Pending', 2500.00);

-- Display all successful payments
SELECT * FROM Payment WHERE Payment_Status = 'Success';

-- Find failed and pending transactions
SELECT * FROM Payment WHERE Payment_Status IN ('Failed','Pending');

-- Retrieve payment details for a specific order
SELECT * FROM Payment WHERE Order_ID = 1;

-- Update payment status after a transaction retry
UPDATE Payment
SET Payment_Status = 'Success',
    Payment_Mode = 'Debit Card',
    Payment_Date = CURRENT_TIMESTAMP
WHERE Order_ID = 3;

-- Count successful and failed payments
SELECT Payment_Status, COUNT(*) AS Transaction_Count
FROM Payment
WHERE Payment_Status IN ('Success','Failed')
GROUP BY Payment_Status;

-- Display payment details with customer and order information
SELECT p.Payment_ID, o.Order_ID, c.Customer_Name, c.Email,
       o.Order_Date, o.Order_Status, p.Payment_Date,
       p.Payment_Mode, p.Payment_Status, p.Transaction_Amount
FROM Payment p
JOIN Orders o ON p.Order_ID = o.Order_ID
JOIN Customer c ON o.Customer_ID = c.Customer_ID
ORDER BY p.Payment_ID;

-- Number of transactions by payment mode
SELECT Payment_Mode, COUNT(*) AS Transaction_Count
FROM Payment
GROUP BY Payment_Mode
ORDER BY Transaction_Count DESC;

-- Most preferred payment method (returns ties)
SELECT Payment_Mode, COUNT(*) AS Transaction_Count
FROM Payment
GROUP BY Payment_Mode
HAVING COUNT(*) = (
    SELECT MAX(mode_count)
    FROM (
        SELECT COUNT(*) AS mode_count
        FROM Payment
        GROUP BY Payment_Mode
    ) AS mode_counts
);

-- Total successful payment revenue
SELECT COALESCE(SUM(Transaction_Amount), 0) AS Successful_Payment_Revenue
FROM Payment
WHERE Payment_Status = 'Success';

-- Revenue by payment method (successful payments only)
SELECT Payment_Mode, SUM(Transaction_Amount) AS Successful_Revenue
FROM Payment
WHERE Payment_Status = 'Success'
GROUP BY Payment_Mode
ORDER BY Successful_Revenue DESC;

-- Average transaction amount
SELECT AVG(Transaction_Amount) AS Average_Transaction_Amount
FROM Payment;

-- Customer payment history
SELECT c.Customer_ID, c.Customer_Name, o.Order_ID, p.Payment_ID,
       p.Payment_Date, p.Payment_Mode, p.Payment_Status, p.Transaction_Amount
FROM Customer c
JOIN Orders o ON c.Customer_ID = o.Customer_ID
LEFT JOIN Payment p ON o.Order_ID = p.Order_ID
ORDER BY c.Customer_ID, o.Order_ID;

-- Count successful, failed and pending transactions (including zero counts)
SELECT s.Payment_Status, COUNT(p.Payment_ID) AS Transaction_Count
FROM (
    SELECT 'Success' AS Payment_Status
    UNION ALL SELECT 'Failed'
    UNION ALL SELECT 'Pending'
) s
LEFT JOIN Payment p ON p.Payment_Status = s.Payment_Status
GROUP BY s.Payment_Status;

-- Orders with failed or pending payments
SELECT o.Order_ID, c.Customer_Name, o.Total_Amount,
       p.Payment_Mode, p.Payment_Status, p.Transaction_Amount
FROM Orders o
JOIN Customer c ON o.Customer_ID = c.Customer_ID
JOIN Payment p ON o.Order_ID = p.Order_ID
WHERE p.Payment_Status IN ('Failed','Pending');

-- Update a payment record
UPDATE Payment
SET Payment_Status = 'Pending'
WHERE Payment_ID = 3;

-- Delete a payment record (example; use only if required)
-- DELETE FROM Payment WHERE Payment_ID = 10;
