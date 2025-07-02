#!/bin/bash
# Shell script wrapper to run the AppleScript for summarizing current Edge tab

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Run the AppleScript
osascript "$SCRIPT_DIR/summarize-current-tab.applescript"