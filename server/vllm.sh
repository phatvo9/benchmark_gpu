#!/bin/bash
echo "SERVER PORT: $SERVER_PORT"
name=${2:-sglang_server}
tag=${3:-latest}

docker run -d --runtime nvidia --gpus all --platform linux/amd64 \
    -v ~/.cache/huggingface:/root/.cache/huggingface \
    --env "HUGGING_FACE_HUB_TOKEN=$HF_TOKEN" \
    -p $SERVER_PORT:$SERVER_PORT \
    --ipc=host --shm-size=1g --name $name \
    vllm/vllm-openai:$tag --model $1 --port $SERVER_PORT \
    --trust-remote-code --max-num-batched-tokens 8192 \
    --max-model-len 16000 --gpu-memory-utilization 0.9 $4