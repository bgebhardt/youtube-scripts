#!/bin/bash
# Shell script wrapper to run the synchronous AppleScript for summarizing current browser tab

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Run the synchronous AppleScript
osascript "$SCRIPT_DIR/summarize-current-tab-sync.applescript"