#!/bin/bash

set -o pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP_DIR="/comfyui"
CLEAN_CONF_PATH="/CLEAN_CONFIG"
DOCKER_ROOT="/docker"

echo "[INFO] Installing Required Linux Packages and Updates"
apt-get -qq update
apt-get -qq install -y git wget curl gcc g++ ffmpeg libsm6 libxext6 libglfw3-dev libgles2-mesa-dev pkg-config libcairo2 libcairo2-dev build-essential fonts-dejavu-core rsync git jq moreutils aria2 
apt-get -qq full-upgrade -y
apt-get -qq clean

if [ -d "${APP_DIR}" ]; then
    echo "[WARNING] Found '${APP_DIR}' that exists! Purging Directory..."
    rm -rf "${APP_DIR}"
fi

mkdir -p "${APP_DIR}"

echo "[INFO] Pulling Latest ComfyUI from GitHub"
git clone https://github.com/comfyanonymous/ComfyUI.git "${APP_DIR}"

echo "[INFO] Preparing for Docker executions for image"
if [ ! -d "${DOCKER_ROOT}" ]; then
    echo "[ERROR] Unsupported action was caught. '${DOCKER_ROOT}' was not found "
    exit 1
fi

echo "[INFO] Installing PIP Requirements..."
pip install -r "${APP_DIR}/requirements.txt"

mkdir "${DOCKER_ROOT}"
echo "[INFO] Copying files"
mv "${DOCKER_ROOT}/extra_model_paths.yaml" "${APP_DIR}/"

echo "[INFO] Creating Clean Configuration"

if [ -d "${CLEAN_CONF_PATH}" ]; then
    rm -rf "${CLEAN_CONF_PATH}"
fi

mkdir -p "${CLEAN_CONF_PATH}/web/extensions"
cp -r -f "${SCRIPT_DIR}/docker-up.html" "${CLEAN_CONF_PATH}/docker-up.html"

echo "[INFO] Copying Configuration"
cp -r -f "${APP_DIR}/web/extensions/." "${CLEAN_CONF_PATH}/web/extensions/."
if [ -z "$(find "${CLEAN_CONF_PATH}/web/extensions" -mindepth 1 -exec echo {} \;)" ]; then
    echo "[BUILD SCRIPT ERROR] Unable to generate Clean Configuration. Error: Nothing in directory..."
    exit 1
fi

rm -rf "${APP_DIR}/web/extensions"
cp -r -f "${SCRIPT_DIR}/docker-up.html" "${APP_DIR}/web"

exit 0