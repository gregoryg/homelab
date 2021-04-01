import os
import requests
from flask import Flask
from jaeger_client import Config
from flask_opentracing import FlaskTracing

app = Flask(__name__)
config = Config(
    config={
        'sampler':
        {'type': 'const',
         'param': 1},
        'logging': True,
        'reporter_batch_size': 1},
    service_name="service")
jaeger_tracer = config.initialize_tracer()
tracing = FlaskTracing(jaeger_tracer, True, app)

def get_counter(counter_endpoint):
    counter_response = requests.get(counter_endpoint)
    return counter_response.text

def increase_counter(counter_endpoint):
    counter_response = requests.post(counter_endpoint)
    return counter_response.text

@app.route('/')
def hello_world():
    counter_service = os.environ.get('COUNTER_ENDPOINT', default="https://localhost:5000")
    counter_endpoint = f'{counter_service}/api/counter'
    counter = get_counter(counter_endpoint)

    increase_counter(counter_endpoint)

    return f"""Hello, World!

You're visitor number {counter} in here!\n\n"""
