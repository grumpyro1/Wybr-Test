from flask import Flask, request, jsonify # a small web server on your computer
import requests # server talk to other websites
from flask_cors import CORS


app = Flask(__name__) # middleman server
CORS(app)  # allow all origins for testing

BASE_URL = "https://fake-json-api.mock.beeceptor.com" # real API website we want to get data from

@app.route("/")
def home():
    return "Hello! This is my first server."


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

if __name__ == "__main__": # This starts the server on your computer.
    app.run(host="0.0.0.0", port=5000, debug=True) # http://127.0.0.1:5000 → this is where Flutter can ask for data.


# Browser/Flutter → Proxy → Real API → Proxy → Browser/Flutter
    
# #--- proxy to show product image from odoo/etc. ----#
#     @app.route("/proxy-image")
#     def proxy_image():
#         image_url = request.args.get("url")
#         if not image_url:
#             return "Missing URL", 400

#         try:
#             response = requests.get(image_url, headers={
#                 "User-Agent": "Mozilla/5.0"
#             })

#             if response.status_code != 200:
#                 return "Failed to fetch image", 502

#             return Response(
#                 response.content,
#                 content_type=response.headers.get("Content-Type"),
#                 headers={
#                     "Access-Control-Allow-Origin": "*",
#                     "Access-Control-Allow-Methods": "GET, OPTIONS",
#                     "Access-Control-Allow-Headers": "Content-Type"
#                 }
#             )
#         except Exception as e:
#             return str(e), 500
