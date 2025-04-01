#!/bin/bash

# Automatically get the current machine's hostname
NODE_NAME=$(hostname)

echo "using node $NODE_NAME"

# Activate the uv environment
activate

# Launch Jupyter Notebook in the background and capture output in a file
LOG_FILE=$(mktemp)
echo "launching notebook"
jupyter lab > "$LOG_FILE" 2>&1 &

# Wait for a few seconds to allow Jupyter to start
sleep 20

# Extract the URL with the token from the log file
JUPYTER_URL=$(grep -oP '(http://localhost:[0-9]+/lab\?token=[a-zA-Z0-9]+)' "$LOG_FILE")

# Check if the URL was found
if [ -z "$JUPYTER_URL" ]; then
    echo "Could not find Jupyter Notebook URL with token."
    cat "$LOG_FILE"
    exit 1
fi

# Print the extracted Jupyter URL
echo "$JUPYTER_URL"
