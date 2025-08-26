from flask import Flask, request, jsonify # a small web server on your computer
import requests # server talk to other websites
from flask_cors import CORS


app = Flask(__name__) # middleman server
CORS(app)  # allow all origins for testing

BASE_URL = "https://fake-json-api.mock.beeceptor.com" # real API website we want to get data from
ODOO_URL = "https://wybr.odoo.com/jsonrpc"
_odooDb = "wybr"
_odooUid = 2
_odooPassword = "roanmiles123"
@app.route("/")
def home():
    return "Proxy is running!"

@app.route("/proxy/<path:endpoint>", methods=["GET", "POST"]) # Hey, if someone goes to http://127.0.0.1:5000/proxy/something, run this code.
def proxy(endpoint): # The endpoint part is whatever comes after /proxy/, like users or companies.
    try:
        url = f"{BASE_URL}/{endpoint}" # Combines our base API URL and the endpoint the user wants: BASE_URL + users → https://fake-json-api.mock.beeceptor.com/users

        if request.method == "GET": # If Flutter (or a browser) asks for data (GET):
            resp = requests.get(url) # Our proxy goes to the real API and grabs the data. The proxy goes to https://fake-json-api.mock.beeceptor.com/users and fetches the JSON data.
            return jsonify(resp.json()), resp.status_code # Sends the data back to Flutter. Proxy sends the reply back to you

        if request.method == "POST": # If Flutter sends data (POST):
            data = request.get_json() # Our proxy forwards the data to the real API
            resp = requests.post(url, json=data, headers={"Content-Type": "application/json"})
            return jsonify(resp.json()), resp.status_code # Sends back the API’s response
    
    except Exception as e:
        return {"error": str(e)}, 500 # "Oops, something broke"

# # New route to fetch products from Odoo
@app.route("/odoo/products", methods=["GET", "POST"])
def fetch_products():
    try:
        payload = {
            "jsonrpc": "2.0",
            "method": "call",
            "params": {
                "service": "object",
                "method": "execute_kw",
                "args": [
                    _odooDb,
                    _odooUid,
                    _odooPassword,
                    "product.product",
                    "search_read",
                    [],   # empty domain
                    {"fields": ["name", "default_code", "list_price"], "limit": 10}
                ]
            },
            "id": 3
        }
        
        resp = requests.post(ODOO_URL, json=payload, headers={"Content-Type": "application/json"})
        return jsonify(resp.json()), resp.status_code # Sends back the Odoo API’s response

    except Exception as e:
        return {"error": str(e)}, 500 # "Oops, something broke"

@app.route("/odoo/add_product", methods=["POST"])
def add_product():
    try:
        data = request.get_json()  # expects { "name": "...", "default_code": "...", "list_price": ... }

        payload = {
            "jsonrpc": "2.0",
            "method": "call",
            "params": {
                "service": "object",
                "method": "execute_kw",
                "args": [
                    _odooDb,
                    _odooUid,
                    _odooPassword,
                    "product.product",
                    "create",
                    [data]  # 👈 pass the product fields
                ]
            },
            "id": 4
        }

        resp = requests.post(ODOO_URL, json=payload, headers={"Content-Type": "application/json"})
        return jsonify(resp.json()), resp.status_code

    except Exception as e:
        return {"error": str(e)}, 500


if __name__ == "__main__": # This starts the server on your computer.
    app.run(host="0.0.0.0", port=5000, debug=True) # http://127.0.0.1:5000 → this is where can ask for data.

# Browser/Flutter → Proxy → Real API → Proxy → Browser/Flutter
