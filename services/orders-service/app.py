from flask import Flask, jsonify, request, render_template_string
from sqlalchemy import create_engine, text
from sqlalchemy.exc import SQLAlchemyError
import boto3
from datetime import datetime, timedelta

app = Flask(__name__)

# Database configuration
DB_USERNAME = "your_db_username"
DB_PASSWORD = "your_db_password"
DB_HOST = "your-orders-db-host"
DB_NAME = "orders_world"

# Create the database engine
DATABASE_URL = f"postgresql+psycopg2://{DB_USERNAME}:{DB_PASSWORD}@{DB_HOST}/{DB_NAME}"
engine = create_engine(DATABASE_URL)

# ECS configuration
ecs_client = boto3.client('ecs', region_name='us-east-1')
cluster_name = "your-ecs-cluster-name"

def get_order_count():
    """
    Fetch the count of 'hello' orders in the last hour.
    """
    try:
        with engine.connect() as connection:
            # Run the SQL query to get the count of relevant orders
            result = connection.execute(text(
                "SELECT COUNT(*) FROM orders WHERE time BETWEEN :start_time AND :end_time AND item = 'hello';"
            ), {
                "start_time": datetime.utcnow() - timedelta(hours=1),
                "end_time": datetime.utcnow()
            })
            count = result.scalar()  # Get the first column of the first row
            return count
    except SQLAlchemyError as e:
        print(f"Database error: {e}")
        return 0

def get_service_task_count(service_name):
    """
    Get the current desired task count of a given ECS service.
    """
    response = ecs_client.describe_services(cluster=cluster_name, services=[service_name])
    task_count = response['services'][0]['desiredCount']
    return task_count

def update_task_count(service_name, count):
    """
    Update the desired task count of a given ECS service.
    """
    ecs_client.update_service(cluster=cluster_name, service=service_name, desiredCount=count)

@app.route('/order-hello', methods=['PUT'])
def order_hello():
    order_count = get_order_count()

    if 3 < order_count < 6:
        # Scale up if the order count is between 3 and 6
        update_task_count("orders-s
