#!/bin/bash

if [ -z "${CNODE_GIT_CHECK_LATEST:-}" ]; then
    export CNODE_GIT_CHECK_LATEST="false"
fi

if [[ "${CNODE_GIT_CHECK_LATEST}" == "true" ]]; then
    for node in "${ROOT}/custom_nodes/"*/; do
        if [ -d "$node" ]; then
            echo "[INFO] (Custom-Node) Checking '$node' for latest commits"
            if [ -d "$node/.git" ]; then
                echo "[INFO] (Custom-Node) Checking '$node'..."
                git -C "$node" stash
                git -C "$node" fetch
                git -C "$node" pull
                git -C "$node" rebase
                echo "[INFO] (Custom-Node) Checked '$node'! Moving Forward..."
            else
                echo "[INFO] (Custom-Node) '$node' does not contain git. Skipping"
            fi
        fi
    done
fi