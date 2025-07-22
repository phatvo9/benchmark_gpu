#!/bin/bash

# Build LLaMA v3 70B using 4-way tensor parallelism

converted_checkpoint_output_dir=~/.cache/tensorrt/checkpoints/llama3_3_70b
tensorrt_output_dir=~/.cache/tensorrt/built/llama3_3_70b

python tuning/tensorrt_llm/llama3_3/convert_checkpoints.py --model_dir ~/.cache/huggingface/hub/models--unsloth--Llama-3.3-70B-Instruct/snapshots/9bac09282bdfd3c874100575c15e21d987c41e0c/ \
                            --output_dir $converted_checkpoint_output_dir \
                            --dtype float16 \
                            --tp_size 4 \

trtllm-build --checkpoint_dir $converted_checkpoint_output_dir \
            --output_dir $tensorrt_output_dir \
            --gemm_plugin auto --use_paged_context_fmha enable \
            --workers 8 