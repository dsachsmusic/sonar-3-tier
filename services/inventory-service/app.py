from flask import Flask, jsonify, request
from sqlalchemy import create_engine, text
from sqlalchemy.exc import SQLAlchemyError

app = Flask(__name__)

# Database configuration
DB_USERNAME = "your_db_username"
DB_PASSWORD = "your_db_password"
DB_HOST = "your-inventory-db-host"
DB_NAME = "inventory_world"

# Create the database engine
DATABASE_URL = f"postgresql+psycopg2://{DB_USERNAME}:{DB_PASSWORD}@{DB_HOST}/{DB_NAME}"
engine = create_engine(DATABASE_URL)

@app.route('/inventory_hello', methods=['GET'])
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

@app.route('/pick-and-pack-hello', methods=['PUT'])
def update_inventory():
    try:
        # Open a connection
        with engine.connect() as connection:
            # Start a transaction
            with connection.begin() as transaction:
                # Execute the raw SQL query to update the inventory
                result = connection.execute(text("UPDATE inventory SET count = count - 1 WHERE item = 'hello' AND count > 0 RETURNING count;"))
                if result.rowcount > 0:
                    transaction.commit()  # Commit the transaction if successful
                    return jsonify({"message": "Inventory updated."})
                else:
                    transaction.rollback()  # Rollback the transaction if no rows were updated
                    return jsonify({"error": "Insufficient inventory or item not found"}), 400
    except SQLAlchemyError as e:
        return jsonify({"error": str(e)}), 500

if __name__ == "__main__":
    app.run(host='0.0.0.0', port=5000)
