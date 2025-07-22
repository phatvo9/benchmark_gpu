#!/bin/bash

docker run -it --runtime nvidia --gpus all --platform linux/amd64 \
    -v /data/.cache/huggingface:/root/.cache/huggingface \
    --env "HUGGING_FACE_HUB_TOKEN=$HF_TOKEN" -p 24444:24444 \
    -w /app -v $(pwd):/app \
    --ipc=host --shm-size=1g --name local_runner_vllm --entrypoint bash vllm/vllm-openai:latest
