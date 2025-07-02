#!/bin/bash

# YouTube Summarizer Setup Script
# This script sets up the complete workflow for YouTube video summarization

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration variables
SCRIPT_NAME="YouTube Summarizer"
APP_NAME="YouTube Summarizer.app"
DESKTOP_PATH="$HOME/Desktop"
APPLICATIONS_PATH="/Applications"
LOG_DIR="$HOME/Library/Logs"
LOG_FILE="$LOG_DIR/youtube_summarizer.log"

echo -e "${BLUE}🎬 YouTube Summarizer Setup${NC}"
echo "=================================="
echo

# Function to print colored output
print_status() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check prerequisites
echo "Checking prerequisites..."

if ! command_exists osascript; then
    print_error "AppleScript (osascript) not found. This script requires macOS."
    exit 1
fi

if ! command_exists osacompile; then
    print_error "osacompile not found. Please install Xcode Command Line Tools."
    exit 1
fi

print_status "Prerequisites check passed"
echo

# Get the path to the run.sh script
echo "Step 1: Locating your summarization script"
echo "==========================================="

# Try to find run.sh in common locations
POSSIBLE_PATHS=(
    "$HOME/run.sh"
    "$HOME/scripts/run.sh"
    "$HOME/bin/run.sh"
    "$HOME/Desktop/run.sh"
    "$HOME/Documents/run.sh"
    "$(pwd)/run.sh"
)

SCRIPT_PATH=""
for path in "${POSSIBLE_PATHS[@]}"; do
    if [[ -f "$path" ]]; then
        echo "Found script at: $path"
        read -p "Is this your YouTube summarizer script? (y/n): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            SCRIPT_PATH="$path"
            break
        fi
    fi
done

if [[ -z "$SCRIPT_PATH" ]]; then
    echo "Please enter the full path to your run.sh script:"
    read -r SCRIPT_PATH
    
    # Expand tilde
    SCRIPT_PATH="${SCRIPT_PATH/#\~/$HOME}"
    
    if [[ ! -f "$SCRIPT_PATH" ]]; then
        print_error "Script not found at: $SCRIPT_PATH"
        exit 1
    fi
fi

# Make sure the script is executable
chmod +x "$SCRIPT_PATH"
print_status "Script path confirmed: $SCRIPT_PATH"
echo

# Test the script quickly
echo "Step 2: Testing your script"
echo "=========================="
echo "Testing if your script can be executed..."

if timeout 10s "$SCRIPT_PATH" --help >/dev/null 2>&1 || timeout 10s "$SCRIPT_PATH" -h >/dev/null 2>&1; then
    print_status "Script appears to be working"
elif [[ $? -eq 124 ]]; then
    print_warning "Script test timed out (this might be normal)"
else
    print_warning "Script test failed, but continuing anyway"
fi
echo

# Create the AppleScript
echo "Step 3: Creating AppleScript application"
echo "======================================="

