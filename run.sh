#!/bin/bash

# Model Benchmark Automation Script
# This script automates the benchmarking process for multiple Hugging Face models

FRAMEWORK=vllm
set +e 

# Args
tag="latest"
BENCHMARK_SCRIPT="./clarifai_gpu_benchmark.sh"
model_path="models/full.txt"
extra_server_args=""
server_port=23333

while [[ $# -gt 0 ]]; do
  key="$1"
  case $key in
    --tag)
      tag="$2"
      shift 2
      ;;
    --script)
      BENCHMARK_SCRIPT="$2"
      shift 2
      ;;
    --fw)
      FRAMEWORK="$2"
      shift 2
      ;;
    --extra-args)
      extra_server_args="$2"
      shift 2
      ;;
    --port)
      server_port="$2"
      shift 2
      ;;
    --model)
      model_path="$2"
      shift 2
      ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
done

export SERVER_PORT=$server_port

# Read models.txt into MODELS array
MODELS=()
while IFS= read -r line; do
  [[ -z "$line" || "$line" =~ ^# ]] && continue
  MODELS+=("$line")
done < $model_path

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"


# Framework configuration
SUPPORTED_FRAMEWORKS=("vllm" "sglang" "lmdeploy")

# Script paths
CONTAINER_NAME="openai_server"
MODEL_CACHE_DIR="${HOME}/.cache/huggingface/hub"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to show usage
show_usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -f, --framework FRAMEWORK    Framework to use (default: vllm)"
    echo "  -h, --help                   Show this help message"
    echo ""
    echo "Supported frameworks: ${SUPPORTED_FRAMEWORKS[*]}"
    echo ""
    echo "Models to be benchmarked:"
    for model in "${MODELS[@]}"; do
        echo "  - $model"
    done
}

# Function to parse command line arguments
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -f|--framework)
                FRAMEWORK="$2"
                shift 2
                ;;
            -h|--help)
                show_usage
                exit 0
                ;;
            *)
                print_error "Unknown option: $1"
                show_usage
                exit 1
                ;;
        esac
    done
    
    # Validate framework
    if [[ ! " ${SUPPORTED_FRAMEWORKS[*]} " =~ " ${FRAMEWORK} " ]]; then
        print_error "Unsupported framework: $FRAMEWORK"
        print_error "Supported frameworks: ${SUPPORTED_FRAMEWORKS[*]}"
        exit 1
    fi
}

# Function to setup framework-specific paths
setup_framework_paths() {
    SERVER_SCRIPT="${SCRIPT_DIR}/server/${FRAMEWORK}.sh"
    RESULTS_DIR="./output/results/${FRAMEWORK}"
    LOG_DIR="./output/logs/${FRAMEWORK}"
    
    print_status "Using framework: $FRAMEWORK"
    print_status "Server script: $SERVER_SCRIPT"
    print_status "Results directory: $RESULTS_DIR"
}

# Function to check if required scripts exist
check_dependencies() {
    print_status "Checking dependencies..."
    
    if [[ ! -f "$SERVER_SCRIPT" ]]; then
        print_error "Server script not found: $SERVER_SCRIPT"
        print_error "Please ensure the server script exists for framework: $FRAMEWORK"
        exit 1
    fi
    
    if [[ ! -f "$BENCHMARK_SCRIPT" ]]; then
        print_error "Benchmark script not found: $BENCHMARK_SCRIPT"
        exit 1
    fi
    
    if ! command -v docker &> /dev/null; then
        print_error "Docker is not installed or not in PATH"
        exit 1
    fi
    
    print_success "All dependencies checked"
}

# Function to setup directories
setup_directories() {
    print_status "Setting up directories..."
    mkdir -p "$RESULTS_DIR"
    mkdir -p "$LOG_DIR"
    mkdir -p "$MODEL_CACHE_DIR"
    
    # Create model-specific result directories
    for model_id in "${MODELS[@]}"; do
        local model_dir="$RESULTS_DIR/${model_id//\//_}"
        mkdir -p "$model_dir"
    done
    
    print_success "Directories created"
}

# Function to cleanup any existing containers
cleanup_containers() {
    print_status "Cleaning up existing containers..."
    
    if docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
        print_warning "Stopping existing container: $CONTAINER_NAME"
        docker stop "$CONTAINER_NAME" 2>/dev/null || true
        docker rm "$CONTAINER_NAME" 2>/dev/null || true
    fi
    
    print_success "Container cleanup completed"
}

