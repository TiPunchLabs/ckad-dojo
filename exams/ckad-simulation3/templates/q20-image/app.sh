#!/bin/bash
# Olympus Application

echo "Starting Olympus Application..."
echo "Version: ${APP_VERSION:-unknown}"
echo "Container ID: $(hostname)"

while true; do
    echo "$(date) - Olympus app running..."
    sleep 5
done
