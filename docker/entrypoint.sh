#!/bin/bash

if [ -z "${DEBUG:-}" ]; then
    export DEBUG=false
fi

if [ "$DEBUG" = "true" ]; then
    echo "[DEBUG] Extra Debugging is enabled"
    echo "[DEBUG] Displaying Project Env Values"
    echo "DL_CUI_MANAGER => ${DL_CUI_MANAGER:-}"
    echo "CNODE_GIT_CHECK_LATEST => ${CNODE_GIT_CHECK_LATEST:-}"
    echo "[DEBUG] Sleeping for 5 Seconds"
    sleep 5s
fi

if grep -qEi "(Microsoft|WSL)" /proc/version &> /dev/null; then
    echo "======== WSL NOTICE ========"
    echo "You are now executing this container in WSL, which can make the system unstable and unresponsive."
    echo " "
    echo "You've been warned. Use it with caution!"
    echo " "
    echo "Application will start in 5 seconds"
    sleep 5s
fi

echo "[INFO] Checking, before launching..."
echo "[INFO] Checking and validating app directory"
if [ -z "${ROOT}" ]; then
    echo "[IMAGE ISSUE] Required Env var 'ROOT' returning as empty or none, which is not a expected!"
    exit 1
fi

if [ ! -d "${ROOT}" ]; then
    echo "[IMAGE ISSUE] App Dir '${ROOT}' is not found! Build issue?"
    exit 1
fi

if [ -z "$(find "${ROOT}" -mindepth 1 -exec echo {} \;)" ]; then
    echo "[IMAGE ISSUE] App Dir '${ROOT}' is empty! Build issue?"
    exit 1
fi

if [ ! -d "/CLEAN_CONFIG/web/extensions" ]; then
    echo "[IMAGE ISSUE] Clean CFG '/CLEAN_CONFIG/web/extensions/' is not found! Build issue?"
    exit 1
fi

if [ -z "$(find "/CLEAN_CONFIG/web/extensions" -mindepth 1 -exec echo {} \;)" ]; then
    echo "[IMAGE ISSUE] Clean CFG '/CLEAN_CONFIG/web/extensions/' is empty! Build issue?"
    exit 1
fi

mkdir -vp /data/config/custom_nodes
mkdir -vp /data/config/web-extensions
mkdir -vp /comfyui/custom_nodes

mkdir -vp /data/models/upscale_models
mkdir -vp /data/models/GLIGEN
mkdir -vp /data/models/CLIPEncoder
mkdir -vp /data/models/sams
mkdir -vp /data/models/seecoders
mkdir -vp /data/models/mmdets
mkdir -vp /data/models/onnx
mkdir -vp /data/models/insightface

declare -A MOUNTS

MOUNTS["/root/.cache"]="/data/.cache"
MOUNTS["${ROOT}/input"]="/data/config/input"
MOUNTS["${ROOT}/custom_nodes"]="/data/config/custom_nodes"

MOUNTS["${ROOT}/user"]="/data/config/user-data"

MOUNTS["${ROOT}/output"]="/output"

MOUNTS["${ROOT}/models/vae_approx"]="/data/models/VAE-approx"
MOUNTS["${ROOT}/models/vae"]="/data/models/VAE"
MOUNTS["${ROOT}/models/loras"]="/data/models/Lora"
MOUNTS["${ROOT}/models/gligen"]="/data/models/GLIGEN"
MOUNTS["${ROOT}/models/controlnet"]="/data/models/ControlNet"
MOUNTS["${ROOT}/models/hypernetworks"]="/data/models/hypernetworks"
MOUNTS["${ROOT}/models/upscale_models"]="/data/models/upscale_models"
MOUNTS["${ROOT}/models/embeddings"]="/data/models/embeddings"
MOUNTS["${ROOT}/models/checkpoints"]="/data/models/checkpoints"
MOUNTS["${ROOT}/models/sams"]="/data/models/sams"
MOUNTS["${ROOT}/models/seecoders"]="/data/models/seecoders"
MOUNTS["${ROOT}/models/mmdets"]="/data/models/mmdets"
MOUNTS["${ROOT}/models/onnx"]="/data/models/onnx"
MOUNTS["${ROOT}/models/insightface"]="/data/models/insightface"
MOUNTS["${ROOT}/models/clip"]="/data/models/clip"
MOUNTS["${ROOT}/models/unet"]="/data/models/unet"

