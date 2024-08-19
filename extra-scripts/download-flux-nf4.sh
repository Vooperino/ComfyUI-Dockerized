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

echo "Checking if checkpoint module exists"
if [ ! -f "${ROOT}/checkpoints/flux1-dev-bnb-nf4-v2.safetensors" ]; then
    echo "File 'flux1-dev-bnb-nf4-v2.safetensors' was not found in the checkpoints. Downloading from 'https://huggingface.co/lllyasviel/flux1-dev-bnb-nf4' "
    cd "${ROOT}/models/checkpoints"
    wget https://huggingface.co/lllyasviel/flux1-dev-bnb-nf4/resolve/main/flux1-dev-bnb-nf4-v2.safetensors
fi

echo "Checking if upscale module exists"
echo "Checking for '4x-UltraSharp.pth'"
if [ ! -f "${ROOT}/upscale_models/4x-UltraSharp.pth" ]; then
    echo "File '4x-UltraSharp.pth' was not found in the checkpoints. Downloading from 'https://huggingface.co/vclansience/SD_lora' "
    cd "${ROOT}/models/upscale_models"
    wget https://huggingface.co/vclansience/SD_lora/resolve/main/4x-UltraSharp.pth
fi

echo "Checking for '4xUltrasharp_4xUltrasharpV10.pt'"
if [ ! -f "${ROOT}/upscale_models/4xUltrasharp_4xUltrasharpV10.pt" ]; then
    echo "File '4xUltrasharp_4xUltrasharpV10.pt' was not found in the checkpoints. Downloading from 'https://huggingface.co/vclansience/SD_lora' "
    cd "${ROOT}/models/upscale_models"
    wget https://huggingface.co/vclansience/SD_lora/resolve/main/4xUltrasharp_4xUltrasharpV10.pt
fi

echo "End of script"