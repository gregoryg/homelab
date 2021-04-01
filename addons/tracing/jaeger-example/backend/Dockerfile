FROM alpine:3.8

RUN apk add --no-cache py3-pip python3 && \
    pip3 install flask Flask-Opentracing jaeger-client

COPY . /usr/src/backend

ENV FLASK_APP backend.py

WORKDIR /usr/src/backend

CMD flask run --host=0.0.0.0 --port=5000
