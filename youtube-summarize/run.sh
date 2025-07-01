#!/bin/bash
# Wrapper script to run youtube_summarize.py with virtual environment

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Activate virtual environment and run the script
source "$SCRIPT_DIR/venv/bin/activate"
python "$SCRIPT_DIR/youtube_summarize.py" "$@"