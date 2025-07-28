#!/bin/bash

model_id=$1
result_dir=$2
model_type=generate

MODEL_BENCHMARK_DIR="external/model_benchmark"
NUM_REQUEST=100

PORT=$3
BASE="http://localhost:$PORT/v1"
echo "Benchmark with base url $BASE"
export OPENAI_API_BASE=$BASE 
export OPENAI_API_KEY="hello"
#export MAKE_REQUEST=2

if [[ "$with_image" == "image" ]]; then
   image_args="--image-sizes 256 1024"
else
   image_args=""
fi

provider=openai
formatted_model_id=$(echo "$model_id" | tr '/' '.' | tr '[:upper:]' '[:lower:]')

echo "Model name: $model_id"
echo "============= Benchmark prod ============="
CMD="python ${MODEL_BENCHMARK_DIR}/run_testloading.py \
--provider $provider --model-type $model_type \
--result-dir ${result_dir}_legacy \
--model-kwargs model=$model_id \
--batch-sizes 1 --num-con-reqs 1 2 8 16 32 64 100 128 \
--input-toks 500 --output-toks 150 \
--test-cold-start $image_args --time-out-s 100000 --num-reqs $NUM_REQUEST \
--infer-kwargs max_tokens=150,temperature=0.7,top_p=0.9"
echo "===="
echo "Executing: \n $CMD\n"
echo "===="
$CMD

echo "============= Benchmark AA ============="


# CMD="python ${MODEL_BENCHMARK_DIR}/run_testloading.py \
# --provider $provider --model-type $model_type \
# --result-dir $result_dir \
# --model-kwargs model=$model_id \
# --batch-sizes 1 --num-con-reqs 1 10 \
# --input-toks 100 --output-toks 300 \
# --test-cold-start $image_args --time-out-s 10000 --num-reqs $NUM_REQUEST \
# --infer-kwargs max_tokens=300,temperature=0.7,top_p=0.9"
# echo "===="
# echo "Executing: \n $CMD\n"
# echo "===="
# $CMD


# CMD="python ${MODEL_BENCHMARK_DIR}/run_testloading.py \
# --provider $provider --model-type $model_type \
# --result-dir $result_dir \
# --model-kwargs model=$model_id \
# --batch-sizes 1 --num-con-reqs 1 10 \
# --input-toks 1000 --output-toks 1000 \
# --test-cold-start $image_args --time-out-s 10000 --num-reqs $NUM_REQUEST \
# --infer-kwargs max_tokens=1000,temperature=0.7,top_p=0.9"
# echo "===="
# echo "Executing: \n $CMD\n"
# echo "===="
# $CMD


# CMD="python ${MODEL_BENCHMARK_DIR}/run_testloading.py \
# --provider $provider --model-type $model_type \
# --result-dir $result_dir \
# --model-kwargs model=$model_id \
# --batch-sizes 1 --num-con-reqs 1 10 \
# --input-toks 10000 --output-toks 1500 \
# --test-cold-start $image_args --time-out-s 10000 --num-reqs $NUM_REQUEST \
# --infer-kwargs max_tokens=1500,temperature=0.7,top_p=0.9"
# echo "===="
# echo "Executing: \n $CMD\n"
# echo "===="
# $CMD
