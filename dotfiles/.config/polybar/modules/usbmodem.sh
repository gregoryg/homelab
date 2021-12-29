#!/bin/bash

ip -4 addr show "$1" 2>&1 | grep -oP '(?<=inet\s)\d+(\.\d+){3}'