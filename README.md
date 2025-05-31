# Bel Air Tandoori Restaurant Management System

A SQL database solution designed for Bel Air Tandoori restaurant in Besançon, France. This system manages customer information, menu items, orders, staff, and financial reporting to streamline restaurant operations.

##  About Bel Air Tandoori

Bel Air Tandoori is a beloved Indian restaurant located in Besançon, Bourgogne-Franche-Comté, specializing in authentic Indian cuisine and tandoori dishes. This database system was created to help modernize their operations and improve customer service.

##  Features

- **Customer Management**: Track customer information, preferences, and order history
- **Menu Management**: Organize dishes by categories, manage pricing and availability
- **Order Processing**: Handle dine-in, takeaway, and delivery orders
- **Staff Management**: Track employee information and roles
- **Inventory Control**: Monitor ingredient stock levels
- **Financial Reporting**: Generate sales reports and analyze performance
- **Table Management**: Track table occupancy and reservations

##  Database Schema

### Core Tables

1. **customers** - Customer information and contact details
2. **menu_categories** - Organization of menu items (Appetizers, Mains, Desserts, etc.)
3. **menu_items** - Individual dishes with pricing and descriptions
4. **staff** - Employee information and roles
5. **tables** - Restaurant table management
6. **orders** - Order tracking and status
7. **order_items** - Individual items within each order
8. **ingredients** - Inventory management for recipe ingredients
9. **suppliers** - Supplier information for procurement

### Key Relationships

- Orders are linked to customers and staff members
- Order items reference specific menu items
- Menu items can have multiple ingredients
- Tables can have multiple orders over time

##  Getting Started

### Prerequisites

- MySQL 8.0+ or PostgreSQL 12+
- SQL client (MySQL Workbench, pgAdmin, or command line)

### Installation

1. Clone this repository:
```bash
git clone https://github.com/yourusername/bel-air-tandoori-db.git
cd bel-air-tandoori-db
```

2. Create the database:
```sql
CREATE DATABASE bel_air_tandoori;
USE bel_air_tandoori;
```

3. Run the schema creation script:
```bash
mysql -u your_username -p bel_air_tandoori < schema.sql
```

4. Insert sample data:
```bash
mysql -u your_username -p bel_air_tandoori < sample_data.sql
```

##  Sample Queries

### Daily Sales Report
```sql
SELECT 
    DATE(order_date) as date,
    COUNT(*) as total_orders,
    SUM(total_amount) as daily_revenue
FROM orders 
WHERE order_date >= CURDATE() - INTERVAL 7 DAY
GROUP BY DATE(order_date)
ORDER BY date DESC;
```

### Most Popular Dishes
```sql
SELECT 
    mi.name,
    COUNT(oi.menu_item_id) as times_ordered,
    SUM(oi.quantity) as total_quantity
FROM order_items oi
JOIN menu_items mi ON oi.menu_item_id = mi.id
GROUP BY mi.id, mi.name
ORDER BY times_ordered DESC
LIMIT 10;
```

### Customer Order History
```sql
SELECT 
    c.name,
    c.phone,
    COUNT(o.id) as total_orders,
    SUM(o.total_amount) as total_spent
FROM customers c
LEFT JOIN orders o ON c.id = o.customer_id
GROUP BY c.id, c.name, c.phone
ORDER BY total_spent DESC;
```

##  File Structure

```
bel-air-tandoori-db/
├── README.md
├── schema.sql              # Database schema creation
├── sample_data.sql         # Sample data insertion
├── queries/
│   ├── daily_reports.sql   # Daily sales and performance queries
│   ├── menu_analysis.sql   # Menu item popularity and analysis
│   ├── customer_insights.sql # Customer behavior analysis
│   └── inventory_management.sql # Stock and supplier queries
├── views/
│   ├── customer_summary.sql    # Customer overview view
│   ├── daily_sales_summary.sql # Daily sales view
│   └── menu_with_categories.sql # Complete menu view
└── procedures/
    ├── place_order.sql     # Stored procedure for order placement
    ├── update_inventory.sql # Inventory update procedures
    └── generate_bill.sql   # Bill generation procedure
```

##  Key Procedures

### Place Order
Handles complete order placement including inventory updates and bill calculation.

### Generate Daily Report
Automated daily sales and performance reporting.

### Update Menu Prices
Bulk price updates with historical tracking.

##  Business Intelligence

The system includes several views and queries for business analysis:

- **Revenue Tracking**: Daily, weekly, and monthly sales analysis
- **Customer Segmentation**: Identify VIP customers and ordering patterns
- **Menu Optimization**: Track dish popularity and profitability
- **Staff Performance**: Monitor order processing efficiency
- **Inventory Alerts**: Low stock notifications and reorder points





---

*This database system was specifically designed to meet the operational needs of Bel Air Tandoori restaurant in Besançon, incorporating local business practices and French restaurant industry standards.*
