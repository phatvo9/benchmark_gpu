
trtllm-bench  --model nvidia/DeepSeek-R1-0528-FP4 \
     throughput \
     --dataset ./tmp/dataset.txt \
     --backend pytorch \
     --tp 8  --ep 2 \
     --extra_llm_api_options ./tuning/tensorrt_llm/deepseek-r1/cuda_graph/config.yaml \
     --kv_cache_free_gpu_mem_fraction 0.7 \
     --max_num_tokens 2048 \
     --max_batch_size 896 \
     --concurrency 2048 \
     --num_requests 4096
    #  --concurrency 8 \
    #  --max_batch_size 16 \
    #  --num_requests 32