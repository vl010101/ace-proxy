#!/bin/bash

echo "Starting Ace Stream engine in the background with a 1GB disk cache limit..."
# Запускаем движок с флагами для консольного режима и ограничения кэша
/opt/acestream.engine/start-engine \
    --client-console \
    --bind-all \
    --disk-cache-limit 1024 &

echo "Waiting for 5 seconds for the engine to initialize..."
sleep 5

echo "Starting HTTPAceProxy in the foreground..."
# Запускаем прокси
exec python3 /opt/HTTPAceProxy-master/acehttp.py
