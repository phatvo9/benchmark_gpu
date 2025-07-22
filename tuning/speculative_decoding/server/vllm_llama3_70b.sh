docker run --rm --runtime nvidia --gpus all --platform linux/amd64 \
    -v /data/.cache/huggingface:/root/.cache/huggingface \
    --env "HUGGING_FACE_HUB_TOKEN=$HF_TOKEN" -p 24444:24444 \
    -w /app -v $(pwd):/app \
    --ipc=host --shm-size=8g vllm/vllm-openai:latest --model unsloth/Llama-3.3-70B-Instruct \
    --port 24444 --seed 42 \
    --trust-remote-code --gpu-memory-utilization 0.9 --tensor-parallel-size 4  