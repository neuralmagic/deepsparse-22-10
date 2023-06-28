#!/bin/bash

# update apt
apt-get -y update
apt-get -y upgrade

# Create the deepsparse user
useradd --home-dir /home/deepsparse \
        --shell /bin/bash \
        --create-home \
        --system \
        deepsparse

# Setup the home directory
chown -R deepsparse: /home/deepsparse
chmod 755 /home/deepsparse

# Replace with the version of DeepSparse you want to install:
VERSION=${DEEPSPARSE_VERSION}

# Install Flask
python3 -m pip install deepsparse=="$VERSION"
