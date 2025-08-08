#!/bin/bash
model_id=$1
port=${2:-8000}
name=${3:-vllm_server}
tag=gptoss

docker run --rm -d --runtime nvidia --gpus all --platform linux/amd64 \
    -v $HOME/.cache/:/root/.cache/ \
    --env "HUGGING_FACE_HUB_TOKEN=$HF_TOKEN" \
    --shm-size 5g --ulimit memlock=-1 --ulimit stack=67108864  --ipc=host --privileged --network=host  --ipc=host --name ${name}_${model_id//\//_} \
    vllm/vllm-openai:$tag --model $model_id --port $port \
    --trust-remote-code --max-num-batched-tokens 16000 \
    --gpu-memory-utilization 0.95 \
    --max-model-len 32000 