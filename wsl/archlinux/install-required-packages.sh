#!/bin/bash

sudo pacman --noconfirm -Syu 

echo "Force Updating Keyring..."
sudo pacman --noconfirm -S archlinux-keyring
echo "Install Docker and Docker Compose"
sudo pacman --noconfirm -S docker docker-compose
echo "Enabling Docker Service"
sudo systemctl enable --now docker
sudo systemctl status docker

echo "Installing Nvidia Container Toolkit and Drivers"
sudo pacman --noconfirm -S nvidia nvidia-container-toolkit nvidia-cg-toolkit opencl-nvidia nvtop
echo "Updating Docker"
sudo systemctl stop docker
sudo systemctl status docker
sudo nvidia-ctk runtime configure --runtime=docker
sudo systemctl start docker

echo "Executing Test Docker"
sudo docker run --rm --runtime=nvidia --gpus all ubuntu nvidia-smi
