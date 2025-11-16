-- Fleet Intelligence Platform - Seed Data
-- Contains realistic operational data with hidden patterns for anomaly detection
-- Includes: fraud patterns, maintenance issues, demand surges

-- Clear existing data (in reverse order of foreign key dependencies)
TRUNCATE TABLE performance_metrics CASCADE;
TRUNCATE TABLE operational_events CASCADE;
TRUNCATE TABLE transactions CASCADE;
TRUNCATE TABLE salespersons CASCADE;
TRUNCATE TABLE customers CASCADE;
TRUNCATE TABLE vehicles CASCADE;
TRUNCATE TABLE categories CASCADE;
TRUNCATE TABLE stores CASCADE;
TRUNCATE TABLE regions CASCADE;

-- =============================================
-- Basic Setup Data
-- =============================================

-- Regions (5 major regions)
INSERT INTO regions (region_name, regional_manager) VALUES
('Northeast', 'Sarah Johnson'),
('Southeast', 'Michael Chen'),
('Midwest', 'Robert Williams'),
('West Coast', 'Lisa Martinez'),
('Southwest', 'David Anderson');

-- Stores (2-3 per region)
INSERT INTO stores (store_name, address, city, state, zip, region_id, manager_name) VALUES
-- Northeast
('Manhattan Hub', '123 5th Avenue', 'New York', 'NY', '10001', 1, 'John Smith'),
('Boston Downtown', '456 State Street', 'Boston', 'MA', '02109', 1, 'Emma Davis'),
-- Southeast  
('Miami Beach', '789 Ocean Drive', 'Miami', 'FL', '33139', 2, 'Carlos Rodriguez'),
('Atlanta Airport', '321 Terminal Rd', 'Atlanta', 'GA', '30320', 2, 'Ashley Thompson'),
-- Midwest
('Chicago Loop', '654 Michigan Ave', 'Chicago', 'IL', '60601', 3, 'Tom Wilson'),
('Detroit Central', '987 Woodward Ave', 'Detroit', 'MI', '48226', 3, 'Jennifer Brown'),
-- West Coast
('LAX Airport', '1 World Way', 'Los Angeles', 'CA', '90045', 4, 'Kevin Lee'),
('SF Financial', '555 Market St', 'San Francisco', 'CA', '94105', 4, 'Maria Garcia'),
-- Southwest
('Phoenix Sky Harbor', '3400 Sky Harbor Blvd', 'Phoenix', 'AZ', '85034', 5, 'James Taylor'),
('Denver Downtown', '1550 Blake St', 'Denver', 'CO', '80202', 5, 'Nicole White');

-- Categories
INSERT INTO categories (category_name, description) VALUES
('Economy', 'Fuel-efficient compact cars perfect for city driving'),
('SUV', 'Spacious vehicles ideal for families and long trips'),
('Luxury', 'Premium vehicles for executives and special occasions'),
('Truck', 'Heavy-duty vehicles for cargo and moving'),
('Electric', 'Zero-emission vehicles for eco-conscious customers');