function install_requirements() {
    local dir="$1"
    if [[ -f "${dir}/requirements.txt" ]]; then
        echo "Installing requirements for ${dir}..."
        pip install -r "${dir}/requirements.txt"
        echo "Requirements installed for ${dir}."
    else
        echo "No requirements.txt found in ${dir}. Skipping."
    fi
}

function process_install_py() {
    local dir="$1"
    if [[ -f "${dir}/install.py" ]]; then
        python3 ${dir}/install.py
    fi
}

function process_directory() {
    local dir="$1"
    if [[ -d "${dir}" ]]; then
        for sub_dir in "${dir}"/*; do
            if [[ -d "${sub_dir}" ]]; then
                install_requirements "${sub_dir}"
                process_install_py "${sub_dir}" || true
            fi
        done
    else
        echo "Error: ${dir} is not a directory."
    fi
}

function copyFreshExtenstion() {
  echo Copying fresh copy of web-extensions core
  cp -r -f -v "/CLEAN_CONFIG/web/extensions/." "${ROOT}/web/extensions/."
}


for to_path in "${!MOUNTS[@]}"; do
  set -Eeuo pipefail
  from_path="${MOUNTS[${to_path}]}"
  rm -rf "${to_path}"
  if [ ! -d "$from_path" ]; then
    echo "[INFO] Creating Direcotory '$from_path' and applying permissions"
    mkdir -vp "$from_path"
  fi
  chmod -R 777 "$from_path"
  mkdir -vp "$(dirname "${to_path}")"
  ln -sT "${from_path}" "${to_path}"
  echo Mounted $(basename "${from_path}")
done

bash /docker/scripts/install-comfyui-manager.sh
bash /docker/scripts/update-all-custom-nodes.sh

if [ -f "/data/config/startup.sh" ]; then
  pushd ${ROOT}
  . /data/config/startup.sh
  popd
fi

chmod -R 777 $ROOT/custom_nodes
process_directory "${ROOT}/custom_nodes"

WEB_EXTENSIONS="${ROOT}/web/extensions"

if [ -z "$(find "${WEB_EXTENSIONS}" -mindepth 1)" ]; then
  echo "[WARNING] Web Extensions are empty"
  copyFreshExtenstion
fi

if [ -f "/data/config/startup.sh" ]; then
  pushd ${ROOT}
  . /data/config/startup.sh
  popd
fi

exec "$@"
if [ -z "${CLI_ARGS}" ]; then
    echo "[WARN] No Cli Args was found..."
fi

DEFAULT_PORT="7860"

echo "[INFO] Checking Web Port"

if [ -z "${WEB_PORT:-}" ]; then
    export WEB_PORT="${DEFAULT_PORT}"
    echo "[WARN] Using Default Web Port ${WEB_PORT}"
fi

if ! [[ "${WEB_PORT}" =~ ^[0-9]+$ ]]; then
    echo "[WARN] Given Web Port is '${WEB_PORT}' which required to be integer value. Defaulting to ${DEFAULT_PORT}"
    unset WEB_PORT
    export WEB_PORT="${DEFAULT_PORT}"
fi

if lsof -i -P -n | grep -q ":$WEB_PORT "; then
    echo "[ERROR] Port ${WEB_PORT} already in-use! Exiting"
    exit 1
fi

sed -i "s/%WEB_PORT%/${WEB_PORT}/g" /docker/scripts/docker-health.sh

echo "[INFO] Final Checkup..."
if [ ! -f "${ROOT}/web/docker-up.html" ]; then
    cp -r -f "/CLEAN_CONFIG/docker-up.html" "${ROOT}/web"
fi

echo "[INFO] Starting Up ComfyUI (Web Port ${WEB_PORT})..."
while true; do
    python -u main.py --listen --port ${WEB_PORT} ${CLI_ARGS}
    if [ $? -ne 0 ]; then
        echo "Exited as 0."
        break
    else
        echo "[WARN] ComfyUI has crashed, restarting..."
    fi
done