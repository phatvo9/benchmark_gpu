docker run -it --rm --gpus all \
    --env "HUGGING_FACE_HUB_TOKEN=$HF_TOKEN" -p 26666:26666 \
    -w /app -v $(pwd):/app \
    -v $HOME/.cache/:/root/.cache/ \
    --privileged  --shm-size 5g --ulimit memlock=-1 --ulimit stack=67108864  --ipc=host --network=host \
    --shm-size=5g --entrypoint bash nvcr.io/nvidia/tensorrt-llm/release:gpt-oss-dev