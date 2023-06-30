#!/bin/bash

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
python3 -m pip install --no-cache-dir --upgrade pip setuptools wheel deepsparse[server,yolo,onnxruntime,yolov8,transformers,image_classification]

# Enable firewall 
echo "y" | ufw enable
ufw allow ssh
ufw allow http
ufw allow https
ufw allow 5543 # for DeepSparse server