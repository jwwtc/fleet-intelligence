# Fleet Operations Intelligence Platform

Production-grade operational intelligence system for vehicle fleet management with real-time anomaly detection, predictive analytics, and business intelligence dashboards. Demonstrates end-to-end data pipeline engineering from normalized database design through analytics and visualization.

![Python](https://img.shields.io/badge/python-3.11-blue) ![PostgreSQL](https://img.shields.io/badge/postgresql-14+-blue) ![Flask](https://img.shields.io/badge/flask-3.0-lightgrey)

## Core Capabilities

- **Fraud Detection**: Pattern recognition across customer transaction histories using aggregate analysis
- **Revenue Optimization**: Comparative price analysis identifying underpriced assets and pricing opportunities
- **Predictive Maintenance**: Vehicle service scheduling based on utilization patterns and idle time
- **Real-Time Monitoring**: Operational event tracking with severity-based alerting (critical/high/medium/low)
- **Multi-Dimensional Analytics**: Performance metrics across customers, vehicles, stores, and regions

## Technical Architecture

### 9-Table Normalized Schema

```
regions → stores → (salespersons, performance_metrics, transactions)
transactions ← (customers, vehicles ← categories)
operational_events (anomaly detection & alerts)
```

**Design Highlights**:
- Composite foreign keys linking transactional data across 5+ tables
- JSON data types for flexible event metadata
- CHECK constraints and validation at database level
- Time-series metrics with composite primary keys
- Indexed lookups for sub-second query performance

### Intelligence Queries

**Fraud Detection** (pattern-based anomaly detection):
```sql
SELECT c.name, COUNT(t.transaction_id) as rentals,
       SUM(t.total_amount) as spent, AVG(t.total_amount) as avg_txn
FROM customers c JOIN transactions t ON c.customer_id = t.customer_id
WHERE t.rental_date >= CURRENT_DATE - INTERVAL '30 days'
GROUP BY c.customer_id, c.name
HAVING COUNT(t.transaction_id) > 2 OR AVG(t.total_amount) > 500;
```

**Revenue Optimization** (actual vs. listed rate analysis):
```sql
SELECT v.model_name, v.price_per_day,
       ROUND(AVG(t.total_amount / NULLIF(
           DATE_PART('day', t.return_date - t.rental_date), 0)), 2) as actual_rate
FROM vehicles v JOIN transactions t ON v.vehicle_id = t.vehicle_id
WHERE t.status = 'completed'
GROUP BY v.vehicle_id, v.model_name, v.price_per_day
HAVING AVG(t.total_amount / NULLIF(
    DATE_PART('day', t.return_date - t.rental_date), 0)) > v.price_per_day * 1.1;
```

### User Interface

Dark theme (#0a0e27 background, #00d4ff accents) with data-dense visualizations:

1. **Command Center** (`/`) - Executive KPIs with threat detection feed
2. **Intelligence Analytics** (`/analytics`) - Fraud matrix, revenue opportunities, maintenance queue
3. **Fleet Database** (`/browse`) - Inventory browser with utilization metrics
4. **Threat Monitor** (`/alerts`) - Operational events with severity filtering
5. **API Endpoint** (`/api/metrics`) - JSON export for integrations

## Features

**Anomaly Detection**:
- Event classification (fraud_risk, maintenance, demand_surge, anomaly)
- Four-tier severity scoring with visual indicators
- Entity tracking (vehicles, customers, stores, transactions)
- Resolution lifecycle management

**Business Intelligence**:
- Customer segmentation by spending patterns
- Geographic performance tracking (store-level KPIs)
- 7-day demand forecasting
- Proactive maintenance alerts

**Data Integrity**:
- Parameterized queries (SQL injection prevention)
- Foreign key constraints (referential integrity)
- CHECK constraints (input validation)
- Audit trails via timestamps

## Technology Stack

**Backend**: Flask 3.0 (Python 3.11), PostgreSQL 14+, psycopg2
**Frontend**: Bootstrap 5 (dark theme), Chart.js
**Query Optimization**: JOINs, aggregate functions, window functions

## Quick Start

```bash
# Setup
python -m venv venv && source venv/bin/activate
pip install flask psycopg2-binary python-dotenv

# Configure database (create config.py with credentials)
createdb vehicle_rental_db
psql -d vehicle_rental_db -f vehicle-rental-ops/sql/schema.sql
psql -d vehicle_rental_db -f vehicle-rental-ops/sql/seed_data.sql

# Run
cd vehicle-rental-ops && python app.py
# Visit http://localhost:5000
```

## Project Structure

```
vehicle-rental-ops/
├── app.py              # Flask routes (5 pages + API)
├── config.py           # DB connection with RealDictCursor
├── templates/          # Jinja2 templates (base, dashboard, analytics, browse, alerts)
└── sql/                # Schema, seed data, analytical queries
```

## Key Insights Generated

1. **Risk Mitigation**: Suspicious transaction patterns for fraud prevention
2. **Revenue Maximization**: Underpriced assets and optimization opportunities
3. **Operational Efficiency**: Maintenance scheduling and inventory optimization

## Performance Considerations

- Strategic indexing on primary/foreign keys
- Connection lifecycle management
- Database-level validation reducing application overhead
- Normalized schema supporting horizontal scaling
- Future: materialized views, Redis caching

---

**Built to demonstrate production-grade data engineering and operational intelligence capabilities**
