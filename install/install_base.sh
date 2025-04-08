#!/bin/bash

set -o pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP_DIR="/comfyui"
CLEAN_CONF_PATH="/CLEAN_CONFIG"
DOCKER_ROOT="/docker"

BOOTSTRAP_PATH="/opt/vlBootstrap"

echo "[INFO] Installing Required Linux Packages and Updates"
apt-get -qq update
apt-get -qq install -y git wget curl gcc g++ ffmpeg libsm6 libxext6 libglfw3-dev libgles2-mesa-dev pkg-config libcairo2 libcairo2-dev build-essential fonts-dejavu-core rsync git jq yq moreutils aria2 supervisord
apt-get -qq full-upgrade -y
apt-get -qq clean

if [ -d "${APP_DIR}" ]; then
    echo "[WARNING] Found '${APP_DIR}' that exists! Purging Directory..."
    rm -rf "${APP_DIR}"
fi

mkdir -p "${APP_DIR}"

if [ ! -d "${BOOTSTRAP_PATH}" ]; then
    echo "[INFO] Creating VLBootstrap"
    mkdir -p ${BOOTSTRAP_PATH}
fi

if [ -f "${BOOTSTRAP_PATH}/supervisord.conf" ]; then
    rm "${BOOTSTRAP_PATH}/supervisord.conf" || true
fi

cp "${DOCKER_ROOT}/supervisord.conf" "${BOOTSTRAP_PATH}/supervisord.conf"
chmod -R 755 "${BOOTSTRAP_PATH}/supervisord.conf"

cp "${DOCKER_ROOT}/internal_cmds/startComfy.sh" "/usr/bin/startComfy"
cp "${DOCKER_ROOT}/internal_cmds/stopComfy.sh" "/usr/bin/stopComfy"

chmod -R 755 /usr/bin/startComfy /usr/bin/stopComfy

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

cd ${SCRIPT_DIR}
python3 ./copy_status_page.py

exit 0