-- Vehicles (varied inventory levels, some with maintenance issues)
INSERT INTO vehicles (model_name, category_id, price_per_day, current_inventory, total_inventory, last_rental_date) VALUES
-- Economy
('Toyota Corolla 2024', 1, 45.99, 12, 20, '2024-11-15'),
('Honda Civic 2024', 1, 47.99, 8, 15, '2024-11-14'),
('Nissan Sentra 2024', 1, 43.99, 15, 18, '2024-11-10'),
-- SUV
('Toyota RAV4 2024', 2, 79.99, 5, 12, '2024-11-15'),
('Honda CR-V 2024', 2, 82.99, 3, 10, '2024-11-16'),  -- Low inventory!
('Chevrolet Tahoe 2024', 2, 105.99, 2, 8, '2024-11-14'),
-- Luxury
('Mercedes E-Class 2024', 3, 159.99, 4, 6, '2024-11-13'),
('BMW 5 Series 2024', 3, 169.99, 3, 5, '2024-11-12'),
('Audi A6 2024', 3, 164.99, 2, 4, '2024-10-01'),  -- Hasn't been rented in 45 days!
-- Truck
('Ford F-150 2024', 4, 89.99, 6, 10, '2024-11-15'),
('Chevrolet Silverado 2024', 4, 92.99, 4, 8, '2024-11-14'),
('RAM 1500 2024', 4, 94.99, 5, 7, '2024-11-16'),
-- Electric
('Tesla Model 3 2024', 5, 99.99, 1, 8, '2024-11-16'),  -- High demand, low availability!
('Tesla Model Y 2024', 5, 119.99, 2, 6, '2024-11-15'),
('Nissan Leaf 2024', 5, 69.99, 8, 10, '2024-11-10');

-- Customers (mix of regular, VIP, and suspicious patterns)
INSERT INTO customers (name, email, phone, address_line, city, state, zip, customer_type, registration_date, total_spent) VALUES
-- Regular customers
('Robert Johnson', 'rjohnson@email.com', '555-0101', '123 Main St', 'New York', 'NY', '10001', 'individual', '2024-01-15', 1250.50),
('Jennifer Davis', 'jdavis@email.com', '555-0102', '456 Oak Ave', 'Boston', 'MA', '02109', 'individual', '2024-02-20', 890.25),
('Michael Brown', 'mbrown@email.com', '555-0103', '789 Pine St', 'Chicago', 'IL', '60601', 'individual', '2024-03-10', 2100.00),
-- Business customers  
('TechCorp Solutions', 'fleet@techcorp.com', '555-0200', '100 Tech Blvd', 'San Francisco', 'CA', '94105', 'business', '2024-01-01', 15670.00),
('Global Consulting Inc', 'rentals@globalconsult.com', '555-0201', '200 Business Park', 'Atlanta', 'GA', '30320', 'business', '2024-02-01', 8900.50),
('StartUp Ventures', 'cars@startup.com', '555-0202', '300 Innovation Dr', 'Miami', 'FL', '33139', 'business', '2024-06-01', 3200.00),
-- Suspicious customers (for fraud detection)
('John Smith', 'temp123@tempmail.com', '555-9999', '999 Fake St', 'Los Angeles', 'CA', '90001', 'individual', '2024-11-01', 50.00),
('Quick Rentals LLC', 'quickrent@disposable.com', '555-8888', 'PO Box 1234', 'Phoenix', 'AZ', '85001', 'business', '2024-11-10', 0.00),
-- VIP customers
('Elizabeth Taylor', 'etaylor@email.com', '555-0301', '1 Luxury Lane', 'Miami', 'FL', '33139', 'individual', '2023-06-15', 25000.00),
('Premier Corp', 'vip@premier.com', '555-0302', '500 Executive Plaza', 'New York', 'NY', '10001', 'business', '2023-01-01', 45000.00);

-- Salespersons
INSERT INTO salespersons (name, email, store_id, hire_date, total_sales) VALUES
('Alex Martinez', 'amartinez@fleet.com', 1, '2023-01-15', 125000.00),
('Samantha Lee', 'slee@fleet.com', 2, '2023-03-01', 98000.00),
('David Wilson', 'dwilson@fleet.com', 3, '2023-06-01', 110000.00),
('Emily Chen', 'echen@fleet.com', 4, '2024-01-01', 45000.00),
('Ryan Garcia', 'rgarcia@fleet.com', 5, '2024-02-15', 38000.00),
('Jessica Brown', 'jbrown@fleet.com', 6, '2023-09-01', 87000.00),
('Marcus Johnson', 'mjohnson@fleet.com', 7, '2023-11-01', 92000.00),
('Sophia Kim', 'skim@fleet.com', 8, '2024-03-01', 28000.00),
('Daniel Thompson', 'dthompson@fleet.com', 9, '2024-04-01', 22000.00),
('Olivia Anderson', 'oanderson@fleet.com', 10, '2024-05-01', 19000.00);

