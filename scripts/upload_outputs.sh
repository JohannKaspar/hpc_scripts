#!/bin/bash

LOCAL_DIR="/data/cephfs-1/home/users/joli13_c/voice_biomarker/outputs"
REMOTE_DIR="sharepoint:/General/Outputs"

echo "Syncing $LOCAL_DIR to $REMOTE_DIR..."
if rclone sync "$LOCAL_DIR" "$REMOTE_DIR" --verbose; then
    echo "Sync completed successfully."
else
    echo "Error during rclone sync." >&2
    exit 1
fi
