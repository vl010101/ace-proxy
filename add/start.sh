#!/bin/bash

echo "Starting Ace Stream engine in RAM-cache mode with limited upload..."
# Запускаем движок с оптимизированными параметрами
/opt/acestream.engine/start-engine \
    --client-console \
    --bind-all \
    # --- Новые параметры для оптимизации ---
    --live-cache-type memory \
    --memory-cache-limit 256 \
    --upload-limit 500 \
    --max-peers 40 &

echo "Waiting for 5 seconds for the engine to initialize..."
sleep 5

echo "Starting HTTPAceProxy in the foreground..."
# Запускаем прокси
exec python3 /opt/HTTPAceProxy-master/acehttp.py
