-- ================================================
-- Bel Air Tandoori Restaurant Management System
-- Database Schema - MySQL/PostgreSQL Compatible
-- Created for Bel Air Tandoori, Besançon, France
-- ================================================

-- Create database (uncomment if needed)
-- CREATE DATABASE bel_air_tandoori;
-- USE bel_air_tandoori;

-- ================================================
-- CORE TABLES
-- ================================================

-- Customer Management
CREATE TABLE customers (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    phone VARCHAR(20) UNIQUE,
    email VARCHAR(100),
    address TEXT,
    city VARCHAR(50) DEFAULT 'Besançon',
    postal_code VARCHAR(10),
    date_registered DATETIME DEFAULT CURRENT_TIMESTAMP,
    is_vip BOOLEAN DEFAULT FALSE,
    total_orders INT DEFAULT 0,
    total_spent DECIMAL(10,2) DEFAULT 0.00,
    dietary_preferences TEXT,
    notes TEXT
);

-- Menu Categories
CREATE TABLE menu_categories (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50) NOT NULL,
    name_french VARCHAR(50),
    description TEXT,
    display_order INT DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE
);

-- Menu Items
CREATE TABLE menu_items (
    id INT PRIMARY KEY AUTO_INCREMENT,
    category_id INT NOT NULL,
    name VARCHAR(100) NOT NULL,
    name_french VARCHAR(100),
    description TEXT,
    price DECIMAL(8,2) NOT NULL,
    cost DECIMAL(8,2),
    is_vegetarian BOOLEAN DEFAULT FALSE,
    is_vegan BOOLEAN DEFAULT FALSE,
    is_spicy BOOLEAN DEFAULT FALSE,
    spice_level ENUM('Mild', 'Medium', 'Hot', 'Very Hot') DEFAULT 'Mild',
    is_available BOOLEAN DEFAULT TRUE,
    preparation_time INT DEFAULT 15, -- minutes
    calories INT,
    allergens TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id) REFERENCES menu_categories(id)
);

-- Staff Management
CREATE TABLE staff (
    id INT PRIMARY KEY AUTO_INCREMENT,
    employee_id VARCHAR(20) UNIQUE NOT NULL,
    name VARCHAR(100) NOT NULL,
    role ENUM('Manager', 'Chef', 'Server', 'Cashier', 'Delivery') NOT NULL,
    phone VARCHAR(20),
    email VARCHAR(100),
    hire_date DATE NOT NULL,
    hourly_rate DECIMAL(6,2),
    is_active BOOLEAN DEFAULT TRUE,
    permissions TEXT -- JSON string for role permissions
);

-- Table Management
CREATE TABLE tables (
    id INT PRIMARY KEY AUTO_INCREMENT,
    table_number VARCHAR(10) NOT NULL UNIQUE,
    capacity INT NOT NULL,
    location ENUM('Indoor', 'Outdoor', 'Private') DEFAULT 'Indoor',
    is_available BOOLEAN DEFAULT TRUE,
    notes TEXT
);

-- Order Management
CREATE TABLE orders (
    id INT PRIMARY KEY AUTO_INCREMENT,
    order_number VARCHAR(20) UNIQUE NOT NULL,
    customer_id INT,
    staff_id INT NOT NULL,
    table_id INT,
    order_type ENUM('Dine-in', 'Takeaway', 'Delivery') NOT NULL,
    order_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    promised_time DATETIME,
    completed_time DATETIME,
    status ENUM('Pending', 'Confirmed', 'Preparing', 'Ready', 'Served', 'Completed', 'Cancelled') DEFAULT 'Pending',
    subtotal DECIMAL(10,2) NOT NULL,
    tax_amount DECIMAL(10,2) NOT NULL,
    discount_amount DECIMAL(10,2) DEFAULT 0.00,
    total_amount DECIMAL(10,2) NOT NULL,
    payment_method ENUM('Cash', 'Card', 'Mobile', 'Online') DEFAULT 'Cash',
    payment_status ENUM('Pending', 'Paid', 'Refunded') DEFAULT 'Pending',
    delivery_address TEXT,
    special_instructions TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES customers(id),
    FOREIGN KEY (staff_id) REFERENCES staff(id),
    FOREIGN KEY (table_id) REFERENCES tables(id)
);

