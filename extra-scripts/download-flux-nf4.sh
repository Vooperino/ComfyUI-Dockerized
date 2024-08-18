#!/bin/bash

echo "Checking for custom node is installed"

if [ ! -d "${ROOT}/custom_nodes/ComfyUI_bitsandbytes_NF4" ]; then
    echo "Custom Node 'ComfyUI_bitsandbytes_NF4' was not found and is required. Downloading using Git"
    git clone https://github.com/comfyanonymous/ComfyUI_bitsandbytes_NF4.git "${ROOT}/custom_nodes/ComfyUI_bitsandbytes_NF4"
    if [ -d "${ROOT}/custom_nodes/ComfyUI_bitsandbytes_NF4" ]; then
        echo "Success! Once you this is executed you need to restart this container!"
        sleep 2s
    fi
else
    echo "Custom Node 'ComfyUI_bitsandbytes_NF4' is installed!"
fi

echo "Checking if module exists"
if [ ! -f "${ROOT}/checkpoints/flux1-dev-bnb-nf4-v2.safetensors" ]; then
    echo "File 'flux1-dev-bnb-nf4-v2.safetensors' was not found in the checkpoints. Downloading from 'https://huggingface.co/lllyasviel/flux1-dev-bnb-nf4' "
    cd "${ROOT}/checkpoints"
    wget https://huggingface.co/lllyasviel/flux1-dev-bnb-nf4/resolve/main/flux1-dev-bnb-nf4-v2.safetensors
fi

echo "End of script"