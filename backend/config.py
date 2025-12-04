import os
from dotenv import load_dotenv

load_dotenv()

class Config:
    SECRET_KEY = os.environ.get('SECRET_KEY') or 'a-hard-to-guess-string'
    MYSQL_HOST = os.environ.get('MYSQL_HOST', 'localhost')
    MYSQL_USER = os.environ.get('MYSQL_USER', 'your_mysql_user')
    MYSQL_PASSWORD = os.environ.get('MYSQL_PASSWORD', 'your_mysql_password')
    MYSQL_DB = os.environ.get('MYSQL_DB', 'dry_news_db')
    MYSQL_PORT = int(os.environ.get('MYSQL_PORT', 3306))
