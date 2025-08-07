#!/bin/bash

model_id=https://clarifai.com/luv_2261/gpt-oss-local-runner-app/models/gpt-oss-120b
result_dir=tmp/benchmark/gpt-oss-120b_openai/
model_type=generate

MODEL_BENCHMARK_DIR="."
NUM_REQUEST=50

BASE="https://api.clarifai.com/v2/ext/openai/v1"
echo "Benchmark with base url $BASE"
export OPENAI_API_BASE=$BASE 
export OPENAI_API_KEY="luv pat"
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
--result-dir $result_dir \
--model-kwargs model=$model_id \
--batch-sizes 1 --num-con-reqs 1 50 100 \
--input-toks 500 --output-toks 150 \
--test-cold-start $image_args --time-out-s 100000 --num-reqs $NUM_REQUEST --skip-if-done \
--infer-kwargs max_tokens=150"
echo "===="
echo "Executing: \n $CMD\n"
echo "===="
$CMD

# CMD="python ${MODEL_BENCHMARK_DIR}/run_testloading.py \
# --provider $provider --model-type $model_type \
# --result-dir $result_dir \
# --model-kwargs model=$model_id \
# --batch-sizes 1 --num-con-reqs 1 50 100 \
# --input-toks 1000 --output-toks 1000 \
# --test-cold-start $image_args --time-out-s 100000 --num-reqs $NUM_REQUEST --skip-if-done \
# --infer-kwargs max_tokens=1000"
# echo "===="
# echo "Executing: \n $CMD\n"
# echo "===="
# $CMD

# CMD="python ${MODEL_BENCHMARK_DIR}/run_testloading.py \
# --provider $provider --model-type $model_type \
# --result-dir $result_dir \
# --model-kwargs model=$model_id \
# --batch-sizes 1 --num-con-reqs 1 50 100 \
# --input-toks 10000 --output-toks 1500 \
# --test-cold-start $image_args --time-out-s 100000 --num-reqs $NUM_REQUEST --skip-if-done \
# --infer-kwargs max_tokens=1000,temperature=0.7,top_p=0.9"
# echo "===="
# echo "Executing: \n $CMD\n"
# echo "===="
# $CMD

echo "============= Benchmark AA ============="


CMD="python ${MODEL_BENCHMARK_DIR}/run_testloading.py \
--provider $provider --model-type $model_type \
--result-dir $result_dir \
--model-kwargs model=$model_id \
--batch-sizes 1 --num-con-reqs 1 10 \
--input-toks 100 --output-toks 300 \
--test-cold-start $image_args --time-out-s 10000 --num-reqs $NUM_REQUEST --skip-if-done \
--infer-kwargs max_completion_tokens=300"
echo "===="
echo "Executing: \n $CMD\n"
echo "===="
$CMD


CMD="python ${MODEL_BENCHMARK_DIR}/run_testloading.py \
--provider $provider --model-type $model_type \
--result-dir $result_dir \
--model-kwargs model=$model_id \
--batch-sizes 1 --num-con-reqs 1 10 \
--input-toks 1000 --output-toks 1000 \
--test-cold-start $image_args --time-out-s 10000 --num-reqs $NUM_REQUEST --skip-if-done \
--infer-kwargs max_completion_tokens=1000"
echo "===="
echo "Executing: \n $CMD\n"
echo "===="
$CMD


CMD="python ${MODEL_BENCHMARK_DIR}/run_testloading.py \
--provider $provider --model-type $model_type \
--result-dir $result_dir \
--model-kwargs model=$model_id \
--batch-sizes 1 --num-con-reqs 1 10 \
--input-toks 10000 --output-toks 1500 \
--test-cold-start $image_args --time-out-s 10000 --num-reqs $NUM_REQUEST --skip-if-done \
--infer-kwargs max_completion_tokens=1500"
echo "===="
echo "Executing: \n $CMD\n"
echo "===="
$CMD


# CMD="python ${MODEL_BENCHMARK_DIR}/run_testloading.py \
# --provider $provider --model-type $model_type \
# --result-dir $result_dir \
# --model-kwargs model=$model_id \
# --batch-sizes 1 --num-con-reqs 1 10 100 \
# --input-toks 100000 --output-toks 5000 \
# --test-cold-start $image_args --time-out-s 10000 --num-reqs $NUM_REQUEST --skip-if-done \
# --infer-kwargs max_completion_tokens=5000"
# echo "===="
# echo "Executing: \n $CMD\n"
# echo "===="
# $CMD
