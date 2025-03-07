# ComfyUI Dockerized
Run ComfyUI on `your machine`/`your AI box`/`your server` with a nice UI without any hassle and in isolated environment!

> [!WARNING]  
> Only NVIDIA cards supported at this moment since I don't have `AMD` and `Intel ARC` card to test it on

# Setup | Installing | Build Container

When building the image have be sure that you dont have an existing one already, but however you can always rebuild it via `docker-compose` command

When building you can use either docker-compose or docker to build it
```bash
# Docker Compose
docker-compose build --no-cache --pull

# After build run to save up the space (Optional)
docker builder prune -a -f
```

# Minimum Specifications Required 

You will need atleast around `32GB` RAM (DDR4 and UP) RAM for this to run, but depended what modules you will run on it. 
GPU is must required for this as of now this build will only support Nvidia GPUs looks for a GPU that is powerful enought to run Flux or Stable Diffusion Modules on it, suggestion is to use `RTX 3060` or `RTX 2060` as the minimum.

# WSL

> [!WARNING]  
> Running this container under WSL is EXPERIMENTAL.
> USE IT HIGH CAUTION

> [!IMPORTANT]
> This container should work longest if you able to pass GPU to WSL and get Docker working on your WSL

| WSL Distro    | Supported | Note |
| :-------- | :------- | :------- | 
| `Ubuntu` | Supported | Ubuntu from MS Store|
| `Arch Linux` | Supported | Arch from [MS Store](https://www.microsoft.com/store/productId/9MZNMNKSM73X?ocid=pdpshare) [Vineel Sai - Arch WSL](https://github.com/VSWSL/Arch-WSL)|
| `Debian` | Not Tested | |
| `OracleLinux` | Not Tested | |

## Ubuntu WSL (Current tested on)

If you have a fresh install of WSL Ubuntu, make sure you have docker and nvidia container runtime installed. The install scripts can be found in the '/wsl/ubuntu' directory in this repository.

Using `install-docker.sh` will install the docker on the WSL instance so you dont need to install docker for windows since it may cause issues with the windows install

# Environment variables

| Variables    | Required | Default Value | Explanation |
| :-------- | :-------: | :-------: |  :------- |
| `WEB_PORT` | No | `7860` | ComfyUI Web UI Port |
| `DL_CUI_MANAGER` | No | `false` | Force check for ComfyUI-Manager is installed |
| `CNODE_GIT_CHECK_LATEST` | No | `false` | Check all of the Custom Nodes for latest commit |
| `DEBUG` | No | `false` | Enables extra logging outputs |

# Libs Used

* ComfyUI - https://github.com/comfyanonymous/ComfyUI

# Contributing
Contributions are welcome! **Create a discussion first of what the problem is and what you want to contribute (before you implement anything)**

# Disclaimer
The authors of this project are not responsible for any content generated using ComfyUI.