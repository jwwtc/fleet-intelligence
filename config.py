import psycopg2
from psycopg2.extras import RealDictCursor
import os

class Config:
    # For local development
    DATABASE = {
        'dbname': os.environ.get('DB_NAME', 'vehicle_rental_db'),
        'user': os.environ.get('DB_USER', 'postgres'),
        'host': os.environ.get('DB_HOST', 'localhost'),
        'port': int(os.environ.get('DB_PORT', '5432'))
    }

def get_db_connection():
    # Check for production DATABASE_URL environment variable
    database_url = os.environ.get('DATABASE_URL')

    if database_url:
        # Production deployment (Render, Heroku, etc.)
        conn = psycopg2.connect(database_url, cursor_factory=RealDictCursor)
    else:
        # Local development
        conn = psycopg2.connect(
            dbname=Config.DATABASE['dbname'],
            user=Config.DATABASE['user'],
            host=Config.DATABASE['host'],
            port=Config.DATABASE['port'],
            cursor_factory=RealDictCursor
        )
    return conn