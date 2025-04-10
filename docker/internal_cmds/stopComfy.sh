#!/bin/bash

cd "/opt/vlBootstrap"

echo "[INFO] Stopping ComfyUI using SupervisorD"
supervisorctl stop comfyui