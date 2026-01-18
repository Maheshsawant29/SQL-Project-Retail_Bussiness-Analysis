SQL Project : "Retail Optical Bussiness Analysis"
<br>
Status: 🚧 Project Work in Progress

👓 Retail Optical Business Intelligence System
1. Introduction

This project focuses on designing and implementing a Relational Database Management System (RDBMS) for a retail optical store. The primary objective is to track the complete customer journey from initial walk-in and eye checkup (prescription) to final purchase (invoice) and post-sale delivery tracking. By integrating clinical records with retail sales data, the system enables comprehensive analysis of customer behavior, staff performance, and product-level outcomes.

2. Database Architecture

The database, retail_optical_bussiness, consists of nine interconnected tables, designed in Third Normal Form (3NF) to ensure data integrity, eliminate redundancy, and support scalable analytics.

Entity Relationship Summary

Core Entities: staff and customers_details form the foundational layer.

Medical Layer: The prescriptions table captures clinical visit and eye checkup data.

Product Layer: A hierarchical structure—products → product_brand → product_type—enables granular inventory and sales analysis.

Sales Layer: invoices and invoice_items store transaction-level and line-item details.

Operations Layer: additional_customer_details tracks CRM-related metrics such as delivery timelines and in-store duration.

3. About the Dataset

The dataset used in this project is synthetically generated using a custom Python-based data seeding engine.

Scale: Over 35,000+ SQL statements, generating approximately 8,000 customers, 8,000 prescriptions, and 5,000 invoices.

Realism: The Faker library was used to generate localized Indian names, contact numbers, and realistic date ranges spanning two years.

Integrity: All data generation logic respects foreign key constraints and real-world sequencing (e.g., visit dates preceding delivery dates).

4. Analysis Structure & Queries

The analytical workflow is organized into modular SQL scripts, each addressing a specific business objective:

queries/
├── 01_exploratory_data_analysis.sql
├── 02_customer_analysis.sql
├── 03_sales_revenue_analysis.sql
├── 04_product_analysis.sql
├── 05_conversion_funnel.sql
├── 06_staff_performance.sql
├── 07_operational_metrics.sql
└── 08_advanced_analytics.sql


5. Technology Stack

Database: MySQL

Data Engineering: Python (VS Code)

Libraries: Faker (synthetic data generation)

Version Control: GitHub

Interface: MySQL Workbench and Command Line (CMD) for bulk data operations

6. Disclaimer

This project is intended solely for educational and portfolio purposes. All names, contact details, and transactional records are synthetically generated using the Faker library and do not correspond to real individuals or businesses. No real-world Personally Identifiable Information (PII) is included.
