# Start server

set args for both server and runner:
```bash
export SERVER_PORT=23333
export VLLM_MODEL=<model id>
```

Start server
```bash
./server/{vllm,sglang}.sh $VLLM_MODEL
```

# Start runner after the server is up

Installation
```
pip install clarifai openai
```

```bash
clarifai model local-runner
```