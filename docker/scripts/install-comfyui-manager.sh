#!/bin/bash

if [ -z "${DL_CUI_MANAGER:-}" ]; then
    export DL_CUI_MANAGER="false"
fi

if [[ ${DL_CUI_MANAGER} == "true" ]]; then
    CUI_MANAGER_PATH="${ROOT}/custom_nodes/ComfyUI-Manager"
    if [ ! -d "${CUI_MANAGER_PATH}" ]; then
        echo "[INFO] ComfyUI-Manager was not found! Installing"
        git clone https://github.com/ltdrdata/ComfyUI-Manager.git "${CUI_MANAGER_PATH}"
    else
        echo "[INFO] Seems like ComfyUI-Manager already exist!"
    fi
fi