-- Order Items
CREATE TABLE order_items (
    id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT NOT NULL,
    menu_item_id INT NOT NULL,
    quantity INT NOT NULL DEFAULT 1,
    unit_price DECIMAL(8,2) NOT NULL,
    total_price DECIMAL(10,2) NOT NULL,
    special_requests TEXT,
    status ENUM('Ordered', 'Preparing', 'Ready', 'Served') DEFAULT 'Ordered',
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
    FOREIGN KEY (menu_item_id) REFERENCES menu_items(id)
);

-- ================================================
-- INVENTORY MANAGEMENT
-- ================================================

-- Suppliers
CREATE TABLE suppliers (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    contact_person VARCHAR(100),
    phone VARCHAR(20),
    email VARCHAR(100),
    address TEXT,
    city VARCHAR(50),
    payment_terms VARCHAR(50),
    is_active BOOLEAN DEFAULT TRUE,
    notes TEXT
);

-- Ingredients/Inventory
CREATE TABLE ingredients (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    category VARCHAR(50),
    unit VARCHAR(20) NOT NULL, -- kg, liters, pieces, etc.
    current_stock DECIMAL(10,3) NOT NULL DEFAULT 0,
    minimum_stock DECIMAL(10,3) NOT NULL DEFAULT 0,
    cost_per_unit DECIMAL(8,2),
    supplier_id INT,
    last_restocked DATE,
    expiry_date DATE,
    storage_location VARCHAR(50),
    is_active BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (supplier_id) REFERENCES suppliers(id)
);

-- Menu Item Ingredients (Recipe Management)
CREATE TABLE menu_item_ingredients (
    id INT PRIMARY KEY AUTO_INCREMENT,
    menu_item_id INT NOT NULL,
    ingredient_id INT NOT NULL,
    quantity_required DECIMAL(8,3) NOT NULL,
    notes TEXT,
    FOREIGN KEY (menu_item_id) REFERENCES menu_items(id) ON DELETE CASCADE,
    FOREIGN KEY (ingredient_id) REFERENCES ingredients(id)
);

-- ================================================
-- FINANCIAL TRACKING
-- ================================================

