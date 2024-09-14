
import os
from flask import Flask, jsonify, request
from sqlalchemy import create_engine, text
from sqlalchemy.exc import SQLAlchemyError
import logging

logging.basicConfig(level=logging.INFO)

app = Flask(__name__)

#for testing Flask app locally, outside of a container, uncomment the following:
os.environ['DB_HOST'] = 'localhost'
os.environ['DB_NAME'] = "inventory"
os.environ['DB_USER'] = "postgres"
os.environ['DB_PASSWORD'] = "postgres"
os.environ['PLATFORM'] = "Windows"
os.environ['PORT_FLASK_INVENTORY'] = "5001"


# Reads environment variables that are set...
# in the Kubernetes config map (in the case of local testing), or, in...
# the ECS Task Definition, in the case of AWS deployment 
DB_HOST = os.getenv('DB_HOST')
DB_PORT = os.getenv('DB_PORT', 5432)  # Default to 5432 if not set
DB_USER = os.getenv('DB_USER')
DB_PASSWORD = os.getenv('DB_PASSWORD')
DB_NAME = os.getenv('DB_NAME')
PORT_FLASK_INVENTORY = os.getenv('PORT_FLASK_INVENTORY')

# Create the database engine
DATABASE_URL = f"postgresql+psycopg2://{DB_USER}:{DB_PASSWORD}@{DB_HOST}:{DB_PORT}/{DB_NAME}"
engine = create_engine(DATABASE_URL)

@app.route('/', methods=['GET'])
def default():
    return "<html><body>There is nothing here. Try a URL that is actually meant to be used on this app.</bodu></html>"

@app.route('/inventory/get/hello', methods=['GET'])
def get_inventory():
    try:
        # Open a connection
        with engine.connect() as connection:
            # Execute the raw SQL query
            result = connection.execute(text("SELECT count FROM inventory WHERE item = 'hello';"))
            count = result.scalar()  # Get the first column of the first row
            if count is not None:
                return jsonify({"count": count})
            else:
                return jsonify({"error": "Item not found"}), 404
    except SQLAlchemyError as e:
        return jsonify({"error": str(e)}), 500


@app.route('/inventory/patch/hello_20', methods=['PATCH'])
def update_inventory_add_hello_20():
    try:
        with engine.connect() as connection:
            # Start a transaction
            with connection.begin() as transaction:
                # Update the count
                connection.execute(text("UPDATE inventory SET count = 20 where item = 'hello'"))
            
            # Retrieve the current count
            # Note: The above SQL transaction is commited after the block ends...so these next lines needs to be in a new block
            new_inventory = connection.execute(text("SELECT count FROM inventory WHERE item = 'hello';"))
            new_count_message = "The new count is " + str(new_inventory.scalar())
            return jsonify({"message": new_count_message})
    except SQLAlchemyError as e:
        return jsonify({"error": str(e)}), 500

@app.route('/inventory/update/remove/hello', methods=['PUT'])
def update_inventory_remove_hello():
    try:
        with engine.connect() as connection:
            # Start a transaction
            with connection.begin() as transaction:
                # Retrieve the current count
                result = connection.execute(text("SELECT count FROM inventory WHERE item = 'hello' AND count > 0;"))
                current_count = result.fetchone()[0]

                if current_count:
                    new_count = current_count - 1

                    # Update the inventory with the new count
                    update_result = connection.execute(
                        text("UPDATE inventory SET count = :new_count WHERE item = 'hello' AND count = :current_count RETURNING count;"),
                        {"new_count": new_count, "current_count": current_count}
                    )

                    if update_result.rowcount > 0:
                        transaction.commit()  # Commit the transaction if successful
                        return jsonify({"message": "Inventory updated."})
                    else:
                        transaction.rollback()  # Rollback the transaction if no rows were updated
                        return jsonify({"error": "Insufficient inventory or item not found"}), 400
                else:
                    transaction.rollback()  # Rollback if item is not found
                    return jsonify({"error": "Item not found"}), 404
    except SQLAlchemyError as e:
        return jsonify({"error": str(e)}), 500

if __name__ == "__main__":
    app.run(host='0.0.0.0', port=PORT_FLASK_INVENTORY)