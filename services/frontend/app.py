from flask import Flask, request, jsonify, render_template_string
import requests
import os
from flask_cors import CORS

app = Flask(__name__)
CORS(app)
#for testing Flask app locally, outside of a container, uncomment the following:
os.environ['FQDN_INVENTORY'] = "192.168.86.153"
os.environ['PORT_INVENTORY'] = "5001" #for local testing, use port we have our inventory app run on for testing
os.environ['FQDN_ORDERS'] = "192.168.86.153"
os.environ['PORT_ORDERS'] = "5002" # for local testing...
os.environ['FQDN_FRONTEND_EXTERNAL'] = "192.168.86.153"
os.environ['PORT_FLASK_FRONTEND'] = "5000" # for local testing...no change from Flask default for frontend service
os.environ['PORT_FRONTEND_EXTERNAL'] = os.getenv('PORT_FLASK_FRONTEND')


FQDN_INVENTORY = os.getenv('FQDN_INVENTORY')
PORT_INVENTORY = os.getenv('PORT_INVENTORY')
FQDN_ORDERS = os.getenv('FQDN_ORDERS')
PORT_ORDERS = os.getenv('PORT_ORDERS')
FQDN_FRONTEND_EXTERNAL = os.getenv('FQDN_FRONTEND_EXTERNAL')
PORT_FRONTEND_EXTERNAL = os.getenv('PORT_FRONTEND_EXTERNAL')
PORT_FLASK_FRONTEND = os.getenv('PORT_FLASK_FRONTEND')

def build_url(fqdn, port, path):
    return f"http://{fqdn}:{port}{path}"

@app.route('/api/get_order_count_hello', methods=['GET'])
def get_order_count_hello():
    url = build_url(FQDN_ORDERS, PORT_ORDERS, "/orders/get/order_count/hello")
    try:
        response = requests.get(url)
        response.raise_for_status()
        return jsonify(response.json())
    except requests.RequestException as e:
        return jsonify({"error": str(e)}), 500

@app.route('/api/delete_all_orders_hello', methods=['DELETE'])
def delete_all_orders_hello():
    url = build_url(FQDN_ORDERS, PORT_ORDERS, "/orders/delete/hello_all")
    try:
        response = requests.delete(url)
        response.raise_for_status()
        return jsonify(response.json())
    except requests.RequestException as e:
        return jsonify({"error": str(e)}), 500

@app.route('/api/place_order_hello', methods=['PUT'])
def place_order_hello():
    url = build_url(FQDN_ORDERS, PORT_ORDERS, "/orders/put/order/hello")
    try:
        response = requests.put(url)
        response.raise_for_status()
        return jsonify(response.json())
    except requests.RequestException as e:
        return jsonify({"error": str(e)}), 500

@app.route('/api/get_inventory_count_hello', methods=['GET'])
def get_inventory_count_hello():
    url = build_url(FQDN_INVENTORY, PORT_INVENTORY, "/inventory/get/hello")
    try:
        response = requests.get(url)
        response.raise_for_status()
        return jsonify(response.json())
    except requests.RequestException as e:
        return jsonify({"error": str(e)}), 500

@app.route('/api/set_inventory_count_hello_20', methods=['PATCH'])
def set_inventory_count_hello_20():
    url = build_url(FQDN_INVENTORY, PORT_INVENTORY, "/inventory/patch/hello_20")
    try:
        response = requests.patch(url)
        response.raise_for_status()
        return jsonify(response.json())
    except requests.RequestException as e:
        return jsonify({"error": str(e)}), 500

@app.route('/api/remove_inventory_hello', methods=['PUT'])
def remove_inventory_hello():
    url = build_url(FQDN_INVENTORY, PORT_INVENTORY, "/inventory/update/remove/hello")
    try:
        response = requests.put(url)
        response.raise_for_status()
        return jsonify(response.json())
    except requests.RequestException as e:
        return jsonify({"error": str(e)}), 500

@app.route('/', methods=['GET'])
def api_frontend():
    return render_template_string('''
    <!DOCTYPE html>
    <html>
    <head>
        <title>API Frontend</title>
        <script>
            const FQDN_FRONTEND_EXTERNAL = "{{ fqdn_frontend_external }}";
            const PORT_FRONTEND_EXTERNAL = "{{ port_frontend_external }}";
            const BASE_URL = `http://${FQDN_FRONTEND_EXTERNAL}:${PORT_FRONTEND_EXTERNAL}`;

            function sendRequest(method, url, body = null) {
                fetch(`${BASE_URL}${url}`, {
                    method: method,
                    headers: {
                        'Content-Type': 'application/json'
                    },
                    body: body ? JSON.stringify(body) : null
                })
                .then(response => {
                    const contentType = response.headers.get("content-type");
                    if (contentType && contentType.includes("application/json")) {
                        return response.json();
                    } else {
                        return response.text().then(text => { throw new Error(text); });
                    }
                })
                .then(data => alert(JSON.stringify(data)))
                .catch(error => alert('Error: ' + error));
            }

            function getOrderCountHello() {
                sendRequest('GET', '/api/get_order_count_hello');
            }
            
            function deleteAllOrdersHello() {
                sendRequest('DELETE', '/api/delete_all_orders_hello');
            }
            
            function placeOrderHello() {
                sendRequest('PUT', '/api/place_order_hello');
            }
            
            function getInventoryCountHello() {
                sendRequest('GET', '/api/get_inventory_count_hello');
            }
            
            function setInventoryCountHello20() {
                sendRequest('PATCH', '/api/set_inventory_count_hello_20');
            }
            
            function removeInventoryHello() {
                sendRequest('PUT', '/api/remove_inventory_hello');
            }    
        </script>
    </head>
    <body>
        <h1>API Frontend</h1>
        <p><button onclick="getOrderCountHello()">Get Order Count for 'hello'</button></p>
        <p><button onclick="deleteAllOrdersHello()">Delete All 'hello' Orders</button></p>
        <p><button onclick="placeOrderHello()">Place an Order for 'hello'</button></p>
        <p><button onclick="getInventoryCountHello()">Get Inventory Count for 'hello'</button></p>
        <p><button onclick="setInventoryCountHello20()">Set Inventory Count for 'hello' to 20</button></p>
        <p><button onclick="removeInventoryHello()">Remove 1 from Inventory Count for 'hello'</button></p>
    </body>
    </html>
    ''', fqdn_frontend_external=FQDN_FRONTEND_EXTERNAL, port_frontend_external=PORT_FRONTEND_EXTERNAL)

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=int(PORT_FLASK_FRONTEND))