model_id=$1
port=${2:-"23330"}
gpu=${3:-"0.2"}

export HUGGING_FACE_HUB_TOKEN=$HF_TOKEN
export HF_HOME=/localfs/.cache/huggingface

python3 -m vllm.entrypoints.openai.api_server \
  --model $model_id \
  --port $port \
  --trust-remote-code \
  --max-num-batched-tokens 16000 \
  --max-model-len 32000 \
  --gpu-memory-utilization $gpu