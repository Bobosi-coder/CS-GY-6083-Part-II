# Docker Deployment Guide

This document provides instructions for running the Dry News application using Docker.

## Prerequisites

- Docker Engine 20.10+ installed
- Docker Compose V2+ installed
- At least 4GB of available RAM
- Ports 3000, 5000, and 3307 available on your host machine

## Quick Start

### 1. Environment Setup

Copy the example environment file and configure it:

```bash
cp .env.example .env
```

Edit `.env` and update the values as needed (especially the SECRET_KEY for production).

### 2. Build and Start Services
Quick Build-and-Strat

```bash
./clean-start.sh
```

Or Manual Build-and-Start all services (database, backend, frontend):

```bash
docker-compose up --build
```

Or run in detached mode:

```bash
docker-compose up -d --build
```

### 3. Access the Application

- **Frontend**: http://localhost:3000
- **Backend API**: http://localhost:5000
- **MySQL Database**: localhost:3307 (connect with MySQL Workbench or CLI)

## Database Initialization

The database will automatically initialize on first startup. SQL scripts in the `/database` directory are automatically executed by MySQL container on first run.

If you need to reset the database:

```bash
# Stop containers
docker-compose down

# Remove the database volume
docker volume rm cs-gy-6083-part-ii_mysql_data

# Start fresh
docker-compose up -d --build
```

## Useful Docker Commands

### View Logs

```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f backend
docker-compose logs -f frontend
docker-compose logs -f db
```

### Stop Services

```bash
# Stop all services
docker-compose down

# Stop and remove volumes (WARNING: deletes database data)
docker-compose down -v
```

### Restart a Service

```bash
docker-compose restart backend
docker-compose restart frontend
```

### Rebuild After Code Changes

```bash
# Rebuild specific service
docker-compose up -d --build backend

# Rebuild all services
docker-compose up -d --build
```

### Access Service Shell

```bash
# Backend Python shell
docker-compose exec backend bash

# Frontend container
docker-compose exec frontend sh

# MySQL CLI
docker-compose exec db mysql -u appuser -p
```

## Development Mode

The `docker-compose.yml` includes a volume mount for the backend that allows live code reloading:

```yaml
volumes:
  - ./backend:/app
```

For frontend development, you may want to run the React dev server locally instead of in Docker:

```bash
# Stop only the frontend container
docker-compose stop frontend

# In the frontend directory
cd frontend
npm install
npm run dev
```

## Production Deployment

### Important Changes for Production

1. **Environment Variables**: Update `.env` with secure credentials
   - Generate a strong `SECRET_KEY`
   - Use strong database passwords
   - Set `FLASK_ENV=production`

2. **Remove Development Volume Mounts**: In `docker-compose.yml`, comment out or remove:
   ```yaml
   # volumes:
   #   - ./backend:/app
   ```

3. **Use Docker Secrets** (for Docker Swarm) or environment variable management tools

4. **Enable HTTPS**: Place a reverse proxy (nginx/traefik) in front with SSL certificates

5. **Resource Limits**: Add resource constraints to docker-compose.yml:
   ```yaml
   deploy:
     resources:
       limits:
         cpus: '1'
         memory: 512M
   ```

## Troubleshooting

### Backend Can't Connect to Database

**Error**: `Can't connect to MySQL server on 'db'`

**Solution**: The database may not be ready. The backend has a health check and depends_on configuration, but you can also:
```bash
docker-compose restart backend
```

### Port Already in Use

**Error**: `Bind for 0.0.0.0:3000 failed: port is already allocated`

**Solution**: Either stop the service using that port, or modify the port mapping in `docker-compose.yml`:
```yaml
ports:
  - "3001:80"  # Change 3000 to 3001
```

### Frontend Shows "Network Error"

Check that:
1. Backend is running: `docker-compose ps`
2. Backend health: `curl http://localhost:5000`
3. Check nginx logs: `docker-compose logs frontend`

### Database Data Persistence

Data is stored in a Docker volume named `mysql_data`. To backup:
```bash
docker-compose exec db mysqldump -u root -p dry_news_db > backup.sql
```

To restore:
```bash
docker-compose exec -T db mysql -u root -p dry_news_db < backup.sql
```

## Architecture

```
┌─────────────────┐
│   Frontend      │
│   (React+Nginx) │ :3000
│   Port 80       │
└────────┬────────┘
         │
         │ /api requests
         ↓
┌─────────────────┐
│   Backend       │
│   (Flask)       │ :5000
│   Port 5000     │
└────────┬────────┘
         │
         │ SQL queries
         ↓
┌─────────────────┐
│   Database      │
│   (MySQL 8.0)   │ :3307→3306
│   Port 3306     │
└─────────────────┘
```

## Network

All services communicate via a Docker bridge network named `app-network`. Service names (db, backend, frontend) act as hostnames within this network.

## Health Checks

All services include health checks:
- **Database**: MySQL ping check
- **Backend**: HTTP GET to /
- **Frontend**: HTTP GET to nginx

Check health status:
```bash
docker-compose ps
```

## Environment Variables Reference

| Variable | Description | Default |
|----------|-------------|---------|
| `MYSQL_ROOT_PASSWORD` | MySQL root password | rootpassword |
| `MYSQL_DB` | Database name | dry_news_db |
| `MYSQL_USER` | Application database user | appuser |
| `MYSQL_PASSWORD` | Application database password | apppassword |
| `SECRET_KEY` | Flask secret key | dev-secret-key-change-in-production |
| `FLASK_ENV` | Flask environment | production |

## Support

For issues related to Docker setup, check:
1. Docker daemon status: `systemctl status docker`
2. Docker compose version: `docker-compose --version`
3. Available disk space: `df -h`
4. Docker logs for errors: `docker-compose logs`


