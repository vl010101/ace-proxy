#!/bin/bash

echo "Starting Ace Stream engine in the background..."
# Start the engine with the required --client-console flag
/opt/acestream.engine/start-engine --client-console --bind-all &

echo "Waiting for 5 seconds for the engine to initialize..."
sleep 5

echo "Starting HTTPAceProxy in the foreground..."
# Use exec to replace the shell process with the python process.
exec python3 /opt/HTTPAceProxy-master/acehttp.py
