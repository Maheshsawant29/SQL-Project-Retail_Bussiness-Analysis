SQL Project : "Retail Optical Bussiness Analysis"
<br>
Status: 🚧 Project Work in Progress

👓 Retail Optical Business Intelligence System
1. Introduction
This project focuses on building a robust Relational Database Management System (RDBMS) for a Retail Optical Store. The goal is to track the complete customer journey—from the initial walk-in and eye checkup (prescription) to the final purchase (invoice) and post-sale delivery tracking. By bridging the gap between medical records and retail sales, this system provides deep insights into customer behavior, staff efficiency, and product performance.

2. Database Architecture
The database, retail_optical_bussiness, consists of 9 interconnected tables designed in 3rd Normal Form (3NF) to ensure data integrity and minimize redundancy.

Entity Relationship Summary
Core Entities: staff and customers_details form the foundation.

Medical Layer: The prescriptions table tracks clinical visits for each customer.

Product Layer: A hierarchical structure of products -> product_brand -> product_type allows for granular inventory and sales tracking.

Sales Layer: invoices and invoice_items capture transaction headers and line-item details.

Operations Layer: additional_customer_details tracks CRM metrics like delivery time and shop floor duration.

3. The Dataset
The data used in this project is synthetically generated using a custom Python seeding engine.

Scale: Over 35,000+ lines of SQL commands generating 8,000 customers, 8,000 prescriptions, and 5,000 invoices.

Realism: Utilized the Faker library to generate localized Indian names, contact numbers, and realistic date ranges spanning two years.

Integrity: The script was designed to respect all Foreign Key constraints and maintain logical relationships (e.g., ensuring a customer’s visit date precedes their delivery date).

4. Analysis Structure & Queries
The project is organized into modular SQL scripts to address specific business questions:

📂 queries/
01_exploratory_data_analysis.sql
02_customer_analysis.sql
03_sales_revenue_analysis.sql
04_product_analysis.sql
05_conversion_funnel.sql
06_staff_performance.sql
07_operational_metrics.sql
08_advanced_analytics.sql

5. Technology Stack
Database: MySQL (Relational Database Engine)

Data Engineering: Python (via VS Code)

Libraries: Faker (for synthetic data generation)

Version Control: GitHub (Project organization and documentation)

Interface: MySQL Workbench & CMD (for bulk data migration)

6. Disclaimer
This project is for educational and portfolio purposes only. All names, contact numbers, and transactional data are synthetically generated using the Python Faker library and do not represent any real individuals or businesses. No real-world PII (Personally Identifiable Information) is included
