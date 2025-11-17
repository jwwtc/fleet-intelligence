# Fleet Operations Intelligence Platform

A real-time operational intelligence system for vehicle rental fleet management, featuring anomaly detection, predictive analytics, and business intelligence capabilities.

## Overview

This platform provides enterprise-grade fleet operations monitoring with automated anomaly detection, revenue optimization insights, and operational event tracking. Built with PostgreSQL and Flask, it demonstrates advanced database design, complex analytical queries, and data-driven decision support.

## Key Features

### Operational Intelligence
- **Real-time anomaly detection** for fraud patterns, maintenance issues, and demand surges
- **Automated alerting** with severity classification (critical, high, medium, low)
- **Predictive maintenance** prioritization based on vehicle idle time and rental patterns

### Business Analytics
- **Fraud detection matrix** identifying suspicious customer activity patterns
- **Revenue optimization** analysis showing pricing discrepancies and profit opportunities
- **Fleet utilization metrics** with availability tracking and performance forecasting

### Data Architecture
- **9-table normalized schema** with proper foreign key relationships
- **JSON event details** for flexible anomaly metadata storage
- **Temporal analysis** using dynamic date intervals for time-series queries

## Database Schema

```
regions → stores → salespersons
                 ↓
categories → vehicles → transactions ← customers
           ↓
operational_events
performance_metrics
```

**Core Tables:**
- `regions` - Geographic organizational hierarchy
- `stores` - Location-specific operations data
- `vehicles` - Fleet inventory with real-time availability
- `customers` - Client profiles with transaction history
- `transactions` - Rental records with status tracking
- `operational_events` - Anomaly detection log with JSON metadata
- `performance_metrics` - Daily KPIs per store location

## Technical Implementation

### Backend Stack
- **Flask 3.0** - Web framework with Jinja2 templating
- **PostgreSQL 14+** - Relational database with JSON support
- **psycopg2** - Database adapter with RealDictCursor for row dictionaries

### Analytical Queries

**Fraud Detection:**
```sql
SELECT c.customer_id, c.name,
       COUNT(t.transaction_id) as rental_count,
       AVG(t.total_amount) as avg_transaction
FROM customers c
JOIN transactions t ON c.customer_id = t.customer_id
WHERE t.rental_date >= CURRENT_DATE - INTERVAL '30 days'
GROUP BY c.customer_id
HAVING COUNT(t.transaction_id) > 2 OR AVG(t.total_amount) > 500
```

**Revenue Optimization:**
```sql
SELECT v.model_name, v.price_per_day,
       AVG(t.total_amount / EXTRACT(day FROM t.return_date - t.rental_date))
           as actual_daily_rate
FROM vehicles v
JOIN transactions t ON v.vehicle_id = t.vehicle_id
WHERE t.status = 'completed'
GROUP BY v.vehicle_id
HAVING AVG(actual_daily_rate) > v.price_per_day * 1.1
```

### UI/UX Design
- **Dark theme** with muted professional color palette
- **Responsive layout** using Bootstrap 5
- **Data-dense interface** optimized for operational monitoring
- **Real-time metrics** with visual severity indicators

## Setup Instructions

### Prerequisites
- Python 3.8+
- PostgreSQL 14+
- pip package manager

### Installation

1. **Clone the repository**
```bash
git clone <repository-url>
cd vehicle-rental-ops
```

2. **Create virtual environment**
```bash
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
```

3. **Install dependencies**
```bash
pip install -r requirements.txt
```

4. **Configure database**
```bash
# Create PostgreSQL database
createdb vehicle_rental_db

# Initialize schema
psql -d vehicle_rental_db -f sql/schema.sql

# Load seed data
psql -d vehicle_rental_db -f sql/seed_data.sql
```

5. **Update configuration**
Edit `config.py` to match your database credentials:
```python
DATABASE = {
    'dbname': 'vehicle_rental_db',
    'user': 'your_username',
    'host': 'localhost',
    'port': 5432
}
```

6. **Run the application**
```bash
python app.py
```

Access the platform at `http://localhost:5000`

## Application Pages

- **Command Center** (`/`) - Real-time KPIs, critical alerts, fleet status overview
- **Intelligence Analytics** (`/analytics`) - Fraud detection, revenue optimization, maintenance priorities
- **Fleet Data** (`/browse`) - Vehicle inventory with utilization metrics
- **Threat Monitor** (`/alerts`) - Operational events log with severity filtering

## Project Structure

```
vehicle-rental-ops/
├── app.py                 # Flask application with route handlers
├── config.py              # Database configuration
├── requirements.txt       # Python dependencies
├── sql/
│   ├── schema.sql        # Database table definitions
│   └── seed_data.sql     # Sample data with anomaly patterns
├── templates/
│   ├── base.html         # Base template with navigation
│   ├── dashboard.html    # Command center page
│   ├── analytics.html    # Intelligence analytics page
│   ├── browse.html       # Fleet data page
│   └── alerts.html       # Threat monitor page
└── static/
    └── style.css         # Custom CSS (if applicable)
```

## Data Patterns

The seed data includes intentional patterns for demonstrating analytics capabilities:
- **Suspicious customers** with abnormally high transaction values
- **Underutilized vehicles** requiring maintenance attention
- **Pricing discrepancies** showing revenue optimization opportunities
- **Demand surges** triggering capacity alerts
