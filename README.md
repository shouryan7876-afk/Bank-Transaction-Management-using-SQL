# Bank-Transaction-Management-using-SQL
This ADBMS-based Banking Management System manages customers, accounts, and transactions securely. It supports deposits, withdrawals, transfers, and balance checks while enforcing ACID properties. Using stored procedures, triggers, functions, and views, the system ensures data integrity, automation, accuracy, and secure audit logging.


🚀 Features

👤 Customer Management

💳 Account Creation & Management

💰 Deposit, Withdraw & Transfer Funds

🔐 Real-time Balance Validation

📑 Auto-Generated Transaction Logs

✅ ACID Transactions (Commit/Rollback)

⚙️ Stored Procedures & Functions

🔔 Triggers for Data Integrity & Logging

📊 Views for Summary & Reports

🛠️ Technologies Used
Component	Technology
Database	MySQL (MariaDB compatible)
Query Language	SQL
Tools	MySQL Workbench / XAMPP / phpMyAdmin
Concepts	ADBMS, Stored Procedures, Triggers, Views, Transactions

📂 Database Modules
Module	Description
Customers	Stores customer details
Accounts	Tracks balances & account type
Transactions	Stores all banking transactions
Transaction Log	Auto-logs every operation

🧾 ADBMS Concepts Implemented
Stored Procedures: Deposit, Withdraw, Transfer
Triggers: Balance validation & action logging
Functions: Balance retrieval, interest calculation
Views: Customer summary, transaction history
Transactions: START TRANSACTION, COMMIT, ROLLBACK
Concurrency Control: Row locking with FOR UPDATE

📦 Setup Instructions
Install MySQL or XAMPP
Open MySQL Workbench / phpMyAdmin
Run the SQL script provided in banking_system.sql
Execute the test commands at bottom of script

✅ Output Highlights
Successful transaction messages
Updated account balances
Transaction logs auto-created
Error alerts for invalid transactions (e.g., insufficient funds, negative balance)

📈 Future Enhancements
Web / Mobile interface
User role management (Admin/Customer)
ATM simulation module
Multi-branch distributed DB support
Automated interest calculation scheduler

🧠 Learning Outcomes
Understanding of real-world banking DB design
Strong experience with SQL procedures & triggers
Implementation of ACID principles & concurrency control
Working knowledge of data integrity & audit trails

👨‍🏫 Authors & Acknowledgment
Developed as a mini-project for ADBMS coursework to demonstrate real-time banking operations and advanced SQL concepts.

📜 License
Free to use for academic and learning purposes.
