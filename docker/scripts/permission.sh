#!/bin/bash

PERMISSION_NUM=777
TARGET_DIRS=(
  "/data/models"
  "/output"
)

while true; do
    for dir in "${TARGET_DIRS[@]}"; do
        mkdir -p "$dir"
        chmod -R $PERMISSION_NUM "$dir"
    done
    sleep 10
done