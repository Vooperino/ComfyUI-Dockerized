FROM pytorch/pytorch:2.4.0-cuda12.4-cudnn9-runtime

ENV DEBIAN_FRONTEND=noninteractive
ENV PIP_PREFER_BINARY=1
ENV ROOT=/comfyui
ENV CUDA_HOME=/opt/conda
ENV NVIDIA_VISIBLE_DEVICES=all 
ENV PYTHONPATH="${PYTHONPATH}:${PWD}" 
ENV CLI_ARGS=""
ENV PIP_ROOT_USER_ACTION=ignore

USER root

COPY /install /install
COPY /docker /docker
COPY /extra-scripts /extra-scripts

RUN chmod -R u+x /install /docker
RUN bash /install/install_base.sh

WORKDIR ${ROOT}

RUN --mount=type=cache,target=/root/.cache/pip \
  pip install opencv-python mmdet mmengine && \
  pip install -U openmim && \
  mim install mmcv insightface onnxruntime-gpu

RUN conda install -c nvidia cuda --no-update-deps -y

RUN rm -rf /install /temp_libs

HEALTHCHECK --interval=5m --timeout=15s --start-period=1m --retries=3 \
  CMD bash /docker/scripts/docker-health.sh || exit 1

ENTRYPOINT ["/docker/entrypoint.sh"]