#!/bin/bash
echo "SERVER PORT: $SERVER_PORT"
name=${2:-sglang_server}
tag=${3:-latest}

cmd="docker run -d --rm --runtime nvidia --gpus all --platform linux/amd64 \
    -v $HOME/.cache/huggingface:/root/.cache/huggingface \
    --env "HUGGING_FACE_HUB_TOKEN=$HF_TOKEN" \
    --ipc=host --shm-size=32g --name $name -p $SERVER_PORT:$SERVER_PORT \
    lmsysorg/sglang:$tag python3 -m sglang.launch_server --model-path $1 --port $SERVER_PORT --host 0.0.0.0 \
    --trust-remote-code --mem-fraction-static 0.9 --chunked-prefill-size 8192 --max-running-requests 128 $4"
echo $cmd
$cmd