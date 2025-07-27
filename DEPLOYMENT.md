# Five Rivers Tutoring - Deployment Guide

## Database Setup ✅
- **Database Name:** `fiveriverstutoring_db`
- **Username:** `fiverriversadmin`
- **Password:** `Password@123`
- **Host:** `localhost` (or your external database host)

## Local Development

### 1. Copy environment template:
```bash
cd local-deploy
cp env.example .env
```

### 2. Update database connection (if needed):
Edit `.env` file to match your database setup.

### 3. Start WordPress container:
```bash
docker-compose -f docker-compose.local.yml up -d
```

### 4. Access WordPress:
- **URL:** http://localhost:8082
- **Database:** Connected to `fiveriverstutoring_db`

## Production Deployment

### 1. Set environment variables:
```bash
export WORDPRESS_DB_HOST=your-db-host
export WORDPRESS_DB_USER=fiverriversadmin
export WORDPRESS_DB_PASSWORD=Password@123
export WORDPRESS_DB_NAME=fiveriverstutoring_db
export WORDPRESS_HOME=https://your-domain.com
export WORDPRESS_SITEURL=https://your-domain.com
```

### 2. Deploy with Docker:
```bash
cd gcp-deploy
docker-compose -f docker-compose.prod.yml up -d
```

## Custom Plugins
- **Tutoring Scheduler** - Student scheduling system
- **Progress Tracker** - Student progress monitoring
- **Homework Assistant** - Homework management
- **Contact Form 7** - Contact forms
- **Elementor** - Page builder
- **Yoast SEO** - SEO optimization

## Database Connection
The WordPress container will automatically connect to your external MySQL database using the credentials from the environment variables. 