#!/bin/bash


trtllm-serve nvidia/DeepSeek-R1-FP4 \
    --host 0.0.0.0 --port 26666 --backend pytorch \
    --tp_size 8 --ep_size 2 \
    --trust_remote_code \
    --kv_cache_free_gpu_memory_fraction 0.7 --extra_llm_api_options ./tuning/tensorrt_llm/deepseek-r1/mtp/trt_bench_mtp.yaml