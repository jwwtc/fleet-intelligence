# Deployment Guide

This guide covers deploying the Fleet Operations Intelligence Platform to Render.com for portfolio presentation.

## Why Deploy?

For engineering portfolios, a live demo is crucial because:
- **Recruiters can interact** with your project immediately (no setup required)
- **Shows production skills** - deployment, environment management, cloud hosting
- **Professional presentation** - live URL on resume/LinkedIn
- **GitHub + Live Demo** - Best of both worlds

## Option 1: Render.com (Recommended - FREE)

### Advantages
- ✓ Free tier includes PostgreSQL database
- ✓ Automatic deploys from GitHub
- ✓ No credit card required
- ✓ SSL certificate included
- ✓ Perfect for portfolios

### Step-by-Step Deployment

#### 1. Prepare GitHub Repository

```bash
# Initialize git repository
git init

# Add all files
git add .

# Create initial commit
git commit -m "Initial commit: Fleet Operations Intelligence Platform"

# Create GitHub repository (via GitHub.com)
# Then connect local repo to GitHub:
git remote add origin https://github.com/YOUR_USERNAME/fleet-operations.git
git branch -M main
git push -u origin main
```

#### 2. Sign Up for Render

1. Go to https://render.com
2. Sign up with your GitHub account
3. Authorize Render to access your repositories

#### 3. Create PostgreSQL Database

1. Click "New +" → "PostgreSQL"
2. Configure:
   - **Name:** `fleet-operations-db`
   - **Database:** `vehicle_rental_db`
   - **User:** `fleet_admin`
   - **Region:** Choose closest to you
   - **Plan:** Free
3. Click "Create Database"
4. **Save the connection details** (you'll see them on the database page)

#### 4. Initialize Database Schema

Once database is created:

1. Click on your database → "Connect" tab
2. Copy the "PSQL Command"
3. Run in your terminal:
```bash
# Connect to Render database
psql postgresql://fleet_admin:PASSWORD@HOST/vehicle_rental_db

# Then paste the contents of sql/schema.sql
# Then paste the contents of sql/seed_data.sql
```

Or upload via Render dashboard:
1. Go to database → "Shell" tab
2. Copy/paste contents of `sql/schema.sql`
3. Copy/paste contents of `sql/seed_data.sql`

#### 5. Deploy Web Service

1. Click "New +" → "Web Service"
2. Connect your GitHub repository
3. Configure:
   - **Name:** `fleet-operations`
   - **Environment:** Python 3
   - **Build Command:** `pip install -r requirements.txt`
   - **Start Command:** `gunicorn app:app`
   - **Plan:** Free
4. Add Environment Variable:
   - Click "Environment" tab
   - Add `DATABASE_URL` → Copy from your database's "Internal Database URL"
5. Click "Create Web Service"

#### 6. Verify Deployment

1. Wait for build to complete (~2-3 minutes)
2. Click on the provided URL (e.g., `fleet-operations.onrender.com`)
3. Test all pages:
   - Command Center (/)
   - Intelligence Analytics (/analytics)
   - Fleet Data (/browse)
   - Threat Monitor (/alerts)

### Troubleshooting

**Build fails:**
- Check `requirements.txt` for typos
- Verify Python version compatibility

**Database connection error:**
- Ensure `DATABASE_URL` environment variable is set
- Verify database is running (check Render dashboard)
- Check if seed data was loaded

**Pages load but show no data:**
- Database might not have seed data
- Re-run `sql/seed_data.sql` in database shell

## Option 2: Railway.app (Alternative)

Similar process to Render:
1. Sign up at https://railway.app
2. "New Project" → "Deploy from GitHub"
3. Add PostgreSQL plugin
4. Set environment variable: `DATABASE_URL=${{Postgres.DATABASE_URL}}`
5. Deploy

**Cost:** $5/month free credit (enough for portfolio project)

## Option 3: GitHub Only (No Live Deployment)

If you prefer not to deploy:

### Make GitHub Repository Stand Out

1. **Excellent README.md** (already created ✓)
2. **Add screenshots** to README:
```bash
# Take screenshots of all 4 pages
# Add to repo in /screenshots folder
# Reference in README.md:
![Command Center](screenshots/dashboard.png)
```

3. **Create demo video:**
   - Record 2-minute walkthrough
   - Upload to YouTube (unlisted)
   - Link in README

4. **Professional GitHub setup:**
   - Add topics/tags: `flask`, `postgresql`, `data-analytics`, `business-intelligence`
   - Add description: "Real-time fleet operations intelligence platform with anomaly detection"
   - Pin repository to GitHub profile

## For Portfolio/Resume

**With Live Deployment:**
```
Fleet Operations Intelligence Platform
Live Demo: fleet-operations.onrender.com
GitHub: github.com/username/fleet-operations

Real-time operational intelligence system with automated anomaly
detection, fraud analysis, and revenue optimization. 9-table
PostgreSQL database with complex analytical queries.
```

**Without Live Deployment:**
```
Fleet Operations Intelligence Platform
GitHub: github.com/username/fleet-operations
Demo Video: youtube.com/watch?v=...

Real-time operational intelligence system with automated anomaly
detection, fraud analysis, and revenue optimization. 9-table
PostgreSQL database with complex analytical queries.
```

## Recommended Approach

For maximum impact: **Deploy on Render (FREE) + GitHub Repository**

This combination shows:
- ✓ Live working demo (recruiters can click immediately)
- ✓ Production deployment skills
- ✓ Code quality (reviewable on GitHub)
- ✓ Documentation (README)
- ✓ Cloud hosting experience

Takes ~30 minutes total setup time and costs $0.
