import os
import sys

from typing import List, Iterator

from clarifai.runners.models.openai_class import OpenAIModelClass
from openai import OpenAI
from clarifai.runners.utils.openai_convertor import build_openai_messages
from clarifai.runners.utils.data_utils import Param
from clarifai.utils.logging import logger

PYTHON_EXEC = sys.executable

def vllm_openai_server(checkpoints, **kwargs):
    """Start vLLM OpenAI compatible server."""
    
    from clarifai.runners.utils.model_utils import execute_shell_command, wait_for_server, terminate_process
    # Start building the command
    cmds = [
        PYTHON_EXEC, '-m', 'vllm.entrypoints.openai.api_server', '--model', checkpoints,
    ]
    # Add all parameters from kwargs to the command
    for key, value in kwargs.items():
        if value is None:  # Skip None values
            continue
        param_name = key.replace('_', '-')
        if isinstance(value, bool):
            if value:  # Only add the flag if True
                cmds.append(f'--{param_name}')
        else:
            cmds.extend([f'--{param_name}', str(value)])
    # Create server instance
    server = type('Server', (), {
        'host': kwargs.get('host', '0.0.0.0'),
        'port': kwargs.get('port', 23333),
        'backend': "vllm",
        'process': None
    })()
    
    try:
        server.process = execute_shell_command(" ".join(cmds))
        logger.info("Waiting for " + f"http://{server.host}:{server.port}")
        wait_for_server(f"http://{server.host}:{server.port}")
        logger.info("Server started successfully at " + f"http://{server.host}:{server.port}")
    except Exception as e:
        logger.error(f"Failed to start vllm server: {str(e)}")
        if server.process:
            terminate_process(server.process)
        raise RuntimeError(f"Failed to start vllm server: {str(e)}")

    return server

class VLLMLlamaModel(OpenAIModelClass):
  """
  A Model that integrates with the Clarifai platform and uses vLLM framework for inference to run the Llama 3.1 8B model with tool calling capabilities.
  """
  client = True  # This will be set in load_model method
  model = True  # This will be set in load_model method

  def load_model(self):
    """Load the model here and start the  server."""
    os.path.join(os.path.dirname(__file__))

    server_args = {
        'max_model_len': 16000,
        'gpu_memory_utilization': 0.9,
        'max-num-batched-tokens': 8192,
        'tensor_parallel_size': 1,
        'port': os.environ.get("SERVER_PORT", 23333),
        'host': 'localhost',
    }

    checkpoints = os.environ["VLLM_MODEL"]

    # Start server
    self.server = vllm_openai_server(checkpoints, **server_args)
    # CLIent initialization
    self.client = OpenAI(
            api_key="notset",
            base_url=f'http://{self.server.host}:{self.server.port}/v1')
    self.model = self.client.models.list().data[0].id

  @OpenAIModelClass.method
  def predict(self,
              prompt: str,
              chat_history: List[dict] = None,
              tools: List[dict] = None,
              tool_choice: str = None,
              max_tokens: int = Param(default=512, description="The maximum number of tokens to generate. Shorter token lengths will provide faster performance.", ),
              temperature: float = Param(default=0.7, description="A decimal number that determines the degree of randomness in the response", ),
              top_p: float = Param(default=0.95, description="An alternative to sampling with temperature, where the model considers the results of the tokens with top_p probability mass."), 
              ) -> str:
    """
    This method is used to predict the response for the given prompt and chat history using the model and tools.
    """
    if tools is not None and tool_choice is None:
        tool_choice = "auto"
            
    messages = build_openai_messages(prompt=prompt, messages=chat_history)
    response = self.client.chat.completions.create(
        model=self.model,
        messages=messages,
        #tools=tools,
        #tool_choice=tool_choice,
        max_completion_tokens=max_tokens,
        temperature=temperature,
        top_p=top_p)
      
    if response.choices[0] and response.choices[0].message.tool_calls:
      import json
      # If the response contains tool calls, return as a string

      tool_calls = response.choices[0].message.tool_calls
      tool_calls_json = json.dumps([tc.to_dict() for tc in tool_calls], indent=2)
      return tool_calls_json
    else:
      # Otherwise, return the content of the first choice
      return response.choices[0].message.content
    

  @OpenAIModelClass.method
  def generate(self,
               prompt: str,
               chat_history: List[dict] = None,
               tools: List[dict] = None,
               tool_choice: str = None,
               max_tokens: int = Param(default=512, description="The maximum number of tokens to generate. Shorter token lengths will provide faster performance.", ),
               temperature: float = Param(default=0.7, description="A decimal number that determines the degree of randomness in the response", ),
               top_p: float = Param(default=0.95, description="An alternative to sampling with temperature, where the model considers the results of the tokens with top_p probability mass.")) -> Iterator[str]:
    """
    This method is used to stream generated text tokens from a prompt + optional chat history and tools.
    """
    messages = build_openai_messages(prompt=prompt, messages=chat_history)
    response = self.client.chat.completions.create(
        model=self.model,
        messages=messages,
        #tools=tools,
        #tool_choice=tool_choice,
        max_completion_tokens=max_tokens,
        temperature=temperature,
        top_p=top_p,
        stream=True)
    
    for chunk in response:
      if chunk.choices:
        if chunk.choices[0].delta.tool_calls:
          # If the response contains tool calls, return the first one as a string
          import json
          tool_calls = chunk.choices[0].delta.tool_calls
          tool_calls_json = [tc.to_dict() for tc in tool_calls]
          # Convert to JSON string
          json_string = json.dumps(tool_calls_json, indent=2)
          # Yield the JSON string
          yield json_string
        else:
          # Otherwise, return the content of the first choice
          text = (chunk.choices[0].delta.content
                  if (chunk and chunk.choices[0].delta.content) is not None else '')
          yield text