APPLESCRIPT_CONTENT=$(cat << 'EOF'
-- Enhanced YouTube Video Summarizer with logging and better error handling

property logFile : "LOG_FILE_PLACEHOLDER"
property scriptPath : "SCRIPT_PATH_PLACEHOLDER"

on run
	logMessage("Script started")
	
	set videoURL to getCurrentURL()
	
	if videoURL is not "" then
		logMessage("Found YouTube URL: " & videoURL)
		display notification "Starting video summarization..." with title "YouTube Summarizer" sound name "Glass"
		runSummarizationAsync(videoURL)
	else
		logMessage("No valid YouTube URL found")
		display notification "No valid YouTube URL found. Please navigate to a YouTube video first." with title "YouTube Summarizer" subtitle "Supports: youtube.com, youtu.be, m.youtube.com" sound name "Basso"
		
		-- Show helpful dialog
		display dialog "❌ No YouTube URL Found" & return & return & "Please make sure you're on a YouTube video page in one of these browsers:" & return & "• Safari" & return & "• Google Chrome" & return & "• Brave Browser" & return & "• Microsoft Edge" & return & "• Arc" & return & return & "Supported URLs:" & return & "• youtube.com/watch?v=..." & return & "• youtu.be/..." & return & "• m.youtube.com/watch?v=..." buttons {"OK"} default button "OK" with title "YouTube Summarizer" with icon caution
	end if
end run

on getCurrentURL()
	set foundURL to ""
	
	-- Try different browsers in order of preference
	-- set browsers to {{"Safari", "URL of current tab of front window"}, {"Google Chrome", "URL of active tab of front window"}, {"Brave Browser", "URL of active tab of front window"}, {"Microsoft Edge", "URL of active tab of front window"}, {"Arc", "URL of active tab of front window"}}
    set browsers to {{"Brave Browser", "URL of active tab of front window"}, {"Microsoft Edge", "URL of active tab of front window"}}
	
	repeat with browserInfo in browsers
		set browserName to item 1 of browserInfo
		set urlCommand to item 2 of browserInfo
		
		try
			if application browserName is running then
				tell application browserName
					if (count of windows) > 0 then
						set currentURL to run script ("tell application \"" & browserName & "\" to return " & urlCommand)
						if isValidYouTubeURL(currentURL) then
							set foundURL to currentURL
							logMessage("Found valid YouTube URL in " & browserName & ": " & currentURL)
							exit repeat
						end if
					end if
				end tell
			end if
		on error e
			logMessage("Error checking " & browserName & ": " & e)
		end try
	end repeat
	
	return foundURL
end getCurrentURL

on runSummarizationAsync(videoURL)
	try
		-- Create unique temp file
		set tempFile to "/tmp/youtube_summary_" & (do shell script "date +%s") & "_" & (random number from 1000 to 9999) & ".txt"
		logMessage("Using temp file: " & tempFile)
		
		-- Validate script exists
		try
			do shell script "test -f " & quoted form of scriptPath
		on error
			display notification "Script not found at: " & scriptPath with title "YouTube Summarizer" sound name "Sosumi"
			logMessage("Script not found at: " & scriptPath)
			return
		end try
		
		-- Build command with proper error handling
		set timeoutCommand to "timeout 300" -- 5 minute timeout
		set shellCommand to timeoutCommand & " " & quoted form of scriptPath & " " & quoted form of videoURL & " > " & quoted form of tempFile & " 2>&1"
		
		-- Add completion handler
		set completionCommand to " && osascript -e 'tell me to handleCompletion(\"" & tempFile & "\")'"
		set errorCommand to " || osascript -e 'tell me to handleError(\"" & tempFile & "\")'"
		
		set fullCommand to "(" & shellCommand & completionCommand & errorCommand & ") &"
		
		logMessage("Executing command: " & fullCommand)
		do shell script fullCommand
		
	on error e
		logMessage("Error in runSummarizationAsync: " & e)
		display notification "Error starting summarization: " & e with title "YouTube Summarizer" sound name "Sosumi"
	end try
end runSummarizationAsync

on handleCompletion(tempFile)
	try
		logMessage("Handling completion for: " & tempFile)
		
		-- Check if file exists and has content
		try
			set fileSize to do shell script "wc -c < " & quoted form of tempFile
			if (fileSize as integer) = 0 then
				handleError(tempFile)
				return
			end if
		on error
			handleError(tempFile)
			return
		end try
		
		-- Read the result
		set summaryResult to do shell script "cat " & quoted form of tempFile
		
		-- Validate result
		if length of summaryResult < 10 then
			display notification "Summary seems too short. Check the log for details." with title "YouTube Summarizer" sound name "Sosumi"
			logMessage("Summary too short: " & summaryResult)
			return
		end if
		
		-- Copy to clipboard
		set the clipboard to summaryResult
		logMessage("Summary copied to clipboard (" & (length of summaryResult) & " characters)")
		
		-- Clean up
		do shell script "rm -f " & quoted form of tempFile
		
		-- Success notification
		display notification "Summary ready! Click to view preview." with title "YouTube Summarizer" subtitle "Copied to clipboard" sound name "Hero"
		
		-- Show preview dialog
		showPreviewDialog(summaryResult)
		
	on error e
		logMessage("Error in handleCompletion: " & e)
		display notification "Error processing result: " & e with title "YouTube Summarizer" sound name "Sosumi"
	end try
end handleCompletion

on handleError(tempFile)
	try
		logMessage("Handling error for: " & tempFile)
		
		set errorOutput to ""
		try
			set errorOutput to do shell script "cat " & quoted form of tempFile
		end try
		
		if errorOutput is not "" then
			logMessage("Error output: " & errorOutput)
			display notification "Summarization failed. Check log for details." with title "YouTube Summarizer" sound name "Sosumi"
		else
			logMessage("No error output found")
			display notification "Summarization timed out or failed silently." with title "YouTube Summarizer" sound name "Sosumi"
		end if
		
		-- Clean up
		do shell script "rm -f " & quoted form of tempFile
		
	on error e
		logMessage("Error in handleError: " & e)
	end try
end handleError

on showPreviewDialog(summaryText)
	try
		set shortPreview to text 1 thru (min(300, length of summaryText)) of summaryText
		if length of summaryText > 300 then set shortPreview to shortPreview & "..."
		
		set dialogResult to display dialog "✅ Video summarized successfully!" & return & return & "📄 Preview:" & return & shortPreview & return & return & "The full summary has been copied to your clipboard." buttons {"Open Obsidian", "Done"} default button "Done" with title "YouTube Summarizer" with icon note
		
		if button returned of dialogResult is "Open Obsidian" then
			openObsidian()
		end if
		
	on error
		-- Fallback to simple notification if dialog fails
		display notification "Summary completed and copied to clipboard!" with title "YouTube Summarizer"
	end try
end showPreviewDialog

on openObsidian()
	try
		tell application "Obsidian" to activate
		delay 0.5
		-- Create new note with Cmd+N
		tell application "System Events"
			keystroke "n" using command down
		end tell
	on error
		display notification "Could not open Obsidian. Please open it manually." with title "YouTube Summarizer"
	end try
end openObsidian

on logMessage(message)
	try
		set timestamp to do shell script "date '+%Y-%m-%d %H:%M:%S'"
		set logEntry to timestamp & " - " & message
		do shell script "echo " & quoted form of logEntry & " >> " & quoted form of logFile
	end try
end logMessage

-- Function to validate YouTube URLs
on isValidYouTubeURL(url)
	if url is "" then return false
	
	-- Convert to lowercase for comparison
	set lowerURL to do shell script "echo " & quoted form of url & " | tr '[:upper:]' '[:lower:]'"
	
	-- Check for various YouTube URL patterns
	set youtubePatterns to {"youtube.com/watch", "youtu.be/", "m.youtube.com/watch", "youtube.com/embed/", "youtube.com/v/", "youtube.com/shorts/"}
	
	repeat with pattern in youtubePatterns
		if lowerURL contains pattern then
			-- Additional validation: make sure it looks like it has a video ID
			if pattern is "youtu.be/" then
				-- For youtu.be links, check there's something after the slash
				if (offset of "youtu.be/" in lowerURL) + 9 < length of lowerURL then
					return true
				end if
			else if pattern contains "watch" then
				-- For watch URLs, check for v= parameter
				if lowerURL contains "v=" then
					return true
				end if
			else if pattern contains "embed/" or pattern contains "v/" or pattern contains "shorts/" then
				-- For embed, v, and shorts URLs, check there's something after the slash
				set patternEnd to (offset of pattern in lowerURL) + (length of pattern)
				if patternEnd < length of lowerURL then
					return true
				end if
			end if
		end if
	end repeat
	
	return false
end isValidYouTubeURL
EOF
)

