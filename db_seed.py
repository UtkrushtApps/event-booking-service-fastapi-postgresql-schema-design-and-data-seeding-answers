import psycopg2
import os

# Adjust these parameters as needed for your environment
DB_NAME = os.environ.get('DB_NAME', 'eventdb')
DB_USER = os.environ.get('DB_USER', 'postgres')
DB_PASSWORD = os.environ.get('DB_PASSWORD', 'password')
DB_HOST = os.environ.get('DB_HOST', 'localhost')
DB_PORT = os.environ.get('DB_PORT', '5432')

# Open the schema.sql and run all commands
SCHEMA_FILE = 'schema.sql'

def main():
    with open(SCHEMA_FILE, 'r') as f:
        schema_sql = f.read()

    conn = psycopg2.connect(
        dbname=DB_NAME, user=DB_USER, password=DB_PASSWORD,
        host=DB_HOST, port=DB_PORT
    )
    try:
        with conn, conn.cursor() as cur:
            # Execute all SQL (DDL & seed DML)
            cur.execute(schema_sql)
            print('DB schema created and data seeded successfully.')
    finally:
        conn.close()

if __name__ == '__main__':
    main()