# Function to start server with specific model
start_server() {
    local model_id=$1
    local log_file="$LOG_DIR/server_${model_id//\//_}.log"
    
    print_status "Starting $FRAMEWORK server for model: $model_id"
    
    # Make server script executable
    chmod +x "$SERVER_SCRIPT"
    
    # Start server in background with model ID
    export MODEL_ID="$model_id"
    export CONTAINER_NAME="openaiserver_${model_id//\//_}"
    export FRAMEWORK="$FRAMEWORK"
    cmd="${SERVER_SCRIPT} ${model_id} ${CONTAINER_NAME} $tag $extra_server_args"
    echo "Start server with cmd"
    echo $cmd
    output=$($cmd 2>&1)
    exit_code=$?

    if echo "$output" | grep -q "Error response from daemon: Conflict"; then
        echo "Docker conflict detected, removing existing container..."
        docker rm "$CONTAINER_NAME" -f
        echo "Removed conflicting container. Retrying server start..."
        if ! $cmd; then
            print_error "Failed to start $FRAMEWORK server for model: $model_id (after removing conflicting container)"
            return 1
        fi
    elif [ $exit_code -ne 0 ]; then
        print_error "Failed to start $FRAMEWORK server for model: $model_id"
        return 1
    fi

    docker logs -f ${CONTAINER_NAME} > $log_file 2>&1&
    print_status "Waiting for $FRAMEWORK server to be ready..."
    # Start log stream in background
    docker logs -f "$CONTAINER_NAME" 2>&1 | \
    while read -r line; do
      echo "$line"
      if [[ "$line" == *"The server is fired up and ready to roll!"* ]] || [[ "$line" == *"Application startup complete"* ]]; then
        echo "✅ ${FRAMEWORK} server is ready!"
        sleep 3
        ready=1
        pkill -P $$ docker  # kill `docker logs -f`
        break
      fi
    done

    local server_pid=$!
    echo "$server_pid" > "$LOG_DIR/server_pid.tmp"
    
    
    # Check if container is running
    if ! docker ps --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
        print_error "$FRAMEWORK server container failed to start for model: $model_id"
        return 1
    fi
    
    print_success "$FRAMEWORK server started successfully for model: $model_id"
    return 0
}

# Function to run benchmark
run_benchmark() {
    local model_id=$1
    local benchmark_log="$LOG_DIR/benchmark_${model_id//\//_}.log"
    local model_result_dir="$RESULTS_DIR/${model_id//\//_}"
    
    print_status "Running benchmark for model: $model_id with framework: $FRAMEWORK"
    
    # Make benchmark script executable
    chmod +x "$BENCHMARK_SCRIPT"
    
    # Set environment variables for benchmark
    export MODEL_ID="$model_id"
    export FRAMEWORK="$FRAMEWORK"
    export RESULT_DIR="$model_result_dir"
    export CONTAINER_NAME="$CONTAINER_NAME"
    
    # Run benchmark
    cmd="${BENCHMARK_SCRIPT} ${model_id} ${RESULT_DIR} $server_port > ${benchmark_log} 2>&1"
    if $cmd; then
        print_success "Benchmark completed for model: $model_id"
        return 0
    else
        print_error "Benchmark failed for model: $model_id"
        return 1
    fi
}

