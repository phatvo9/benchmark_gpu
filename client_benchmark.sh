#!/bin/bash

export OPENAI_API_KEY=notset
export OPENAI_API_BASE="http://localhost:23333/v1"

MAX_REQUEST=10

echo "======== Benchmark with prod setting ========="

echo "1. 1 con request"
python external/llmperf/token_benchmark_ray.py \
--model $1 \
--mean-input-tokens 500 \
--stddev-input-tokens 0 \
--mean-output-tokens 150 \
--stddev-output-tokens 0 \
--max-num-completed-requests $MAX_REQUEST \
--timeout 600 \
--num-concurrent-requests 1 \
--results-dir ${2}/i500_o150_c1 \
--llm-api openai \
--additional-sampling-params '{}'
echo "--------------------------------------------------"
echo "2. 16 con request"
python external/llmperf/token_benchmark_ray.py \
--model $1 \
--mean-input-tokens 500 \
--stddev-input-tokens 0 \
--mean-output-tokens 150 \
--stddev-output-tokens 0 \
--max-num-completed-requests $MAX_REQUEST \
--timeout 600 \
--num-concurrent-requests 16 \
--results-dir ${2}/i500_o150_c16 \
--llm-api openai \
--additional-sampling-params '{}'
echo "--------------------------------------------------"
echo "3. 32 con request"
python external/llmperf/token_benchmark_ray.py \
--model $1 \
--mean-input-tokens 500 \
--stddev-input-tokens 0 \
--mean-output-tokens 150 \
--stddev-output-tokens 0 \
--max-num-completed-requests $MAX_REQUEST \
--timeout 600 \
--num-concurrent-requests 32 \
--results-dir ${2}/i500_o150_c32 \
--llm-api openai \
--additional-sampling-params '{}'

######################
echo "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
echo "======== Benchmark with AA setting ========="

echo "1.1. 1000 Input tokens, 1000 Output tokens, 1 con request"
python external/llmperf/token_benchmark_ray.py \
--model $1 \
--mean-input-tokens 1000 \
--stddev-input-tokens 0 \
--mean-output-tokens 1000 \
--stddev-output-tokens 0 \
--max-num-completed-requests $MAX_REQUEST \
--timeout 600 \
--num-concurrent-requests 1 \
--results-dir ${2}/i1000_o1000_c1 \
--llm-api openai \
--additional-sampling-params '{}'

echo "--------------------------------------------------"
echo "1.2. 1000 Input tokens, 1000 Output tokens, 10 con request"
python external/llmperf/token_benchmark_ray.py \
--model $1 \
--mean-input-tokens 1000 \
--stddev-input-tokens 0 \
--mean-output-tokens 1000 \
--stddev-output-tokens 0 \
--max-num-completed-requests $MAX_REQUEST \
--timeout 600 \
--num-concurrent-requests 10 \
--results-dir ${2}/i1000_o1000_c10 \
--llm-api openai \
--additional-sampling-params '{}'

echo "--------------------------------------------------"
echo "2.1. 100 Input tokens, 300 Output tokens, 1 con request"
python external/llmperf/token_benchmark_ray.py \
--model $1 \
--mean-input-tokens 100 \
--stddev-input-tokens 0 \
--mean-output-tokens 300 \
--stddev-output-tokens 0 \
--max-num-completed-requests $MAX_REQUEST \
--timeout 600 \
--num-concurrent-requests 1 \
--results-dir ${2}/i100_o300_c1  \
--llm-api openai \
--additional-sampling-params '{}'

echo "--------------------------------------------------"
echo "2.2. 100 Input tokens, 300 Output tokens, 10 con request"
python external/llmperf/token_benchmark_ray.py \
--model $1 \
--mean-input-tokens 100 \
--stddev-input-tokens 0 \
--mean-output-tokens 300 \
--stddev-output-tokens 0 \
--max-num-completed-requests $MAX_REQUEST \
--timeout 600 \
--num-concurrent-requests 10 \
--results-dir ${2}/i100_o300_c10  \
--llm-api openai \
--additional-sampling-params '{}'

echo "--------------------------------------------------"
echo "3.1. 10000 Input tokens, 1500 Output tokens, 1 con request"
python external/llmperf/token_benchmark_ray.py \
--model $1 \
--mean-input-tokens 10000 \
--stddev-input-tokens 0 \
--mean-output-tokens 1500 \
--stddev-output-tokens 0 \
--max-num-completed-requests $MAX_REQUEST \
--timeout 600 \
--num-concurrent-requests 1 \
--results-dir ${2}/i10000_o1500_c1  \
--llm-api openai \
--additional-sampling-params '{}'

echo "--------------------------------------------------"
echo "3.2. 10000 Input tokens, 1500 Output tokens, 10 con request"
python external/llmperf/token_benchmark_ray.py \
--model $1 \
--mean-input-tokens 10000 \
--stddev-input-tokens 0 \
--mean-output-tokens 1500 \
--stddev-output-tokens 0 \
--max-num-completed-requests $MAX_REQUEST \
--timeout 600 \
--num-concurrent-requests 10 \
--results-dir ${2}/i10000_o1500_c10  \
--llm-api openai \
--additional-sampling-params '{}'