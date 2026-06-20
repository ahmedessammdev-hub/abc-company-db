# E-Commerce Order Management System - SQL Tasks (Session 2)

This repository contains SQL scripts to design, populate, and query a database schema for ABC Inc.'s online store. The system manages customers, product categories, products, orders, order items, and payments.

## Database Schema

The database `ABC_ECommerce` consists of the following tables:
* **Categories**: Hierarchical category tree (Parent-child self-referential relationship) supporting multiple levels of depth.
* **Customers**: Registered customer information including emails and registration dates.
* **Products**: Product catalog linked to categories, maintaining stock levels and pricing rules.
* **Orders**: Purchase orders placed by customers, tracking fulfillment status.
* **OrderItems**: Many-to-many junction table between Orders and Products, capturing purchase prices and quantities.
* **Payments**: Order payments and transaction status ('Pending', 'Paid', 'Failed').
* **RestockAlerts**: Target log table containing products with stock below 10.
* **MonthlySalesAudit**: Archive table capturing monthly aggregates for executive performance reports.

## File Execution Order

To set up the environment and run all tasks, execute the scripts in the following order:
1. `01_create_tables.sql`: Builds the database schema, primary/foreign key relationships, and required User-Defined Table Types (UDTT).
2. `02_insert_data.sql`: Seeds the tables with realistic sample data using dynamic relative dates to guarantee reporting ranges are active.
3. `03_task_queries.sql`: Contains the solutions for all 18 tasks, complete with testing routines and verification blocks.

## Key Tasks & Concepts Implemented

### Part 1: Joins, Aggregation & Filtering
* **Tasks 1 - 4**: Complex left/inner joins, handling distinct counting to prevent duplicates, and utilizing conditional `CASE WHEN` and `DATEDIFF` logic.
* **Task 5**: Partitioning and rank ranking (`ROW_NUMBER() OVER PARTITION BY`) to pull top products per category.
* **Task 6 & 7**: Advanced analytics including window aggregates (`SUM OVER` for rolling totals) and average comparison subqueries.

### Part 2: CTEs, Views & Indexes
* **Task 8**: Date-comparison CTEs finding prompt customers (ordered within 7 days of registration).
* **Task 9**: Recursive CTE to trace arbitrary parent-child categories and assemble a breadcrumb category path (e.g. `Electronics > Mobiles > Smartphones`).
* **Task 10**: Summary views for high-performance retrieval of customer metrics.
* **Task 11**: Covering index design (`IX_OrderItems_ProductID_Covering`) to improve query plan performance.

### Part 3: Functions, Stored Procedures & Cursors
* **Task 12 & 13**: Safe scalar functions with condition checks and null handlers.
* **Task 14**: Inline Table-Valued Functions (iTVF) integrated with `CROSS APPLY` to render dynamic calendar month snaps.
* **Task 15**: ACID-compliant transaction-handling stored procedure `sp_place_order` executing multi-table operations (creation, inventory updates, payment logging) with comprehensive TRY/CATCH error handling and rollback.
* **Task 16**: Multi-result set Stored Procedure returning output parameters and record lists.
* **Task 17 & 18**: Iterative cursor workflows for automated stock alerting and historical performance audits.
