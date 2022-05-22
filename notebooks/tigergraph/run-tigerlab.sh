#!/usr/bin/env bash
# conda activate tigerlab
echo PLEASE ACTIVATE tigerlab Python venv!
jupyter lab --ip=0.0.0.0 \
        --port=8888 \
        --no-browser \
        --notebook-dir=~/projects/homelab/notebooks \
        --ResourceUseDisplay.track_cpu_percent=True
