from flask import Flask, render_template, jsonify, request
import psycopg2
from config import get_db_connection
from datetime import datetime, timedelta

app = Flask(__name__)
app.secret_key = 'fleet-intelligence-2024'

# Home Dashboard - KPIs and Alerts
@app.route('/')
def dashboard():
    conn = get_db_connection()
    cur = conn.cursor()
    
    # Get KPIs
    cur.execute("""
        SELECT 
            COUNT(DISTINCT customer_id) as total_customers,
            COUNT(CASE WHEN status = 'active' THEN 1 END) as active_rentals,
            SUM(CASE WHEN status = 'completed' THEN total_amount ELSE 0 END) as total_revenue
        FROM transactions
        WHERE rental_date >= CURRENT_DATE - INTERVAL '30 days'
    """)
    kpis = cur.fetchone()
    
    # Get critical alerts with entity details
    cur.execute("""
        SELECT
            oe.event_type,
            oe.entity_type,
            oe.entity_id,
            oe.severity,
            oe.detected_at,
            oe.details,
            CASE
                WHEN oe.entity_type = 'vehicle' THEN (SELECT model_name FROM vehicles WHERE vehicle_id = oe.entity_id)
                WHEN oe.entity_type = 'customer' THEN (SELECT name FROM customers WHERE customer_id = oe.entity_id)
                WHEN oe.entity_type = 'store' THEN (SELECT store_name FROM stores WHERE store_id = oe.entity_id)
                WHEN oe.entity_type = 'transaction' THEN CONCAT('Transaction #', oe.entity_id)
                ELSE CONCAT(oe.entity_type, ' #', oe.entity_id)
            END as entity_name
        FROM operational_events oe
        WHERE resolved = FALSE AND severity IN ('high', 'critical')
        ORDER BY detected_at DESC
        LIMIT 5
    """)
    alerts = cur.fetchall()
    
    # Fleet utilization
    cur.execute("""
        SELECT 
            ROUND(AVG(1.0 - (current_inventory::numeric / total_inventory::numeric)) * 100, 1)::float as utilization
        FROM vehicles
    """)
    utilization = cur.fetchone()
    
    cur.close()
    conn.close()
    
    return render_template('dashboard.html', 
                         kpis=kpis, 
                         alerts=alerts, 
                         utilization=utilization['utilization'])

# Analytics - Intelligence Insights
@app.route('/analytics')
def analytics():
    conn = get_db_connection()
    cur = conn.cursor()

    # Fraud detection
    cur.execute("""
        SELECT c.customer_id, c.name, c.email, c.phone,
               COUNT(t.transaction_id) as rental_count,
               SUM(t.total_amount) as total_spent,
               ROUND(AVG(t.total_amount)::numeric, 2) as avg_transaction
        FROM customers c
        JOIN transactions t ON c.customer_id = t.customer_id
        WHERE t.rental_date >= CURRENT_DATE - INTERVAL '30 days'
        GROUP BY c.customer_id, c.name, c.email, c.phone
        HAVING COUNT(t.transaction_id) > 2 OR AVG(t.total_amount) > 500
        ORDER BY avg_transaction DESC
    """)
    suspicious_customers = cur.fetchall()

    # Revenue optimization opportunities
    cur.execute("""
        SELECT v.model_name, v.price_per_day,
               COUNT(t.transaction_id) as rental_count,
               ROUND(AVG(t.total_amount / NULLIF(
                   EXTRACT(day FROM t.return_date::timestamp - t.rental_date::timestamp), 0))::numeric, 2) as actual_daily_rate,
               ROUND((AVG(t.total_amount / NULLIF(
                   EXTRACT(day FROM t.return_date::timestamp - t.rental_date::timestamp), 0)) - v.price_per_day) * 30, 2) as monthly_opportunity
        FROM vehicles v
        JOIN transactions t ON v.vehicle_id = t.vehicle_id
        WHERE t.status = 'completed' AND t.return_date IS NOT NULL
        GROUP BY v.vehicle_id, v.model_name, v.price_per_day
        HAVING AVG(t.total_amount / NULLIF(EXTRACT(day FROM t.return_date::timestamp - t.rental_date::timestamp), 0)) > v.price_per_day * 1.1
    """)
    revenue_opportunities = cur.fetchall()

    # Maintenance priorities
    cur.execute("""
        SELECT vehicle_id, model_name, last_rental_date,
               CURRENT_DATE - last_rental_date as days_idle
        FROM vehicles
        WHERE last_rental_date < CURRENT_DATE - INTERVAL '30 days'
           OR last_rental_date IS NULL
        ORDER BY last_rental_date NULLS FIRST
        LIMIT 10
    """)
    maintenance_needed = cur.fetchall()
    
    cur.close()
    conn.close()

    return render_template('analytics.html',
                         suspicious_customers=suspicious_customers,
                         revenue_opportunities=revenue_opportunities,
                         maintenance=maintenance_needed)

# Vehicle Browse
@app.route('/browse')
def browse():
    conn = get_db_connection()
    cur = conn.cursor()
    
    cur.execute("""
        SELECT v.vehicle_id, v.model_name, c.category_name,
               v.price_per_day, v.current_inventory,
               ROUND(((1.0 - v.current_inventory::numeric / v.total_inventory) * 100)::numeric, 1) as utilization_rate
        FROM vehicles v
        JOIN categories c ON v.category_id = c.category_id
        ORDER BY utilization_rate DESC
    """)
    vehicles = cur.fetchall()
    
    cur.close()
    conn.close()
    
    return render_template('browse.html', vehicles=vehicles)

# Alerts Management
@app.route('/alerts')
def alerts():
    conn = get_db_connection()
    cur = conn.cursor()

    cur.execute("""
        SELECT
            oe.*,
            CASE
                WHEN oe.entity_type = 'vehicle' THEN (SELECT model_name FROM vehicles WHERE vehicle_id = oe.entity_id)
                WHEN oe.entity_type = 'customer' THEN (SELECT name FROM customers WHERE customer_id = oe.entity_id)
                WHEN oe.entity_type = 'store' THEN (SELECT store_name FROM stores WHERE store_id = oe.entity_id)
                WHEN oe.entity_type = 'transaction' THEN CONCAT('Transaction #', oe.entity_id)
                ELSE CONCAT(oe.entity_type, ' #', oe.entity_id)
            END as entity_name
        FROM operational_events oe
        ORDER BY detected_at DESC
    """)
    events = cur.fetchall()
    
    cur.close()
    conn.close()
    
    return render_template('alerts.html', events=events)

# API endpoint for metrics
@app.route('/api/metrics')
def api_metrics():
    conn = get_db_connection()
    cur = conn.cursor()
    
    cur.execute("""
        SELECT metric_date, store_id, revenue, utilization_rate
        FROM performance_metrics
        WHERE metric_date >= CURRENT_DATE - INTERVAL '7 days'
        ORDER BY metric_date DESC
    """)
    metrics = cur.fetchall()
    
    cur.close()
    conn.close()
    
    return jsonify(metrics)

if __name__ == '__main__':
    import os
    # Use environment variable for debug mode (False in production)
    debug_mode = os.environ.get('FLASK_DEBUG', 'False').lower() == 'true'
    # Bind to 0.0.0.0 for cloud deployment, port from environment or default to 5000
    port = int(os.environ.get('PORT', 5000))
    app.run(host='0.0.0.0', port=port, debug=debug_mode)