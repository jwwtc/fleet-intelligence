-- Fleet Intelligence Platform Schema
-- Enhanced with operational intelligence capabilities
-- Database: vehicle_rental_db

-- Clean up existing tables if they exist
DROP TABLE IF EXISTS operational_events CASCADE;
DROP TABLE IF EXISTS performance_metrics CASCADE;
DROP TABLE IF EXISTS transactions CASCADE;
DROP TABLE IF EXISTS vehicles CASCADE;
DROP TABLE IF EXISTS categories CASCADE;
DROP TABLE IF EXISTS customers CASCADE;
DROP TABLE IF EXISTS salespersons CASCADE;
DROP TABLE IF EXISTS stores CASCADE;
DROP TABLE IF EXISTS regions CASCADE;

-- =============================================
-- Core Operations Tables
-- =============================================

-- 1. Regions Table (Geographic Divisions)
-- This table has no foreign keys, so we create it first
CREATE TABLE regions (
    region_id SERIAL PRIMARY KEY,
    region_name VARCHAR(50) NOT NULL UNIQUE,
    regional_manager VARCHAR(100) NOT NULL
);

-- 2. Stores Table (Branch Locations)
-- References regions table, so must come after regions
CREATE TABLE stores (
    store_id SERIAL PRIMARY KEY,
    store_name VARCHAR(100) NOT NULL,
    address VARCHAR(200) NOT NULL,
    city VARCHAR(50) NOT NULL,
    state CHAR(2) NOT NULL,
    zip VARCHAR(10) NOT NULL,
    region_id INTEGER NOT NULL,
    manager_name VARCHAR(100) NOT NULL,
    FOREIGN KEY (region_id) REFERENCES regions(region_id)
);

-- 3. Categories

CREATE TABLE categories (
    category_id SERIAL PRIMARY KEY,
    category_name VARCHAR(50) NOT NULL UNIQUE,
    description VARCHAR(200) NOT NULL
);

-- 4. Vehicles  

CREATE TABLE vehicles (
    vehicle_id SERIAL PRIMARY KEY,
    model_name VARCHAR(100) NOT NULL,
    category_id INTEGER NOT NULL,
    price_per_day DECIMAL(10,2) NOT NULL,
    current_inventory INTEGER NOT NULL,
    total_inventory INTEGER NOT NULL,
    last_rental_date DATE,
    FOREIGN KEY (category_id) REFERENCES categories(category_id)
);

-- 5. Customers
CREATE TABLE customers (
    customer_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone VARCHAR(20),
    address_line VARCHAR(200),
    city VARCHAR(50),
    state CHAR(2),
    zip VARCHAR(10),
    customer_type VARCHAR(20) NOT NULL CHECK (customer_type IN ('individual', 'business')),
    registration_date DATE NOT NULL DEFAULT CURRENT_DATE,
    total_spent DECIMAL(12,2) DEFAULT 0.00
);

-- 6. Salespersons
CREATE TABLE salespersons (
    salesperson_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    store_id INTEGER NOT NULL,
    hire_date DATE NOT NULL DEFAULT CURRENT_DATE,
    total_sales DECIMAL(12,2) DEFAULT 0.00,
    FOREIGN KEY (store_id) REFERENCES stores(store_id)
);

-- 7. Transactions

CREATE TABLE transactions (
    transaction_id SERIAL PRIMARY KEY,
    customer_id INTEGER NOT NULL,
    vehicle_id INTEGER NOT NULL,
    salesperson_id INTEGER NOT NULL,
    store_id INTEGER NOT NULL,
    rental_date DATE NOT NULL DEFAULT CURRENT_DATE,
    return_date DATE,
    quantity INTEGER NOT NULL DEFAULT 1 CHECK (quantity > 0),
    total_amount DECIMAL(10,2) NOT NULL,
    status VARCHAR(20) NOT NULL CHECK (status IN ('active', 'completed', 'cancelled')),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (vehicle_id) REFERENCES vehicles(vehicle_id),
    FOREIGN KEY (salesperson_id) REFERENCES salespersons(salesperson_id),
    FOREIGN KEY (store_id) REFERENCES stores(store_id),
    CHECK (return_date IS NULL OR return_date >= rental_date)
);

-- 8. operational_events

CREATE TABLE operational_events(
    event_id SERIAL PRIMARY KEY,
    event_type VARCHAR(20) NOT NULL CHECK (event_type IN ('anomaly', 'maintenance', 'demand_surge', 'fraud_risk')),
    entity_type VARCHAR(20) NOT NULL CHECK (entity_type IN ('vehicle', 'customer', 'store', 'transaction')),
    entity_id INTEGER NOT NULL,
    severity VARCHAR(20) NOT NULL CHECK (severity IN ('low', 'medium', 'high', 'critical')),
    detected_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    details JSON,
    resolved BOOLEAN NOT NULL DEFAULT FALSE
);

-- 9. Performance Metrics
CREATE TABLE performance_metrics (
    metric_date DATE NOT NULL,
    store_id INTEGER NOT NULL,
    revenue DECIMAL(12,2) DEFAULT 0.00,
    utilization_rate DECIMAL(3,2) DEFAULT 0.00 CHECK (utilization_rate BETWEEN 0 AND 1),
    avg_rental_duration DECIMAL(5,2) DEFAULT 0.00,
    maintenance_costs DECIMAL(10,2) DEFAULT 0.00,
    customer_satisfaction_score DECIMAL(3,2) DEFAULT 0.00 CHECK (customer_satisfaction_score BETWEEN 0 AND 5),
    demand_forecast_next_7d INTEGER DEFAULT 0,
    PRIMARY KEY (metric_date, store_id),
    FOREIGN KEY (store_id) REFERENCES stores(store_id)
);