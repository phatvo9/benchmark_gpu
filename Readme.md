| Model | FP8 |
|-------|-----|
| Qwen/Qwen3-0.6B | ❌ |
| Qwen/Qwen3-4B | ❌ |
| Qwen/Qwen2-7B-Instruct | ❌ |
| Qwen/Qwen-14B | ❌ |
| Qwen/Qwen3-32B | RedHatAI/Qwen3-32B-FP8-dynamic |
| Qwen/Qwen3-30B-A3B | RedHatAI/Qwen3-30B-A3B-FP8-dynamic |
| unsloth/Llama-3.2-3B-Instruct | ❌ |
| unsloth/Llama-3.1-8B-Instruct | RedHatAI/Meta-Llama-3.1-8B-Instruct-FP8 |
| unsloth/gemma-3-4b-it | RedHatAI/gemma-3-4b-it-FP8-dynamic |
| unsloth/gemma-3n-E4B-it | ❌ |
| unsloth/gemma-3-12b-it | ❌ |
| unsloth/gemma-3-27b-it | RedHatAI/gemma-3-27b-it-FP8-dynamic |
| openbmb/MiniCPM3-4B | ❌ |
| openbmb/MiniCPM-o-2_6 | ❌ |
| openbmb/MiniCPM4-8B | ❌ |
| deepseek-ai/DeepSeek-R1-0528-Qwen3-8B | ❌ |
| microsoft/Phi-4-reasoning-plus | ❌ |
| baidu/ERNIE-4.5-21B-A3B-PT | ❌ |

# Installation

1. Git clone recursive this repository

Or download `model_benchmark.zip`

```bash

pip install -U gdown
python download_repos.py <Google Drive Link>

```

2. Install dependencies of `model_benchmark`

```bash

pip install -r external/model_benchmark/requirements.txt
```



# Install conda

```bash
curl -O https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
bash Miniconda3-latest-Linux-x86_64.sh
/root/miniconda3/bin/conda init

# aarch64
curl -O https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-aarch64.sh
bash Miniconda3-latest-Linux-aarch64.sh
```

# Build Docker Image

## GH200

```
git clone https://github.com/vllm-project/vllm.git
cd vllm
python3 use_existing_torch.py
nohup sh -c 'DOCKER_BUILDKIT=1 docker build . \
  --target vllm-openai \
  --platform "linux/arm64" \
  -t vllm/vllm-gh200-openai:latest \
  --build-arg max_jobs=66 \
  --build-arg nvcc_threads=2 \
  --build-arg torch_cuda_arch_list="9.0+PTX" \
  --build-arg vllm_fa_cmake_gpu_arches="90-real" \
  -f docker/Dockerfile' > build_log.log 2>&1 &
```