# Function to stop server and cleanup
stop_server_and_cleanup() {
    local model_id=$1
    
    print_status "Stopping $FRAMEWORK server and cleaning up for model: $model_id"
    
    # Stop Docker container
    if docker ps --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
        print_status "Stopping Docker container: $CONTAINER_NAME"
        docker stop "$CONTAINER_NAME" 2>/dev/null || true
        docker rm "$CONTAINER_NAME" 2>/dev/null || true
    fi
    
    # Kill server process if it's still running
    if [[ -f "$LOG_DIR/server_pid.tmp" ]]; then
        local server_pid=$(cat "$LOG_DIR/server_pid.tmp")
        if kill -0 "$server_pid" 2>/dev/null; then
            print_status "Stopping server process: $server_pid"
            kill "$server_pid" 2>/dev/null || true
        fi
        rm -f "$LOG_DIR/server_pid.tmp"
    fi
    
    # Clean up model checkpoints
    print_status "Cleaning up model checkpoints..."
    if [[ -d "$MODEL_CACHE_DIR" ]]; then
        sudo rm -rf "$MODEL_CACHE_DIR"/*
    fi
    
    # Clean up Docker images (optional - uncomment if you want to remove images)
    # docker image prune -f
    
    print_success "Cleanup completed for model: $model_id"
}

# Function to benchmark a single model
benchmark_model() {
    local model_id=$1
    local start_time=$(date +%s)
    
    print_status "Starting benchmark process for model: $model_id using framework: $FRAMEWORK"
    
    # Start server
    if ! start_server "$model_id"; then
        print_error "Failed to start $FRAMEWORK server for model: $model_id"
        stop_server_and_cleanup "$model_id"
        return 1
    fi
    
    # Run benchmark
    if ! run_benchmark "$model_id"; then
       print_error "Failed to run benchmark for model: $model_id"
       stop_server_and_cleanup "$model_id"
       return 1
    fi
    
    # Stop server and cleanup
    stop_server_and_cleanup "$model_id"
    
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    
    print_success "Completed benchmark for model: $model_id (Duration: ${duration}s)"
    return 0
}

# Function to generate final report
generate_report() {
    local report_file="$RESULTS_DIR/benchmark_summary_${FRAMEWORK}_$(date +%Y%m%d_%H%M%S).md"
    
    print_status "Generating benchmark report..."
    
    echo "# Benchmark Results Summary - $FRAMEWORK" > "$report_file"
    echo "Generated on: $(date)" >> "$report_file"
    echo "Framework: $FRAMEWORK" >> "$report_file"
    echo "" >> "$report_file"
    
    echo "## Models Benchmarked" >> "$report_file"
    for model_id in "${MODELS[@]}"; do
        local model_result_dir="$RESULTS_DIR/${model_id//\//_}"
        if [[ -d "$model_result_dir" ]] && [[ -n "$(ls -A "$model_result_dir" 2>/dev/null)" ]]; then
            echo "- ✅ $model_id" >> "$report_file"
        else
            echo "- ❌ $model_id (Failed)" >> "$report_file"
        fi
    done
    
    echo "" >> "$report_file"
    echo "## Directory Structure" >> "$report_file"
    echo "- Results: \`$RESULTS_DIR/\`" >> "$report_file"
    echo "- Logs: \`$LOG_DIR/\`" >> "$report_file"
    echo "" >> "$report_file"
    echo "## Model Results" >> "$report_file"
    for model_id in "${MODELS[@]}"; do
        local model_result_dir="$RESULTS_DIR/${model_id//\//_}"
        echo "- $model_id: \`$model_result_dir/\`" >> "$report_file"
    done
    
    print_success "Report generated: $report_file"
}

# Function to show configuration
show_configuration() {
    echo "=================================================="
    echo "         MODEL BENCHMARK AUTOMATION"
    echo "=================================================="
    echo "Framework: $FRAMEWORK"
    echo "Server Script: $SERVER_SCRIPT"
    echo "Results Directory: $RESULTS_DIR"
    echo "Log Directory: $LOG_DIR"
    echo "Total Models: ${#MODELS[@]}"
    echo "=================================================="
    echo ""
}

# Main execution function
main() {
    # Parse command line arguments
    parse_args "$@"
    
    # Setup framework-specific paths
    setup_framework_paths
    
    # Show configuration
    show_configuration
    
    print_status "Starting model benchmark automation with framework: $FRAMEWORK"
    
    # Setup
    check_dependencies
    setup_directories
    cleanup_containers
    
    # Benchmark each model
    local successful_benchmarks=0
    local failed_benchmarks=0
    
    for model_id in "${MODELS[@]}"; do
        echo ""
        print_status "Processing model $((successful_benchmarks + failed_benchmarks + 1))/${#MODELS[@]}: $model_id"
        
        if benchmark_model "$model_id"; then
            ((successful_benchmarks++))
        else
            ((failed_benchmarks++))
        fi
        
        # Brief pause between models
        if [[ $((successful_benchmarks + failed_benchmarks)) -lt ${#MODELS[@]} ]]; then
            print_status "Waiting 5 seconds before next model..."
            sleep 5
        fi
    done
    
    # Generate final report
    generate_report
    
    # Final summary
    echo ""
    echo "=================================================="
    print_status "Benchmark automation completed!"
    print_success "Framework: $FRAMEWORK"
    print_success "Successfully benchmarked: $successful_benchmarks models"
    if [[ $failed_benchmarks -gt 0 ]]; then
        print_error "Failed benchmarks: $failed_benchmarks models"
    fi
    echo "=================================================="
    print_status "Results directory: $RESULTS_DIR"
    print_status "Logs directory: $LOG_DIR"
    echo "=================================================="
}

# Trap to cleanup on script exit
#trap 'cleanup_containers' EXIT

# Run main function with all arguments
main "$@"