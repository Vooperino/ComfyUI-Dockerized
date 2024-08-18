#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Setting up docker"
bash "${SCRIPT_DIR}/install-docker.sh"
echo "Setting up nvidia container docker runtime"
bash "${SCRIPT_DIR}/install-nvidia-container-runtime.sh"

echo "Building Image"
cd ../../
sudo docker compose build --no-cache