# Replace placeholders in the AppleScript
APPLESCRIPT_CONTENT="${APPLESCRIPT_CONTENT//SCRIPT_PATH_PLACEHOLDER/$SCRIPT_PATH}"
APPLESCRIPT_CONTENT="${APPLESCRIPT_CONTENT//LOG_FILE_PLACEHOLDER/$LOG_FILE}"

# Create temporary AppleScript file
TEMP_SCRIPT="/tmp/youtube_summarizer.applescript"
echo "$APPLESCRIPT_CONTENT" > "$TEMP_SCRIPT"

# Compile the AppleScript to an application
APP_PATH="$DESKTOP_PATH/$APP_NAME"
osacompile -o "$APP_PATH" "$TEMP_SCRIPT"

# Clean up temporary file
rm "$TEMP_SCRIPT"

print_status "AppleScript application created at: $APP_PATH"
echo

# Set up logging
echo "Step 4: Setting up logging"
echo "========================="

mkdir -p "$LOG_DIR"
touch "$LOG_FILE"
print_status "Log file created: $LOG_FILE"
echo

# Create a launcher script for easier access
echo "Step 5: Creating launcher script"
echo "==============================="

LAUNCHER_SCRIPT="$HOME/bin/youtube-summarizer"
mkdir -p "$HOME/bin"

cat > "$LAUNCHER_SCRIPT" << EOF
#!/bin/bash
# YouTube Summarizer Launcher
open "$APP_PATH"
EOF

