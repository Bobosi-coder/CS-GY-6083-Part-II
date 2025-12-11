#!/bin/bash

echo "========================================"
echo "Database Reset Script"
echo "========================================"
echo ""
echo "⚠️  WARNING: This will DELETE all database data!"
echo "Press Ctrl+C to cancel, or Enter to continue..."
read

cd "$(dirname "$0")"

echo ""
echo "1. Stopping containers..."
sudo docker-compose down

echo ""
echo "2. Removing database volume..."
sudo docker volume rm cs-gy-6083-part-ii_mysql_data

echo ""
echo "3. Starting containers (database will initialize from SQL files)..."
sudo docker-compose up -d

echo ""
echo "4. Waiting for database initialization (this may take 30-60 seconds)..."
sleep 40

echo ""
echo "5. Checking container status..."
sudo docker-compose ps

echo ""
echo "========================================"
echo "✅ Database reset complete!"
echo "========================================"
echo ""
echo "The SQL files in /database have been executed."
echo ""
echo "To verify data was loaded:"
echo "  sudo docker-compose exec db mysql -u appuser -papppassword dry_news_db -e 'SHOW TABLES;'"
echo ""
