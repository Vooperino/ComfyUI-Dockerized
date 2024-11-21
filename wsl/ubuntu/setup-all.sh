#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Install required packages"
bash "${SCRIPT_DIR}/install-required-packages.sh"

echo "Building Image"
cd "${SCRIPT_DIR}"
cd "../../" 
sudo docker compose build --no-cache --pull