chmod +x "$LAUNCHER_SCRIPT"
print_status "Launcher script created: $LAUNCHER_SCRIPT"
echo

# Check if ~/bin is in PATH
if [[ ":$PATH:" != *":$HOME/bin:"* ]]; then
    print_warning "Note: $HOME/bin is not in your PATH. Add this to your shell profile:"
    echo "export PATH=\"\$HOME/bin:\$PATH\""
    echo
fi

# Keyboard shortcut setup instructions
echo "Step 6: Setting up keyboard shortcut"
echo "===================================="

print_info "To set up a keyboard shortcut for easy access:"
echo "1. Open System Preferences → Keyboard → Shortcuts"
echo "2. Click 'App Shortcuts' in the left sidebar"
echo "3. Click the '+' button"
echo "4. Application: Select 'All Applications'"
echo "5. Menu Title: Enter exactly: YouTube Summarizer"
echo "6. Keyboard Shortcut: Press your desired key combination (e.g., ⌘⌥Y)"
echo "7. Click 'Add'"
echo

# Alternative: Shortcuts app method
print_info "Alternative method using Shortcuts app:"
echo "1. Open the Shortcuts app"
echo "2. Click '+' to create a new shortcut"
echo "3. Add 'Run AppleScript' action"
echo "4. Paste this code:"
echo "   tell application \"$APP_NAME\" to activate"
echo "5. Save the shortcut with a name like 'YouTube Summarizer'"
echo "6. Right-click the shortcut → 'Add to Dock' for easy access"
echo

# Create a test YouTube URL for verification
echo "Step 7: Testing the setup"
echo "========================"

print_info "Let's test the setup with a sample YouTube URL"
echo "Please:"
echo "1. Open any browser (Safari, Chrome, Brave, Edge, or Arc)"
echo "2. Navigate to any YouTube video"
echo "3. Double-click the YouTube Summarizer app on your Desktop"
echo

read -p "Press Enter when you're ready to continue with setup verification..."
echo

# Create an uninstaller
echo "Step 8: Creating uninstaller"
echo "==========================="

UNINSTALL_SCRIPT="$HOME/Desktop/Uninstall YouTube Summarizer.sh"
cat > "$UNINSTALL_SCRIPT" << EOF
#!/bin/bash
# YouTube Summarizer Uninstaller

echo "Removing YouTube Summarizer..."
rm -rf "$APP_PATH"
rm -f "$LAUNCHER_SCRIPT"
rm -f "$LOG_FILE"
rm -f "\$0"  # Remove this script
echo "YouTube Summarizer has been uninstalled."
EOF

chmod +x "$UNINSTALL_SCRIPT"
print_status "Uninstaller created: $UNINSTALL_SCRIPT"
echo

# Final setup summary
echo "Setup Complete! 🎉"
echo "=================="
echo
print_status "✅ AppleScript app created: $APP_PATH"
print_status "✅ Launcher script: $LAUNCHER_SCRIPT"
print_status "✅ Log file: $LOG_FILE"
print_status "✅ Uninstaller: $UNINSTALL_SCRIPT"
echo

echo -e "${GREEN}🚀 How to use:${NC}"
echo "1. Navigate to any YouTube video in your browser"
echo "2. Double-click 'YouTube Summarizer.app' on your Desktop"
echo "3. Or run: youtube-summarizer (if ~/bin is in your PATH)"
echo "4. Wait for the notification when summary is ready"
echo "5. Summary will be automatically copied to clipboard"
echo "6. Paste into Obsidian or anywhere else!"
echo

echo -e "${BLUE}📋 Workflow Summary:${NC}"
echo "• Supports: Safari, Chrome, Brave, Edge, Arc browsers"
echo "• Validates YouTube URLs automatically"
echo "• Runs summarization in background (15-30 seconds)"
echo "• Shows notifications for start/complete/errors"
echo "• Auto-copies result to clipboard"
echo "• Optional Obsidian integration"
echo "• Comprehensive logging for troubleshooting"
echo

echo -e "${YELLOW}📝 Next Steps:${NC}"
echo "1. Set up a keyboard shortcut (instructions above)"
echo "2. Test with a YouTube video"
echo "3. Check the log file if you encounter issues"
echo

print_info "Tip: You can view logs anytime with: tail -f $LOG_FILE"
echo

print_status "Setup completed successfully!"