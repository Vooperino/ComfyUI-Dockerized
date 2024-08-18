# ComfyUI Dockerized
Run ComfyUI on `your machine`/`your AI box`/`your server` with a nice UI without any hassle and in isolated environment!

# Setup | Installing | Build Container

When building the image have be sure that you dont have an existing one already, but however you can always rebuild it via `docker-compose` command

When building you can use either docker-compose or docker to build it
```bash
# Docker Compose
docker-compose build --no-cache --pull

# After build run to save up the space (Optional)
docker builder prune -a -f
```

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