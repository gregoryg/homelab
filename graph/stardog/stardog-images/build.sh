#!/usr/bin/env bash
     # --build-arg http_proxy=http://172.16.17.5:3128 \
     # --build-arg https_proxy=http://172.16.17.5:3128 \
time docker build \
     --tag gregoryg/dbnetutils:latest \
     --tag gregoryg/dbnetutils:8.2 .
