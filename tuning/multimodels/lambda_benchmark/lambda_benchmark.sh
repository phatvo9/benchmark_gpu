result_dir=./tmp/benchmark/multimodels

model_id=Qwen/Qwen3-8B
model_name=${model_id//\//_}
port=23330
idx=3
echo "Start ${model_id}, Index $idx, Port: $port"
nohup bash -c "./clarifai_gpu_benchmark.sh $model_id ${result_dir}/$model_name/$idx $port" > tmp/logs/multimodels/${model_name}_${idx}.log &
echo "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"