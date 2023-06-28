#!/bin/bash

set -Eeuxo \
    && apt-get update \
    && apt-get install ffmpeg libsm6 libxext6  -y \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends git \
    && python3.8 -m venv $VENV \
    && $VENV/bin/pip install --no-cache-dir --upgrade pip setuptools wheel

VENV="/venv"

# Create the deepsparse user
useradd --home-dir /home/deepsparse \
        --shell /bin/bash \
        --create-home \
        --system \
        deepsparse

# Setup the home directory
chown -R deepsparse: /home/deepsparse
chmod 755 /home/deepsparse

# Install DeepSparse
python3 -m pip install deepsparse[server,yolo,onnxruntime,yolov8,transformers,image_classification]"
