# Deployment Guide

Deploy the Fleet Operations Intelligence Platform to Render.com.

## Render.com (Free Tier)

### 1. Push to GitHub

```bash
git init
git add .
git commit -m "Initial commit"
git remote add origin https://github.com/YOUR_USERNAME/fleet-operations.git
git push -u origin main
```

### 2. Create PostgreSQL Database

1. Render Dashboard → "New +" → "PostgreSQL"
2. Name: `fleet-operations-db`, Database: `vehicle_rental_db`, Plan: Free
3. Save connection details

### 3. Initialize Schema

Connect via PSQL or Render Shell, then run:
- `sql/schema.sql`
- `sql/seed_data.sql`

### 4. Deploy Web Service

1. "New +" → "Web Service" → Connect GitHub repo
2. Build Command: `pip install -r requirements.txt`
3. Start Command: `gunicorn app:app`
4. Add env var: `DATABASE_URL` (from database's Internal URL)

### 5. Verify

Test all routes: `/`, `/analytics`, `/browse`, `/alerts`

## Troubleshooting

- **Build fails:** Check `requirements.txt`
- **DB connection error:** Verify `DATABASE_URL` env var
- **No data:** Re-run `sql/seed_data.sql`
