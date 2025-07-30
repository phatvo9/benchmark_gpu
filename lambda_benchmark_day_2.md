## Start server

make sure tmp/server folder exists

```
mkdir tmp
mkdir tmp/server
```

```
nohup bash -c "python3 -m vllm.entrypoints.openai.api_server \
  --model Qwen/Qwen3-8B \
  --port 23330 \
  --trust-remote-code \
  --max-num-batched-tokens 16000 \
  --max-model-len 32000 \
  --gpu-memory-utilization 0.95" > tmp/server/1.log &
```

## Set up benchmark code:

```
git clone https://github.com/phatvo9/benchmark_gpu.git
cd benchmark_gpu
pip install gdown
python3 download_repos.py https://drive.google.com/file/d/1BpTsi6oj1tni3CM5EAtZDdgOIyfTrP5U/view?usp=drive_link
pip install -r external/model_benchmark/requirements.txt

sudo ln -s $(which python3) /usr/local/bin/python
mkdir -p tmp/logs/multimodels/
```

## Run benchmark (you may want to wait for other servers up)

`tuning/multimodels/lambda_benchmark/lambda_benchmark.sh`
   
view logs at `tmp/logs/multimodels/`