#!/bin/bash
echo "SERVER PORT: $SERVER_PORT"
name=${2:-vllm_server}
tag=${3:-latest}
gpu=0.2

docker run --rm -d --runtime nvidia --gpus all --platform linux/amd64 \
    -v /localfs/.cache/huggingface:/root/.cache/huggingface \
    --env "HUGGING_FACE_HUB_TOKEN=$HF_TOKEN" \
    --shm-size 5g --ulimit memlock=-1 --ulimit stack=67108864  --ipc=host --privileged --network=host  --ipc=host --name $name \
    vllm/vllm-openai:$tag --model $1 --port $SERVER_PORT \
    --trust-remote-code --max-num-batched-tokens 16000 \
    --max-model-len 64000 --gpu-memory-utilization $gpu $4