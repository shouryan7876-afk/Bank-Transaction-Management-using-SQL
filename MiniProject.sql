-- ============================================
-- BANKING SYSTEM - ADBMS MINI PROJECT
-- ============================================

DROP DATABASE IF EXISTS banking_system;
CREATE DATABASE banking_system;
USE banking_system;

-- ============================================
-- 1. CREATE TABLES
-- ============================================

CREATE TABLE customers (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(15) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE accounts (
    account_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT NOT NULL,
    account_type ENUM('Savings', 'Current') NOT NULL,
    balance DECIMAL(12, 2) DEFAULT 0.00,
    status ENUM('Active', 'Closed') DEFAULT 'Active',
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

CREATE TABLE transactions (
    transaction_id INT PRIMARY KEY AUTO_INCREMENT,
    account_id INT NOT NULL,
    transaction_type ENUM('Deposit', 'Withdrawal', 'Transfer') NOT NULL,
    amount DECIMAL(12, 2) NOT NULL,
    balance_after DECIMAL(12, 2) NOT NULL,
    transaction_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (account_id) REFERENCES accounts(account_id)
);

-- ============================================
-- 2. INSERT SAMPLE DATA
-- ============================================

INSERT INTO customers (name, email, phone) VALUES
('Rajesh Kumar', 'rajesh@email.com', '9876543210'),
('Priya Sharma', 'priya@email.com', '9876543211'),
('Amit Patel', 'amit@email.com', '9876543212');

INSERT INTO accounts (customer_id, account_type, balance) VALUES
(1, 'Savings', 50000.00),
(2, 'Current', 75000.00),
(3, 'Savings', 30000.00);

-- ============================================
-- 3. STORED PROCEDURES
-- ============================================

-- Deposit Money
DELIMITER $$
CREATE PROCEDURE sp_deposit(
    IN p_account_id INT,
    IN p_amount DECIMAL(12,2)
)
BEGIN
    DECLARE v_balance DECIMAL(12,2);
    
    START TRANSACTION;
    
    SELECT balance INTO v_balance 
    FROM accounts 
    WHERE account_id = p_account_id AND status = 'Active'
    FOR UPDATE;
    
    IF v_balance IS NULL THEN
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Account not found';
    END IF;
    
    IF p_amount <= 0 THEN
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Amount must be positive';
    END IF;
    
    SET v_balance = v_balance + p_amount;
    
    UPDATE accounts SET balance = v_balance WHERE account_id = p_account_id;
    
    INSERT INTO transactions (account_id, transaction_type, amount, balance_after)
    VALUES (p_account_id, 'Deposit', p_amount, v_balance);
    
    COMMIT;
    SELECT 'Deposit Successful' AS message, v_balance AS new_balance;
END$$
DELIMITER ;

-- Withdraw Money
DELIMITER $$
CREATE PROCEDURE sp_withdraw(
    IN p_account_id INT,
    IN p_amount DECIMAL(12,2)
)
BEGIN
    DECLARE v_balance DECIMAL(12,2);
    
    START TRANSACTION;
    
    SELECT balance INTO v_balance 
    FROM accounts 
    WHERE account_id = p_account_id AND status = 'Active'
    FOR UPDATE;
    
    IF v_balance IS NULL THEN
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Account not found';
    END IF;
    
    IF p_amount <= 0 THEN
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Amount must be positive';
    END IF;
    
    IF v_balance < p_amount THEN
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Insufficient balance';
    END IF;
    
    SET v_balance = v_balance - p_amount;
    
    UPDATE accounts SET balance = v_balance WHERE account_id = p_account_id;
    
    INSERT INTO transactions (account_id, transaction_type, amount, balance_after)
    VALUES (p_account_id, 'Withdrawal', p_amount, v_balance);
    
    COMMIT;
    SELECT 'Withdrawal Successful' AS message, v_balance AS new_balance;
END$$
DELIMITER ;

-- Transfer Money
DELIMITER $$
CREATE PROCEDURE sp_transfer(
    IN p_from_account INT,
    IN p_to_account INT,
    IN p_amount DECIMAL(12,2)
)
BEGIN
    DECLARE v_from_balance DECIMAL(12,2);
    DECLARE v_to_balance DECIMAL(12,2);
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SELECT 'Transfer Failed' AS message;
    END;
    
    START TRANSACTION;
    
    SELECT balance INTO v_from_balance 
    FROM accounts WHERE account_id = p_from_account FOR UPDATE;
    
    SELECT balance INTO v_to_balance 
    FROM accounts WHERE account_id = p_to_account FOR UPDATE;
    
    IF v_from_balance IS NULL OR v_to_balance IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Account not found';
    END IF;
    
    IF p_amount <= 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Amount must be positive';
    END IF;
    
    IF v_from_balance < p_amount THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Insufficient balance';
    END IF;
    
    SET v_from_balance = v_from_balance - p_amount;
    SET v_to_balance = v_to_balance + p_amount;
    
    UPDATE accounts SET balance = v_from_balance WHERE account_id = p_from_account;
    UPDATE accounts SET balance = v_to_balance WHERE account_id = p_to_account;
    
    INSERT INTO transactions (account_id, transaction_type, amount, balance_after)
    VALUES 
    (p_from_account, 'Transfer', p_amount, v_from_balance),
    (p_to_account, 'Deposit', p_amount, v_to_balance);
    
    COMMIT;
    SELECT 'Transfer Successful' AS message;
END$$
DELIMITER ;

-- ============================================
-- 4. FUNCTIONS
-- ============================================

DELIMITER $$
CREATE FUNCTION fn_get_balance(p_account_id INT)
RETURNS DECIMAL(12,2)
DETERMINISTIC READS SQL DATA
BEGIN
    DECLARE v_balance DECIMAL(12,2);
    SELECT balance INTO v_balance FROM accounts WHERE account_id = p_account_id;
    RETURN IFNULL(v_balance, 0);
END$$
DELIMITER ;

DELIMITER $$
CREATE FUNCTION fn_calculate_interest(p_amount DECIMAL(12,2), p_rate DECIMAL(5,2))
RETURNS DECIMAL(12,2)
DETERMINISTIC
BEGIN
    RETURN (p_amount * p_rate) / 100;
END$$
DELIMITER ;

-- ============================================
-- 5. TRIGGERS
-- ============================================

DELIMITER $$
CREATE TRIGGER trg_check_balance
BEFORE UPDATE ON accounts
FOR EACH ROW
BEGIN
    IF NEW.balance < 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Balance cannot be negative';
    END IF;
END$$
DELIMITER ;

CREATE TABLE transaction_log (
    log_id INT PRIMARY KEY AUTO_INCREMENT,
    account_id INT,
    action VARCHAR(50),
    amount DECIMAL(12,2),
    logged_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

DELIMITER $$
CREATE TRIGGER trg_log_transaction
AFTER INSERT ON transactions
FOR EACH ROW
BEGIN
    INSERT INTO transaction_log (account_id, action, amount)
    VALUES (NEW.account_id, NEW.transaction_type, NEW.amount);
END$$
DELIMITER ;

-- ============================================
-- 6. VIEWS
-- ============================================

CREATE VIEW vw_customer_summary AS
SELECT 
    c.customer_id,
    c.name,
    c.email,
    a.account_id,
    a.account_type,
    a.balance
FROM customers c
JOIN accounts a ON c.customer_id = a.customer_id
WHERE a.status = 'Active';

CREATE VIEW vw_transaction_history AS
SELECT 
    t.transaction_id,
    c.name AS customer_name,
    t.transaction_type,
    t.amount,
    t.balance_after,
    t.transaction_date
FROM transactions t
JOIN accounts a ON t.account_id = a.account_id
JOIN customers c ON a.customer_id = c.customer_id
ORDER BY t.transaction_date DESC;

-- ============================================
-- 7. TEST QUERIES
-- ============================================

-- View all accounts
SELECT * FROM vw_customer_summary;

-- Check balance
SELECT fn_get_balance(1) AS balance;

-- Deposit
CALL sp_deposit(1, 5000.00);

-- Withdraw
CALL sp_withdraw(2, 3000.00);

-- Transfer
CALL sp_transfer(1, 3, 10000.00);

-- View transactions
SELECT * FROM vw_transaction_history LIMIT 10;

-- Calculate interest
SELECT fn_calculate_interest(50000, 5) AS interest;

-- View logs
SELECT * FROM transaction_log;

-- Account statistics
SELECT 
    account_type,
    COUNT(*) AS total_accounts,
    SUM(balance) AS total_balance,
    AVG(balance) AS avg_balance
FROM accounts
WHERE status = 'Active'
GROUP BY account_type;


-- 1. Check initial balance
SELECT fn_get_balance(1); -- Returns: 50000

-- 2. Try overdraft (will fail)
CALL sp_withdraw(1, 60000); -- ❌ Error: Insufficient balance

-- 3. Valid withdrawal
CALL sp_withdraw(1, 5000); -- ✅ Success

-- 4. Check balance again
SELECT fn_get_balance(1); -- Returns: 45000

-- 5. See all transactions
SELECT * FROM vw_transaction_history;

-- 6. See automatic logs (created by trigger)
SELECT * FROM transaction_log;

-- 7. Try atomic transfer
CALL sp_transfer(1, 2, 10000); -- Either both accounts update or neither