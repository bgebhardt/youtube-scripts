-- Enhanced YouTube Video Summarizer with logging and better error handling


(*-- TODO: this is currently failing at shelling out the command.
--  example error

(timeout 300 '/Users/bryan/code/personal/youtube-scripts/youtube-summarize/run.sh' 'https://www.youtube.com/watch?v=PWeV8Oecya8' --output-dir '/Users/bryan/code/personal/youtube-scripts/youtube-summarize/downloads' > '/tmp/youtube_summary_1751424653_6957.txt' 2>&1 && osascript -e 'tell me to handleCompletion("/tmp/youtube_summary_1751424653_6957.txt")' || osascript -e 'tell me to handleError("/tmp/youtube_summary_1751424653_6957.txt")')
bash: /tmp/youtube_summary_1751424653_6957.txt: cannot overwrite existing file
11:66: execution error: ÇscriptÈ doesnÕt understand the ÒhandleErrorÓ message. (-1708)

I think maybe the osascript call is not including the script application

*)

-- property logFile : "~/Library/Logs/youtube_summarizer.log"
-- property scriptPath : "~/path/to/your/run.sh" -- UPDATE THIS PATH
-- Enhanced YouTube Video Summarizer with logging and better error handling

property logFile : "/Users/bryan/Library/Logs/youtube_summarizer.log"
property scriptPath : "/Users/bryan/code/personal/youtube-scripts/youtube-summarize/run.sh"
property downloadPath : "/Users/bryan/code/personal/youtube-scripts/youtube-summarize/downloads"
property promptPath : "/Users/bryan/code/personal/youtube-scripts/youtube-summarize/prompts/default.md"


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
		display dialog "? No YouTube URL Found" & return & return & "Please make sure you're on a YouTube video page in one of these browsers:" & return & "¥ Safari" & return & "¥ Google Chrome" & return & "¥ Brave Browser" & return & "¥ Microsoft Edge" & return & "¥ Arc" & return & return & "Supported URLs:" & return & "¥ youtube.com/watch?v=..." & return & "¥ youtu.be/..." & return & "¥ m.youtube.com/watch?v=..." buttons {"OK"} default button "OK" with title "YouTube Summarizer" with icon caution
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
						log "before valid check " & currentURL
						if (my isValidYouTubeURL(currentURL)) then
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
		set timeoutCommand to "/opt/homebrew/bin/timeout 300" -- 5 minute timeout
		set shellCommand to timeoutCommand & " " & quoted form of scriptPath & " " & quoted form of videoURL & " --output-dir " & quoted form of downloadPath & " --prompt " & quoted form of promptPath & " > " & quoted form of tempFile & " 2>&1"
		
		-- Add completion handler
		--		set completionCommand to " && osascript -e 'tell me to handleCompletion(\"" & tempFile & "\")'"
		--		set errorCommand to " || osascript -e 'tell me to handleError(\"" & tempFile & "\")'"
		
		--		set fullCommand to "(" & shellCommand & completionCommand & errorCommand & ") &"
		set fullCommand to "(" & shellCommand & ") &"
		
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
		
		set dialogResult to display dialog "? Video summarized successfully!" & return & return & "?? Preview:" & return & shortPreview & return & return & "The full summary has been copied to your clipboard." buttons {"Open Obsidian", "Done"} default button "Done" with title "YouTube Summarizer" with icon note
		
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
on isValidYouTubeURL(theURL)
	log "checking url: " & theURL
	if URL is "" then return false
	
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
