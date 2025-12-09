#!/bin/bash

echo "========================================"
echo "Clean Start - Dry News Application"
echo "========================================"
echo ""

cd "$(dirname "$0")"

echo "1. Stopping and removing all containers..."
sudo docker-compose down -v

echo ""
echo "2. Removing any orphaned containers..."
sudo docker container prune -f

echo ""
echo "3. Starting database (fresh)..."
sudo docker-compose up -d db

echo "   Waiting for database initialization (60 seconds)..."
for i in {60..1}; do
    echo -ne "   $i seconds remaining...\r"
    sleep 1
done
echo ""

echo ""
echo "4. Checking database status..."
sudo docker-compose ps db

echo ""
echo "5. Starting backend..."
sudo docker-compose up -d backend

echo "   Waiting for backend (20 seconds)..."
for i in {20..1}; do
    echo -ne "   $i seconds remaining...\r"
    sleep 1
done
echo ""

echo ""
echo "6. Starting frontend..."
sudo docker-compose up -d frontend

echo "   Waiting for frontend (10 seconds)..."
sleep 10

echo ""
echo "========================================"
echo "✅ All services started!"
echo "========================================"
echo ""
sudo docker-compose ps

echo ""
echo "Verifying database tables..."
sudo docker-compose exec db mysql -u appuser -papppassword dry_news_db -e "SHOW TABLES;" 2>/dev/null || echo "Run this to check tables: sudo docker-compose exec db mysql -u appuser -papppassword dry_news_db -e 'SHOW TABLES;'"

echo ""
echo "========================================"
echo "Access your application at:"
echo "  Frontend:  http://localhost:3000"
echo "  Backend:   http://localhost:5000"
echo "  Database:  localhost:3307"
echo ""
echo "Useful commands:"
echo "  Logs:      sudo docker-compose logs -f"
echo "  Stop:      sudo docker-compose down"
echo "  Status:    sudo docker-compose ps"
echo "========================================"
