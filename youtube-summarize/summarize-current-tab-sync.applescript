-- Synchronous YouTube Video Summarizer
-- Gets current browser tab URL, validates YouTube, runs summarizer, and copies result to clipboard

property logFile : "/Users/bryan/Library/Logs/youtube_summarizer.log"
property scriptPath : "/Users/bryan/code/personal/youtube-scripts/youtube-summarize/run.sh"
property downloadPath : "/Users/bryan/code/personal/youtube-scripts/youtube-summarize/downloads"
property promptPath : "/Users/bryan/code/personal/youtube-scripts/youtube-summarize/prompts/default.md"

on run
	logMessage("Synchronous script started")
	
	set videoURL to getCurrentURL()
	
	if videoURL is not "" then
		logMessage("Found YouTube URL: " & videoURL)
		display notification "Starting video summarization..." with title "YouTube Summarizer" sound name "Glass"
		
		set success to runSummarizationSync(videoURL)
		
		if success then
			logMessage("Summarization completed successfully")
		else
			logMessage("Summarization failed")
		end if
	else
		logMessage("No valid YouTube URL found")
		display notification "No valid YouTube URL found. Please navigate to a YouTube video first." with title "YouTube Summarizer" subtitle "Supports: youtube.com, youtu.be, m.youtube.com" sound name "Basso"
		
		-- Show helpful dialog
		display dialog "❓ No YouTube URL Found" & return & return & "Please make sure you're on a YouTube video page in one of these browsers:" & return & "• Safari" & return & "• Google Chrome" & return & "• Brave Browser" & return & "• Microsoft Edge" & return & "• Arc" & return & return & "Supported URLs:" & return & "• youtube.com/watch?v=..." & return & "• youtu.be/..." & return & "• m.youtube.com/watch?v=..." buttons {"OK"} default button "OK" with title "YouTube Summarizer" with icon caution
	end if
end run

on getCurrentURL()
	set foundURL to ""
	
	-- Try different browsers in order of preference
	-- set browsers to {{"Safari", "URL of current tab of front window"}, {"Google Chrome", "URL of active tab of front window"}, {"Brave Browser", "URL of active tab of front window"}, {"Microsoft Edge", "URL of active tab of front window"}, {"Arc", "URL of active tab of front window"}}
	-- set browsers to {{"Brave Browser", "URL of active tab of front window"}, {"Microsoft Edge", "URL of active tab of front window"}}
	set browsers to {{"Brave Browser", "URL of active tab of front window"}}
	
	repeat with browserInfo in browsers
		set browserName to item 1 of browserInfo
		set urlCommand to item 2 of browserInfo
		
		try
			if application browserName is running then
				tell application browserName
					if (count of windows) > 0 then
						set currentURL to run script ("tell application \"" & browserName & "\" to return " & urlCommand)
						log "Checking URL: " & currentURL
						if (my isValidYouTubeURL(currentURL)) then
							set foundURL to currentURL
							my logMessage("Found valid YouTube URL in " & browserName & ": " & currentURL)
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

on runSummarizationSync(videoURL)
	--	try
	-- Validate script exists
	try
		do shell script "test -f " & quoted form of scriptPath
	on error
		display notification "Script not found at: " & scriptPath with title "YouTube Summarizer" sound name "Sosumi"
		logMessage("Script not found at: " & scriptPath)
		return false
	end try
	
	-- Show progress dialog (non-blocking)
	display notification "Processing video... This may take 1-2 minutes." with title "YouTube Summarizer" sound name "Glass"
	
	-- Build and execute command synchronously (this will wait for completion)
	set shellCommand to quoted form of scriptPath & " " & quoted form of videoURL & " --output-dir " & quoted form of downloadPath & " --prompt " & quoted form of promptPath
	
	logMessage("Executing command: " & shellCommand)
	
	-- Execute synchronously - this blocks until completion
	set commandOutput to do shell script shellCommand
	
	log "cmd out: " & commandOutput
	
	logMessage("Command completed successfully")
	
	-- This is not right. Need to find by file name based on Youtube URL
	-- Find the most recent summary file
	set findCommand to "find " & quoted form of downloadPath & " -name 'summary.*.md' -type f -exec ls -t {} + | head -1"
	set latestSummaryFile to do shell script findCommand
	
	-- quick hack to get right content; TODO: fix finding the right output
	set latestSummaryFile to commandOutput
	
	if latestSummaryFile is not equal to "" then
		
		-- quick hack to get right content; TODO: fix finding the right output
		-- Read the summary file content
		--set summaryContent to do shell script "cat " & quoted form of latestSummaryFile
		set summaryContent to commandOutput
		-- TODO: none of these work to get rid of the unwanted cmd output. Need to change command be quieter.
		--set summaryContent to do shell script "awk '/# Video Information:/,EOF' " & quoted form of commandOutput
		--set summaryContent to do shell script "echo " & quoted form of commandOutput & " | sed -n '/# Video Information:/,$p'"
		-- set summaryContent to do shell script "echo " & quoted form of commandOutput & " | grep -A 999999 \" # Video Information:\""
		
		
		-- Copy to clipboard
		set the clipboard to summaryContent
		logMessage("Summary copied to clipboard (" & (length of summaryContent) & " characters)")
		
		-- Success notification
		display notification "Summary ready! Copied to clipboard." with title "YouTube Summarizer" subtitle ((length of summaryContent) as text) & " characters" sound name "Hero"
		
		-- TODO: This function is not working. Need to debug
		-- Show preview dialog
		-- my showPreviewDialog(summaryContent)
		
		return true
	else
		-- Fallback: try to extract from command output
		if length of commandOutput > 50 then
			set the clipboard to commandOutput
			display notification "Summary completed! Output copied to clipboard." with title "YouTube Summarizer" sound name "Hero"
			logMessage("Fallback: copied command output to clipboard")
			return true
		else
			display notification "No summary file found. Check logs for details." with title "YouTube Summarizer" sound name "Sosumi"
			logMessage("No summary file found and output too short: " & commandOutput)
			return false
		end if
	end if
	
	(*	on error e
		logMessage("Error in runSummarizationSync: " & e)
		display notification "Error during summarization: " & e with title "YouTube Summarizer" sound name "Sosumi"
		return false *)
	--	end try
end runSummarizationSync

-- TODO: This function is not working. Need to debug
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
		set logEntry to timestamp & " - [SYNC] " & message
		do shell script "echo " & quoted form of logEntry & " >> " & quoted form of logFile
	on error
		-- Ignore logging errors
	end try
end logMessage

-- Function to validate YouTube URLs
on isValidYouTubeURL(theURL)
	if theURL is "" then return false
	
	-- Convert to lowercase for comparison
	set lowerURL to do shell script "echo " & quoted form of theURL & " | tr '[:upper:]' '[:lower:]'"
	
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