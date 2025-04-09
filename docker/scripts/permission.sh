#!/bin/bash

TARGET_DIRS=(
  "/data/models"
  "/output"
)

while true; do
    for dir in "${TARGET_DIRS[@]}"; do
        if [ ! -z "$dir" ]; then
            if [ -d "$dir" ]; then
                chmod -R 777 "$dir"
            fi
        fi
    done
    sleep 10
done