-- Daily Sales Summary
CREATE TABLE daily_sales (
    id INT PRIMARY KEY AUTO_INCREMENT,
    sale_date DATE NOT NULL UNIQUE,
    total_orders INT DEFAULT 0,
    total_revenue DECIMAL(12,2) DEFAULT 0.00,
    total_tax DECIMAL(10,2) DEFAULT 0.00,
    cash_sales DECIMAL(10,2) DEFAULT 0.00,
    card_sales DECIMAL(10,2) DEFAULT 0.00,
    dine_in_orders INT DEFAULT 0,
    takeaway_orders INT DEFAULT 0,
    delivery_orders INT DEFAULT 0,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Customer Reviews (Optional)
CREATE TABLE reviews (
    id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT,
    order_id INT,
    rating INT CHECK (rating >= 1 AND rating <= 5),
    comment TEXT,
    review_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    is_public BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (customer_id) REFERENCES customers(id),
    FOREIGN KEY (order_id) REFERENCES orders(id)
);

-- ================================================
-- INDEXES FOR PERFORMANCE
-- ================================================

-- Customer indexes
CREATE INDEX idx_customers_phone ON customers(phone);
CREATE INDEX idx_customers_email ON customers(email);
CREATE INDEX idx_customers_city ON customers(city);

-- Order indexes
CREATE INDEX idx_orders_date ON orders(order_date);
CREATE INDEX idx_orders_status ON orders(status);
CREATE INDEX idx_orders_customer ON orders(customer_id);
CREATE INDEX idx_orders_type ON orders(order_type);
CREATE INDEX idx_orders_number ON orders(order_number);

-- Menu item indexes
CREATE INDEX idx_menu_items_category ON menu_items(category_id);
CREATE INDEX idx_menu_items_available ON menu_items(is_available);
CREATE INDEX idx_menu_items_price ON menu_items(price);

-- Order items indexes
CREATE INDEX idx_order_items_order ON order_items(order_id);
CREATE INDEX idx_order_items_menu ON order_items(menu_item_id);

-- Inventory indexes
CREATE INDEX idx_ingredients_stock ON ingredients(current_stock);
CREATE INDEX idx_ingredients_category ON ingredients(category);

-- ================================================
-- VIEWS FOR COMMON QUERIES
-- ================================================

-- Complete menu with categories
CREATE VIEW menu_with_categories AS
SELECT 
    mi.id,
    mi.name,
    mi.name_french,
    mi.description,
    mi.price,
    mi.is_vegetarian,
    mi.is_vegan,
    mi.spice_level,
    mi.is_available,
    mc.name as category_name,
    mc.name_french as category_name_french
FROM menu_items mi
JOIN menu_categories mc ON mi.category_id = mc.id
WHERE mi.is_available = TRUE AND mc.is_active = TRUE
ORDER BY mc.display_order, mi.name;

-- Customer order summary
CREATE VIEW customer_summary AS
SELECT 
    c.id,
    c.name,
    c.phone,
    c.email,
    c.is_vip,
    COUNT(o.id) as total_orders,
    COALESCE(SUM(o.total_amount), 0) as total_spent,
    MAX(o.order_date) as last_order_date,
    AVG(o.total_amount) as average_order_value
FROM customers c
LEFT JOIN orders o ON c.id = o.customer_id AND o.status = 'Completed'
GROUP BY c.id, c.name, c.phone, c.email, c.is_vip;

-- Daily sales summary view
CREATE VIEW daily_revenue AS
SELECT 
    DATE(order_date) as sale_date,
    COUNT(*) as total_orders,
    SUM(total_amount) as total_revenue,
    SUM(tax_amount) as total_tax,
    SUM(CASE WHEN payment_method = 'Cash' THEN total_amount ELSE 0 END) as cash_sales,
    SUM(CASE WHEN payment_method = 'Card' THEN total_amount ELSE 0 END) as card_sales,
    COUNT(CASE WHEN order_type = 'Dine-in' THEN 1 END) as dine_in_orders,
    COUNT(CASE WHEN order_type = 'Takeaway' THEN 1 END) as takeaway_orders,
    COUNT(CASE WHEN order_type = 'Delivery' THEN 1 END) as delivery_orders
FROM orders 
WHERE status = 'Completed' 
GROUP BY DATE(order_date)
ORDER BY sale_date DESC;

-- ================================================
-- TRIGGERS FOR AUTOMATION
-- ================================================

-- Update customer totals when order is completed
DELIMITER //
CREATE TRIGGER update_customer_stats 
AFTER UPDATE ON orders
FOR EACH ROW
BEGIN
    IF NEW.status = 'Completed' AND OLD.status != 'Completed' THEN
        UPDATE customers 
        SET 
            total_orders = total_orders + 1,
            total_spent = total_spent + NEW.total_amount
        WHERE id = NEW.customer_id;
    END IF;
END//
DELIMITER ;

-- Auto-generate order numbers
DELIMITER //
CREATE TRIGGER generate_order_number
BEFORE INSERT ON orders
FOR EACH ROW
BEGIN
    IF NEW.order_number IS NULL OR NEW.order_number = '' THEN
        SET NEW.order_number = CONCAT('BA', DATE_FORMAT(NOW(), '%Y%m%d'), '-', LPAD(LAST_INSERT_ID() + 1, 4, '0'));
    END IF;
END//
DELIMITER ;

-- ================================================
-- SAMPLE DATA (Basic Setup)
-- ================================================

-- Insert menu categories
INSERT INTO menu_categories (name, name_french, description, display_order) VALUES
('Appetizers', 'Entrées', 'Start your meal with our delicious appetizers', 1),
('Tandoori Specialties', 'Spécialités Tandoori', 'Fresh from our tandoori oven', 2),
('Curry Dishes', 'Plats au Curry', 'Authentic Indian curries', 3),
('Biryani & Rice', 'Biryani et Riz', 'Aromatic rice dishes', 4),
('Breads', 'Pains', 'Fresh baked Indian breads', 5),
('Desserts', 'Desserts', 'Sweet endings to your meal', 6),
('Beverages', 'Boissons', 'Refreshing drinks', 7);

-- Insert basic staff
INSERT INTO staff (employee_id, name, role, phone, hire_date, hourly_rate) VALUES
('MGR001', 'Rajesh Kumar', 'Manager', '+33381234567', '2023-01-15', 18.00),
('CHF001', 'Priya Sharma', 'Chef', '+33381234568', '2023-02-01', 16.00),
('SRV001', 'Marie Dubois', 'Server', '+33381234569', '2023-03-01', 12.00),
('CSH001', 'Jean Martin', 'Cashier', '+33381234570', '2023-03-15', 11.50);

-- Insert tables
INSERT INTO tables (table_number, capacity, location) VALUES
('T01', 2, 'Indoor'),
('T02', 4, 'Indoor'),
('T03', 4, 'Indoor'),
('T04', 6, 'Indoor'),
('T05', 8, 'Indoor'),
('P01', 4, 'Outdoor'),
('P02', 6, 'Outdoor');

-- Basic menu items (sample)
INSERT INTO menu_items (category_id, name, name_french, description, price, is_vegetarian, spice_level) VALUES
(1, 'Chicken Tikka', 'Tikka de Poulet', 'Tender chicken pieces marinated in spices', 12.50, FALSE, 'Medium'),
(1, 'Vegetable Samosa', 'Samosa aux Légumes', 'Crispy pastry filled with spiced vegetables', 6.50, TRUE, 'Mild'),
(2, 'Tandoori Chicken', 'Poulet Tandoori', 'Half chicken marinated and cooked in tandoor', 18.90, FALSE, 'Medium'),
(2, 'Paneer Tikka', 'Tikka Paneer', 'Cottage cheese cubes grilled in tandoor', 14.50, TRUE, 'Mild'),
(3, 'Butter Chicken', 'Poulet au Beurre', 'Creamy tomato-based chicken curry', 16.90, FALSE, 'Mild'),
(3, 'Palak Paneer', 'Épinards au Paneer', 'Cottage cheese in creamy spinach curry', 13.90, TRUE, 'Mild'),
(4, 'Chicken Biryani', 'Biryani de Poulet', 'Aromatic basmati rice with spiced chicken', 17.50, FALSE, 'Medium'),
(5, 'Garlic Naan', 'Naan à l\'Ail', 'Fresh bread with garlic and herbs', 4.50, TRUE, 'Mild'),
(6, 'Gulab Jamun', 'Gulab Jamun', 'Sweet milk dumplings in syrup', 6.50, TRUE, 'Mild'),
(7, 'Mango Lassi', 'Lassi à la Mangue', 'Sweet yogurt drink with mango', 4.90, TRUE, 'Mild');

-- ================================================
-- END OF SCHEMA
-- ================================================

-- Grant appropriate permissions (adjust as needed)
-- GRANT SELECT, INSERT, UPDATE, DELETE ON bel_air_tandoori.* TO 'restaurant_user'@'localhost';
-- FLUSH PRIVILEGES;

-- Success message
SELECT 'Bel Air Tandoori database schema created successfully!' as Status;
