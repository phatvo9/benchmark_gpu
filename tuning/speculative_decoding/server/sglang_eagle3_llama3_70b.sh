docker run --rm --runtime nvidia --gpus all --platform linux/amd64 \
    -v /data/.cache/huggingface:/root/.cache/huggingface \
    --env "HUGGING_FACE_HUB_TOKEN=$HF_TOKEN" -p 24444:24444 \
    -w /app -v $(pwd):/app \
    --ipc=host --shm-size=8g \
    lmsysorg/sglang:latest python3 -m sglang.launch_server --model-path $1 --port 24444 \
