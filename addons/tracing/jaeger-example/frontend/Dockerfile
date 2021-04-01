FROM alpine:3.8

RUN apk add --no-cache py3-pip python3 && \
    pip3 install flask requests Flask-Opentracing jaeger-client

COPY . /usr/src/frontend

ENV FLASK_APP frontend.py

WORKDIR /usr/src/frontend

CMD flask run --host=0.0.0.0 --port=8000
