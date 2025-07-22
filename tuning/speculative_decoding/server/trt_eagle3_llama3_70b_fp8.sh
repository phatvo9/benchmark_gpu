trtllm-serve RedHatAI/Llama-3.3-70B-Instruct-FP8-dynamic \
    --host 0.0.0.0 --port 26666 \
    --backend pytorch --tp_size 4 \
    --trust_remote_code \
    --kv_cache_free_gpu_memory_fraction 0.8 --extra_llm_api_options ./tuning/speculative_decoding/server/trt_llama3_70b_cfg_eagle3_fp8.yaml