-- Transactions (mix of completed, active, and suspicious patterns)
INSERT INTO transactions (customer_id, vehicle_id, salesperson_id, store_id, rental_date, return_date, quantity, total_amount, status) VALUES
-- Completed normal transactions
(1, 1, 1, 1, '2024-10-01', '2024-10-05', 1, 183.96, 'completed'),
(2, 4, 2, 2, '2024-10-10', '2024-10-15', 1, 399.95, 'completed'),
(3, 10, 5, 5, '2024-10-20', '2024-10-25', 1, 449.95, 'completed'),
(4, 7, 7, 7, '2024-10-15', '2024-10-20', 2, 1599.90, 'completed'),
(5, 2, 4, 4, '2024-11-01', '2024-11-05', 1, 239.95, 'completed'),
-- Active rentals
(1, 13, 1, 1, '2024-11-14', NULL, 1, 299.97, 'active'),
(3, 5, 5, 5, '2024-11-15', NULL, 1, 248.97, 'active'),
(6, 8, 8, 8, '2024-11-13', NULL, 1, 509.97, 'active'),
(4, 14, 7, 7, '2024-11-12', NULL, 2, 719.92, 'active'),
-- Suspicious transactions (fraud patterns)
(7, 7, 3, 3, '2024-11-10', '2024-11-11', 1, 999.99, 'completed'),  -- Way overcharged!
(8, 1, 9, 9, '2024-11-15', NULL, 5, 229.95, 'active'),  -- 5 economy cars at once?
(7, 8, 3, 3, '2024-11-11', '2024-11-12', 1, 899.99, 'completed'),  -- Overcharged again!
-- High-value business transactions
(9, 7, 1, 1, '2024-11-01', '2024-11-10', 1, 1599.90, 'completed'),
(10, 8, 1, 1, '2024-11-05', '2024-11-15', 3, 5099.70, 'completed'),
-- Cancelled transactions
(2, 6, 2, 2, '2024-11-10', NULL, 1, 317.98, 'cancelled'),
(5, 11, 4, 4, '2024-11-08', NULL, 1, 92.99, 'cancelled');

-- Performance Metrics (showing trends and patterns)
INSERT INTO performance_metrics (metric_date, store_id, revenue, utilization_rate, avg_rental_duration, maintenance_costs, customer_satisfaction_score, demand_forecast_next_7d) VALUES
-- Store 1 - Manhattan (high performance)
('2024-11-10', 1, 3500.00, 0.85, 4.2, 200.00, 4.5, 25),
('2024-11-11', 1, 3200.00, 0.82, 4.0, 150.00, 4.6, 24),
('2024-11-12', 1, 3800.00, 0.88, 4.5, 180.00, 4.4, 26),
('2024-11-13', 1, 4100.00, 0.91, 4.8, 220.00, 4.3, 28),
('2024-11-14', 1, 4500.00, 0.93, 5.0, 250.00, 4.2, 30),  -- Demand surge!
('2024-11-15', 1, 4200.00, 0.90, 4.6, 200.00, 4.4, 27),
-- Store 3 - Miami (maintenance issues)
('2024-11-10', 3, 2100.00, 0.65, 3.5, 800.00, 3.8, 15),  -- High maintenance costs!
('2024-11-11', 3, 1900.00, 0.60, 3.2, 850.00, 3.6, 14),
('2024-11-12', 3, 1800.00, 0.58, 3.0, 900.00, 3.5, 13),
('2024-11-13', 3, 2000.00, 0.62, 3.3, 750.00, 3.7, 15),
('2024-11-14', 3, 2200.00, 0.64, 3.6, 700.00, 3.9, 16),
('2024-11-15', 3, 2300.00, 0.66, 3.8, 650.00, 4.0, 17),
-- Store 7 - LAX (normal operations)
('2024-11-10', 7, 2800.00, 0.75, 3.8, 300.00, 4.2, 20),
('2024-11-11', 7, 2900.00, 0.76, 3.9, 310.00, 4.1, 21),
('2024-11-12', 7, 2750.00, 0.73, 3.7, 290.00, 4.3, 19),
('2024-11-13', 7, 3000.00, 0.78, 4.0, 320.00, 4.2, 22),
('2024-11-14', 7, 3100.00, 0.79, 4.1, 330.00, 4.1, 23),
('2024-11-15', 7, 2950.00, 0.77, 3.9, 305.00, 4.2, 21);

