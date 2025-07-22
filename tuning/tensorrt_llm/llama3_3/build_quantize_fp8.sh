#!/bin/bash

model_checkpoint=~/.cache/huggingface/hub/models--unsloth--Llama-3.3-70B-Instruct/snapshots/9bac09282bdfd3c874100575c15e21d987c41e0c/
converted_checkpoint_output_dir=~/.cache/tensorrt/checkpoints/llama3_3_70b_fp8
tensorrt_output_dir=~/.cache/tensorrt/built/llama3_3_70b_fp8


# python ./tuning/tensorrt_llm/quantize.py --model_dir $model_checkpoint \
#                                    --dtype float16 \
#                                    --qformat fp8 \
#                                    --kv_cache_dtype fp8 \
#                                    --output_dir $converted_checkpoint_output_dir \
#                                    --calib_size 512 --tp_size 4


trtllm-build --checkpoint_dir $converted_checkpoint_output_dir \
            --output_dir $tensorrt_output_dir \
            --gemm_plugin auto --use_paged_context_fmha enable \
            --workers 8                                   