#!/bin/bash

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
    echo "[INFO] Validating Custom Nodes Directory!"
    local dir="$1"
    if [[ -d "${dir}" ]]; then
        for sub_dir in "${dir}"/*; do
            if [[ -d "${sub_dir}" ]]; then
                install_requirements "${sub_dir}"
                process_install_py "${sub_dir}" || true
            fi
        done
    else
        echo "[Error] ${dir} is not a directory."
    fi
}

mkdir -vp /data/config/custom_nodes
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

process_directory "/comfyui/custom_nodes"

supervisord -c /opt/vlBootstrap/supervisord.conf
startComfy