trtllm-bench --model nvidia/DeepSeek-R1-FP4   -w tuning/tensorrt_llm/deepseek-r1/mtp  \
throughput     \
--dataset dataset.txt     --backend pytorch     \
--num_requests 30 --concurrency 1 \
--max_batch_size 1 --tp 8 --ep 2  \
--extra_llm_api_options ./tuning/tensorrt_llm/deepseek-r1/mtp/trt_bench_mtp.yaml

