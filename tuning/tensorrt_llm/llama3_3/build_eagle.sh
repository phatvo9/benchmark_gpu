#!/bin/bash

model_checkpoint=~/.cache/huggingface/hub/models--unsloth--Llama-3.3-70B-Instruct/snapshots/9bac09282bdfd3c874100575c15e21d987c41e0c/
eagle_model_chkpt=~/.cache/huggingface/hub/models--yuhuili--EAGLE3-LLaMA3.3-Instruct-70B/snapshots/7694341d51d7079231b04028cf6824973fe7044a/
converted_checkpoint_output_dir=~/.cache/tensorrt/checkpoints/llama3_3_70b_eagle3
tensorrt_output_dir=~/.cache/tensorrt/built/llama3_3_70b_eagle3



python3 tuning/tensorrt_llm/eagle.py --model_dir ${model_checkpoint} \
                                --eagle_model_dir ${eagle_model_chkpt} \
                                --output_dir ${converted_checkpoint_output_dir} \
                                --dtype float16 \
                                --max_draft_len 63 \
                                --num_eagle_layers 4 \
                                --max_non_leaves_per_layer 10 --tp_size 4

trtllm-build --checkpoint_dir ${converted_checkpoint_output_dir} \
            --output_dir ${tensorrt_output_dir} \
            --gemm_plugin auto --workers 8 \
            --use_paged_context_fmha enable \
            --speculative_decoding_mode eagle 
