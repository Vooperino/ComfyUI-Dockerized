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

bash /docker/scripts/install-comfyui-manager.sh
bash /docker/scripts/update-all-custom-nodes.sh

if [ -f "/data/config/startup.sh" ]; then
  pushd ${ROOT}
  . /data/config/startup.sh
  popd
fi

chmod -R 777 $ROOT/custom_nodes
process_directory "${ROOT}/custom_nodes"

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

#echo "[INFO] Starting Up ComfyUI (Web Port ${WEB_PORT})..."
#while true; do
#    python -u main.py --listen --port ${WEB_PORT} ${CLI_ARGS}
#    if [ $? -ne 0 ]; then
#        echo "Exited as 0."
#        break
#    else
#        echo "[WARN] ComfyUI has crashed, restarting..."
#    fi
#done


#cd "/opt/vlBootstrap"
#echo "[INFO] Starting ComfyUI using SupervisorD"
#supervisorctl start comfyui

supervisord -n -c /opt/vlBootstrap/supervisord.conf