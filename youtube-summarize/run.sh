#!/bin/bash
# Wrapper script to run youtube_summarize.py with virtual environment

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Load environment variables from .env file if it exists
if [ -f "$SCRIPT_DIR/.env" ]; then
    export $(cat "$SCRIPT_DIR/.env" | grep -v '^#' | xargs)
    #echo "Loaded environment variables from .env file"
fi

# Activate virtual environment and run the script
source "$SCRIPT_DIR/venv/bin/activate"
python "$SCRIPT_DIR/youtube_summarize.py" "$@"