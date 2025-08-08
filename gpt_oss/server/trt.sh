#!/bin/bash

# Usage: ./run_tensorrt_llm.sh <model_name> [additional_trtllm_flags]
# Example:
# ./run_tensorrt_llm.sh openai/gpt-oss-120b --host 0.0.0.0 --port 8000 --backend pytorch --tp_size 1 --ep_size 1

MODEL_NAME="$1"
shift  # shift to access additional flags
TRTLLM_FLAGS="$@"

if [[ -z "$MODEL_NAME" ]]; then
  echo "Usage: $0 <model_name> [additional_trtllm_flags]"
  exit 1
fi

docker run --rm --ipc=host -it \
  --ulimit stack=67108864 \
  --ulimit memlock=-1 \
  --gpus all \
  -p 8000:8000 \
  -e TRTLLM_ENABLE_PDL=1 \
  -e TRT_LLM_DISABLE_LOAD_WEIGHTS_IN_PARALLEL=True \
  -v ~/.cache:/root/.cache:rw \
  nvcr.io/nvidia/tensorrt-llm/release:gpt-oss-dev \
  bash -c "trtllm-serve ${MODEL_NAME} ${TRTLLM_FLAGS}"
