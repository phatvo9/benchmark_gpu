#!/bin/bash
model_id=$1

#tasks=$2
tasks="humaneval"

lm_eval --model local-completions \
--tasks $tasks --confirm_run_unsafe_code \
--model_args model=$1,base_url=http://localhost:24444/v1/completions,num_concurrent=4,max_retries=1,tokenized_requests=False --gen_kwargs temperature=0,max_tokens=4096