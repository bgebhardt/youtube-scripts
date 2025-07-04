# AppleScript Integration

Readme generated by Claude for the working proof of concept.

This directory contains AppleScript automation to summarize YouTube videos directly from your Microsoft Edge browser.

## Files

### Asynchronous Version (Original)
- `youtube-summarizer.applescript` - Complex async version with background processing
- Not currently working due to callback issues

### Synchronous Version (Recommended)
- `summarize-current-tab-sync.applescript` - Synchronous AppleScript that waits for completion
- `summarize-current-tab-sync.sh` - Shell wrapper for the synchronous AppleScript

### Legacy Files
- `summarize-current-tab.scpt` - Simple Edge-only version
- `summarize-edge-tab.sh` - Shell wrapper for Edge-only version

## Usage

### Method 1: Synchronous Shell Script (Recommended)
```bash
./summarize-current-tab-sync.sh
```

### Method 2: Direct Synchronous AppleScript
Double-click `summarize-current-tab-sync.applescript` or run:
```bash
osascript summarize-current-tab-sync.applescript
```

### Legacy Methods
```bash
# Edge-only version
./summarize-edge-tab.sh

# Simple Edge-only AppleScript
osascript summarize-current-tab.scpt
```

## What the Synchronous Version Does

1. **Multi-Browser Support**: Checks Brave, Edge, Safari, Chrome, and Arc in order
2. **Validates YouTube**: Ensures the URL is from YouTube (youtube.com, youtu.be, etc.)
3. **Shows Progress**: Displays notification that processing has started
4. **Runs Synchronously**: Executes `./run.sh` and waits for completion (1-2 minutes)
5. **Reads Summary File**: Finds and reads the generated summary markdown file
6. **Copies to Clipboard**: Automatically copies the complete summary to clipboard
7. **Shows Preview**: Displays success dialog with summary preview
8. **Obsidian Integration**: Optional button to open Obsidian for note-taking

## Setup Requirements

- Microsoft Edge browser
- YouTube Summarizer already set up (see main README)
- macOS with AppleScript support

## Workflow

1. Navigate to any YouTube video in Microsoft Edge
2. Run the AppleScript via either method above
3. Wait for processing (shows progress dialog)
4. Summary is automatically copied to clipboard
5. Success dialog shows completion status

## Error Handling

The script handles several error conditions:
- No Edge windows open
- Current tab is not a YouTube URL
- Summarizer script fails
- Network or API errors

## Customization

To use different prompt types, modify the command in the AppleScript:
```applescript
set command to "cd " & quoted form of parentDir & " && ./run.sh --prompt prompts/review.md " & quoted form of currentURL
```

## Keyboard Shortcuts

You can assign a keyboard shortcut to this script using:
- **Automator**: Create a Service and assign a hotkey
- **Script Editor**: Save as application and use system preferences
- **Third-party tools**: BetterTouchTool, Keyboard Maestro, etc.