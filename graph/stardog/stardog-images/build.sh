#!/usr/bin/env bash
# --build-arg http_proxy=http://172.16.17.5:3128 \
# --build-arg https_proxy=http://172.16.17.5:3128 \
time docker build \
  -f Dockerfile-from-base-image \
  --tag gregoryg/dbnetutils:latest \
  --tag gregoryg/dbnetutils:9.2.0 \
  .
