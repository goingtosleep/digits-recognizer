from flask import Flask, request, jsonify
import pickle
from datetime import datetime



app = Flask(__name__)

@app.route('/')
def hello_world():
    return 'Hello, World!'

def save(d, filename):
    with open(filename, 'wb') as handle:
        pickle.dump(d, handle, protocol=pickle.HIGHEST_PROTOCOL)


@app.route('/submit', methods = ['POST'])
def submit():
    data = request.get_json()
    if type(data) is dict:
        now = datetime.now()
        filename = f"{data['name']}--{now.day}-{now.month}_{now.hour}:{now.minute}.pkl"
        save(data, filename)

    response = jsonify({'response': 'ok'})
    return response

@app.after_request
def add_headers(response):
    response.headers.add('Access-Control-Allow-Origin', '*')
    response.headers.add('Access-Control-Allow-Headers', 'Content-Type,Authorization')
    return response

# app.run(debug=True)

