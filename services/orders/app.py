import os
from flask import Flask, jsonify, request, render_template_string
from sqlalchemy import create_engine, text
from sqlalchemy.exc import SQLAlchemyError
import boto3
import requests
from datetime import datetime, timedelta

app = Flask(__name__)

#for testing Flask app locally, outside of a container, uncomment the following:
os.environ['DB_HOST'] = "localhost"
os.environ['DB_NAME'] = "orders"
os.environ['DB_USER'] = "postgres"
os.environ['DB_PASSWORD'] = "postgres"
os.environ['PLATFORM'] = "Windows"

# Reads environment variables that are set...
# in the Kubernetes config map (in the case of local testing), or, in...
# the ECS Task Definition, in the case of AWS deployment 
DB_HOST = os.getenv('DB_HOST')
DB_PORT = os.getenv('DB_PORT', 5432)  # Default to 5432 if not set
DB_USER = os.getenv('DB_USER')
DB_PASSWORD = os.getenv('DB_PASSWORD')
DB_NAME = os.getenv('DB_NAME')

PLATFORM = os.getenv('PLATFORM')  # 'minikube' or 'aws' (or Windows, for testing)

# Create the database engine
DATABASE_URL = f"postgresql+psycopg2://{DB_USER}:{DB_PASSWORD}@{DB_HOST}:{DB_PORT}/{DB_NAME}"
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

def get_ecs_service_task_count(service_name):
    """
    Get the current desired task count of a given ECS service.
    """
    response = ecs_client.describe_services(cluster=cluster_name, services=[service_name])
    task_count = response['services'][0]['desiredCount']
    return task_count

def update_ecs_task_count(service_name, count):
    """
    Update the desired task count of a given ECS service.
    """
    ecs_client.update_service(cluster=cluster_name, service=service_name, desiredCount=count)

def get_k8s_service_replica_count(deployment_name):
    """
    Get the current number of replicas for a Kubernetes deployment in Minikube.
    """
    k8s_api_url = f"http://localhost:8001/apis/apps/v1/namespaces/default/deployments/{deployment_name}"
    response = requests.get(k8s_api_url)
    if response.status_code == 200:
        replicas = response.json()['status']['replicas']
        return replicas
    else:
        print(f"Failed to get replica count from Kubernetes. Status code: {response.status_code}, Response: {response.text}")
        return 0

def update_k8s_replica_count(deployment_name, replicas):
    """
    Update the number of replicas for a Kubernetes deployment in Minikube.
    """
    k8s_api_url = f"http://localhost:8001/apis/apps/v1/namespaces/default/deployments/{deployment_name}/scale"
    headers = {"Content-Type": "application/strategic-merge-patch+json"}
    data = {"spec": {"replicas": replicas}}
    response = requests.patch(k8s_api_url, json=data, headers=headers)
    if response.status_code == 200:
        print(f"Successfully scaled up {deployment_name} to {replicas} replicas.")
    else:
        print(f"Failed to scale up {deployment_name}. Status code: {response.status_code}, Response: {response.text}")

@app.route('/order/hello', methods=['PUT'])
def order_hello():
    order_count = get_order_count()

    if 3 < order_count < 6:
        # Scale up if the order count is between 3 and 6
        if PLATFORM == 'aws':
            current_count = get_ecs_service_task_count("orders")
            update_ecs_task_count("orders", current_count + 1)
        elif PLATFORM == 'minikube':
            current_count = get_k8s_service_replica_count("orders-deployment")
            update_k8s_replica_count("orders-deployment", current_count + 1)
        #elif PLATFORM == 'Windows'...do nothing
        return render_template_string("Not enough nodes to fulfill your order. Must increment nodes by one...please try again later.")

    elif order_count >= 6:
        # Return an error message if the order count is too high
        return render_template_string("Our system cannot process any more orders. Please try again later.")

    else:
        # Scale down to 2 tasks if more than 2 are running
        if PLATFORM == 'aws':
            current_count = get_ecs_service_task_count("orders")
            if current_count > 2:
                update_ecs_task_count("orders", 2)
        elif PLATFORM == 'minikube':
            current_count = get_k8s_service_replica_count("orders-deployment")
            if current_count > 2:
                update_k8s_replica_count("orders-deployment", 2)
        #elif PLATFORM == 'Windows'...do nothing

        # Call the inventory service to check and update inventory
        inventory_response = requests.get('http://inventory:5000/inventory/hello_world').json()
        if inventory_response['count'] >= 1:
            requests.put('http://inventory:5000/pick-and-pack/hello_world')
            return render_template_string("Thank you for your order. Here it is: Hello World!")

    return render_template_string("An unexpected error occurred. Please try again later.")

if __name__ == "__main__":
    app.run(host='0.0.0.0', port=5000)