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
    
    # Get critical alerts
    cur.execute("""
        SELECT event_type, entity_type, severity, detected_at, details
        FROM operational_events
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
        SELECT c.name, c.email, COUNT(t.transaction_id) as rental_count,
               SUM(t.total_amount) as total_spent,
               ROUND(AVG(t.total_amount), 2) as avg_transaction
        FROM customers c
        JOIN transactions t ON c.customer_id = t.customer_id
        WHERE t.rental_date >= CURRENT_DATE - INTERVAL '30 days'
        GROUP BY c.customer_id, c.name, c.email
        HAVING COUNT(t.transaction_id) > 2 OR AVG(t.total_amount) > 500
        ORDER BY avg_transaction DESC
    """)
    suspicious_customers = cur.fetchall()
    
    # Revenue optimization opportunities
    cur.execute("""
        SELECT v.model_name, v.price_per_day,
               COUNT(t.transaction_id) as rental_count,
               ROUND(AVG(t.total_amount / NULLIF(
                   DATE_PART('day', t.return_date - t.rental_date), 0)), 2) as actual_daily_rate,
               ROUND((AVG(t.total_amount / NULLIF(
                   DATE_PART('day', t.return_date - t.rental_date), 0)) - v.price_per_day) * 30, 2) as monthly_opportunity
        FROM vehicles v
        JOIN transactions t ON v.vehicle_id = t.vehicle_id
        WHERE t.status = 'completed'
        GROUP BY v.vehicle_id, v.model_name, v.price_per_day
        HAVING AVG(t.total_amount / NULLIF(DATE_PART('day', t.return_date - t.rental_date), 0)) > v.price_per_day * 1.1
    """)
    revenue_opportunities = cur.fetchall()
    
    # Maintenance priorities
    cur.execute("""
        SELECT model_name, last_rental_date,
               CURRENT_DATE - last_rental_date as days_idle
        FROM vehicles
        WHERE last_rental_date < CURRENT_DATE - INTERVAL '30 days'
           OR last_rental_date IS NULL
        ORDER BY last_rental_date NULLS FIRST
    """)
    maintenance_needed = cur.fetchall()
    
    cur.close()
    conn.close()
    
    return render_template('analytics.html',
                         suspicious=suspicious_customers,
                         opportunities=revenue_opportunities,
                         maintenance=maintenance_needed)

# Vehicle Browse
@app.route('/browse')
def browse():
    conn = get_db_connection()
    cur = conn.cursor()
    
    cur.execute("""
        SELECT v.vehicle_id, v.model_name, c.category_name, 
               v.price_per_day, v.current_inventory,
               ROUND((1.0 - v.current_inventory::float / v.total_inventory) * 100, 1) as utilization_rate
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
        SELECT * FROM operational_events
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
    app.run(debug=True)