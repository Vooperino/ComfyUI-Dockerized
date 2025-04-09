#!/bin/bash

PERMISSION_NUM=777
TARGET_DIRS=(
  "/data/models"
  "/output"
)

echo "[Perm-fix] Permission updater started"

while true; do
    for dir in "${TARGET_DIRS[@]}"; do
        mkdir -p "$dir"
        chmod -R $PERMISSION_NUM "$dir"
        echo "[Perm-fix] Updated permissions on $dir"
    done
    sleep 10
done