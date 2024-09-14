import os
from flask import Flask, jsonify, request, render_template_string
from sqlalchemy import create_engine, text
from sqlalchemy.exc import SQLAlchemyError
import boto3
import requests
from datetime import datetime, timedelta
import logging

logging.basicConfig(level=logging.INFO)

app = Flask(__name__)

#for testing Flask app locally, outside of a container, uncomment the following:
os.environ['DB_HOST'] = "localhost"
os.environ['DB_NAME'] = "orders"
os.environ['DB_USER'] = "postgres"
os.environ['DB_PASSWORD'] = "postgres"
os.environ['PLATFORM'] = "Windows"
os.environ['FQDN_INVENTORY'] = "192.168.86.153"
os.environ['PORT_FLASK_INVENTORY'] = "5001"
os.environ['PORT_INVENTORY'] = os.getenv('PORT_FLASK_INVENTORY')
os.environ['PORT_FLASK_ORDERS'] = "5002"




# Reads environment variables that are set...
# in the Kubernetes config map (in the case of local testing), or, in...
# the ECS Task Definition, in the case of AWS deployment 
DB_HOST = os.getenv('DB_HOST')
DB_PORT = os.getenv('DB_PORT', 5432)  # Default to 5432 if not set
DB_USER = os.getenv('DB_USER')
DB_PASSWORD = os.getenv('DB_PASSWORD')
DB_NAME = os.getenv('DB_NAME')
PLATFORM = os.getenv('PLATFORM')
FQDN_INVENTORY = os.getenv('FQDN_INVENTORY')
PORT_INVENTORY = os.getenv('PORT_INVENTORY')
PORT_FLASK_ORDERS = os.getenv('PORT_FLASK_ORDERS')

# Create the database engine
DATABASE_URL = f"postgresql+psycopg2://{DB_USER}:{DB_PASSWORD}@{DB_HOST}:{DB_PORT}/{DB_NAME}"
engine = create_engine(DATABASE_URL)

# ECS configuration
ecs_client = boto3.client('ecs', region_name='us-east-1')
cluster_name = "your-ecs-cluster-name"

def get_order_count_hello():
    """
    Fetch the count of 'hello' orders in the last hour.
    """
    try:
        with engine.connect() as connection:
            # Run the SQL query to get the count of relevant orders
            # Note: end_time below is into future as hack to account for servers different time zones.
            query = text("SELECT COUNT(*) FROM orders WHERE time BETWEEN :start_time AND :end_time AND item = 'hello';")
            result = connection.execute(
                query,
                {
                "start_time": datetime.now() - timedelta(hours=24),
                "end_time": datetime.now() + timedelta(hours=24)
                })
            count = result.scalar()  # Get the first column of the first row
            return count
    except SQLAlchemyError as e:
        print(f"Database error: {e}")
        return 0

def append_order_to_orders_db_hello():
    """
    Add one 'hello' order to the orders db
    """
    try:
        with engine.connect() as connection:
            with connection.begin() as transaction:
            # Run the SQL query insert an order into the orders DB
                connection.execute(text("INSERT INTO orders (item) values ('hello')"))
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

@app.route('/', methods=['GET'])
def default():
    return "<html><body>There is nothing here. Try a URL that is actually meant to be used on this app.</bodu></html>"

@app.route('/orders/get/order_count/hello', methods=['GET'])
def call_get_order_count_hello():
    order_count = get_order_count_hello()
    return jsonify({"order count": order_count})

@app.route('/orders/delete/hello_all', methods=['DELETE'])
def delete_hello_all():
    try:
        with engine.connect() as connection:
            # Start a transaction
            with connection.begin() as transaction:
                # Update the count
                connection.execute(text("DELETE FROM orders WHERE item = 'hello';"))
            # Retrieve the current count
            # Note: The above SQL transaction is commited after the block ends...so these next lines needs to be in a new block
            new_order_count = get_order_count_hello()
            new_order_count_message = "The new order count is " + str(new_order_count)
            return jsonify({"message": new_order_count_message})
    except SQLAlchemyError as e:
        return jsonify({"error": str(e)}), 500

@app.route('/orders/put/order/hello', methods=['PUT'])
def order_hello():
    
    order_count = get_order_count_hello()
    return_strings = []
    # Safety check for too many nodes running...2 tasks is the max for us
    if PLATFORM == 'aws':
        current_count = get_ecs_service_task_count("orders")
        if current_count > 2:
            update_ecs_task_count("orders", 2)
            return_strings.append("Somehow more than two containers are running. Going to scale down.")
    elif PLATFORM == 'minikube':
        current_count = get_k8s_service_replica_count("orders-deployment")
        if current_count > 2:
            update_k8s_replica_count("orders-deployment", 2)
            return_strings.append("Somehow more than two containers are running. Going to scale down")

    if 3 < int(order_count) < 6:
        # Scale up if the order count is between 3 and 6
        if PLATFORM == 'aws':
            current_count = get_ecs_service_task_count("orders")
            update_ecs_task_count("orders", current_count + 1)
            return_strings.append("Not enough nodes to fulfill your order. Must increment nodes by one...please try again later.")
        elif PLATFORM == 'minikube':
            current_count = get_k8s_service_replica_count("orders-deployment")
            update_k8s_replica_count("orders-deployment", current_count + 1)
            return_strings.append("Not enough nodes to fulfill your order. Must increment nodes by one...please try again later.")
        elif PLATFORM == 'Windows':
            return_strings.append("Not enough nodes to fulfill your order. Must increment nodes by one...please try again later.")
            return_strings.append("Warning: The app is running on a Windows machine, not in containers. Manual steps are needed in this case.")

        return jsonify({"message": (" ".join(return_strings))})

    elif int(order_count) >= 6:
        # Return an error message if the order count is too high
        return jsonify({"message": "Our system cannot process any more orders. Please try again later."})
    
    #else - there are between 1 and 3 orders currently items...we can handle processing an order
    else:
        # Add an order to the orders DB and call the inventory service to check and update inventory and 
        inventory_response = requests.get(f'http://{FQDN_INVENTORY}:{PORT_INVENTORY}/inventory/get/hello').json()
        if inventory_response['count'] >= 1:
            append_order_to_orders_db_hello()
            requests.put(f'http://{FQDN_INVENTORY}:{PORT_INVENTORY}/inventory/update/remove/hello')
            return jsonify({"message": "Thank you for your order. Here it is: Hello World!"})
        else:
            return jsonify({"message": "There is no inventory left of what you ordered. Somebody needs to manually update inventory!"})


if __name__ == "__main__":
    app.run(host='0.0.0.0', port=PORT_FLASK_ORDERS)
