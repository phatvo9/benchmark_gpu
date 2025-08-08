model_id=${1:-"openai/gpt-oss-120b"}
port=${2:-8000}
name=${3:-sglang_server}
tag=dev

docker run --rm --gpus all \
    -v $HOME/.cache/:/root/.cache/ \
    --env "HUGGING_FACE_HUB_TOKEN=$HF_TOKEN" \
    --shm-size 5g --ulimit memlock=-1 --ulimit stack=67108864  --ipc=host --privileged --network=host  --ipc=host --name ${name}_${model_id//\//_} \
    lmsysorg/sglang:$tag python3 -m sglang.launch_server \
    --model-path $model_id \
    --tp-size 8 --mem-fraction-static 0.8 \
    --port $port --host 0.0.0.0
