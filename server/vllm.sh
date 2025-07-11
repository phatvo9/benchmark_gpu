#!/bin/bash

docker run -d --runtime nvidia --gpus all --platform linux/amd64 \
    -v ~/.cache/huggingface:/root/.cache/huggingface \
    --env "HUGGING_FACE_HUB_TOKEN=$HF_TOKEN" \
    -p 23333:23333 \
    --ipc=host --shm-size=1g --name $2 \
    vllm/vllm-openai:$3 --model $1 --port 23333 \
    --trust-remote-code --max-num-batched-tokens 8192 \
    --max-model-len 16000 --gpu-memory-utilization 0.9 $4