-- Operational Events (detected anomalies and issues)
INSERT INTO operational_events (event_type, entity_type, entity_id, severity, detected_at, details, resolved) VALUES
-- Fraud detection
('fraud_risk', 'customer', 7, 'high', '2024-11-11 10:30:00', 
 '{"reason": "Multiple high-value rentals in short period", "amount": 1899.98, "risk_score": 0.92}', false),
('fraud_risk', 'transaction', 11, 'critical', '2024-11-15 14:45:00',
 '{"reason": "Unusual quantity for customer type", "quantity": 5, "normal_range": "1-2"}', false),
-- Maintenance alerts
('maintenance', 'vehicle', 9, 'high', '2024-11-10 08:00:00',
 '{"reason": "No rental in 45 days", "last_rental": "2024-10-01", "recommended_action": "inspection"}', false),
('maintenance', 'vehicle', 3, 'medium', '2024-11-12 09:15:00',
 '{"reason": "High mileage threshold reached", "current_miles": 35000, "service_due": 36000}', true),
-- Demand surge
('demand_surge', 'store', 1, 'high', '2024-11-14 16:00:00',
 '{"utilization": 0.93, "available_vehicles": 2, "incoming_demand": 30}', false),
('demand_surge', 'vehicle', 13, 'critical', '2024-11-16 10:00:00',
 '{"category": "Electric", "available": 1, "demand": 15, "recommendation": "transfer_inventory"}', false),
-- Anomalies
('anomaly', 'transaction', 10, 'high', '2024-11-10 11:20:00',
 '{"type": "pricing_anomaly", "expected": 159.99, "actual": 999.99, "variance": 525}', false),
('anomaly', 'store', 3, 'medium', '2024-11-13 13:30:00',
 '{"type": "maintenance_cost_spike", "normal_range": "200-400", "actual": 900}', false);

-- Update calculated fields
UPDATE vehicles 
SET last_rental_date = CURRENT_DATE - INTERVAL '1 day' 
WHERE vehicle_id IN (1, 4, 5, 10, 13, 14);

UPDATE customers 
SET total_spent = (
    SELECT COALESCE(SUM(total_amount), 0) 
    FROM transactions 
    WHERE transactions.customer_id = customers.customer_id 
    AND status = 'completed'
);

UPDATE salespersons 
SET total_sales = total_sales + (
    SELECT COALESCE(SUM(total_amount), 0) 
    FROM transactions 
    WHERE transactions.salesperson_id = salespersons.salesperson_id 
    AND status = 'completed' 
    AND rental_date >= '2024-10-01'
);

-- Final status message
SELECT 'Seed data loaded successfully!' as status,
       (SELECT COUNT(*) FROM regions) as regions,
       (SELECT COUNT(*) FROM stores) as stores,
       (SELECT COUNT(*) FROM vehicles) as vehicles,
       (SELECT COUNT(*) FROM customers) as customers,
       (SELECT COUNT(*) FROM transactions) as transactions,
       (SELECT COUNT(*) FROM operational_events) as events,
       (SELECT COUNT(*) FROM performance_metrics) as metrics;