docker run -it --runtime nvidia --gpus all --platform linux/amd64 \
    -v /data/.cache/:/root/.cache/ \
    --env "HUGGING_FACE_HUB_TOKEN=$HF_TOKEN" -p 26666:26666 \
    -w /app -v $(pwd):/app \
    --ipc=host --shm-size=5g --name tensorrt_llm --entrypoint bash nvcr.io/nvidia/tensorrt-llm/release:1.0.0rc3