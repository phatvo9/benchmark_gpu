#!/bin/bash
port=$2
gpu=${3:-"0.2"}
name=${4:-vllm_server}
tag=${5:-latest}

model_id=$1
docker run --rm -d --runtime nvidia --gpus all --platform linux/amd64 \
    -v /localfs/.cache/huggingface:/root/.cache/huggingface \
    --env "HUGGING_FACE_HUB_TOKEN=$HF_TOKEN" \
    --shm-size 5g --ulimit memlock=-1 --ulimit stack=67108864  --ipc=host --privileged --network=host  --ipc=host --name ${name}_${model_id//\//_}_${gpu} \
    vllm/vllm-openai:$tag --model $model_id --port $port \
    --trust-remote-code --max-num-batched-tokens 16000 \
    --max-model-len 32000 --gpu-memory-utilization $gpu