from flask import Flask, jsonify
import os

app = Flask(__name__)
VERSION = os.environ.get("VERSION", "v1")

@app.route("/")
def hello():
    return jsonify({"message": f"Hello from backend {VERSION}!"})

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)
