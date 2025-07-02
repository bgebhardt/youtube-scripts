-- AppleScript to summarize current YouTube video from Brave Browser
-- Gets current tab URL, validates it's YouTube, runs summarizer, and copies result to clipboard

on run
	try
		-- Get the current URL from Brave Browser
		tell application "Brave Browser"
			if (count of windows) = 0 then
				display dialog "No Brave Browser windows are open." buttons {"OK"} default button 1
				return
			end if
			
			set currentURL to URL of active tab of front window
		end tell
		
		-- Validate it's a YouTube URL
		if not (currentURL contains "youtube.com" or currentURL contains "youtu.be") then
			display dialog "Current tab is not a YouTube video. Please navigate to a YouTube video and try again." buttons {"OK"} default button 1
			return
		end if
		
		-- Show processing dialog
		display dialog "Processing YouTube video: " & currentURL & return & return & "This may take a few minutes..." buttons {"Cancel", "Continue"} default button 2
		
		-- Get the script directory and run the summarizer
		set scriptPath to (path to me) as string
		set scriptDir to POSIX path of ((scriptPath as alias) as string)
		set parentDir to do shell script "dirname " & quoted form of scriptDir
		
		-- Change to the youtube-summarize directory and run the script
		set command to "cd " & quoted form of parentDir & " && ./run.sh " & quoted form of currentURL
		
		-- Execute the command and capture output
		set scriptOutput to do shell script command
		
		-- Find the most recent summary file and read it
		set findCommand to "find " & quoted form of parentDir & "/downloads -name 'summary.*.md' -type f -exec ls -t {} + | head -1"
		set latestSummaryFile to do shell script findCommand
		
		if latestSummaryFile is not equal to "" then
			-- Read the summary file content
			set summaryContent to do shell script "cat " & quoted form of latestSummaryFile
		else
			-- Fallback to extracting from script output
			set summaryStart to (offset of "SUMMARY:" in scriptOutput)
			if summaryStart > 0 then
				set summaryContent to text (summaryStart + 8) thru -1 of scriptOutput
				-- Clean up the content
				set summaryContent to do shell script "echo " & quoted form of summaryContent & " | sed 's/^=*$//' | sed '/^[[:space:]]*$/d'"
			else
				set summaryContent to scriptOutput
			end if
		end if
		
		-- Copy to clipboard
		set the clipboard to summaryContent
		
		-- Show success message
		display dialog "YouTube video summarized successfully!" & return & return & "Summary has been copied to clipboard." & return & return & "Summary length: " & (length of summaryContent) & " characters" buttons {"OK"} default button 1
		
	on error errorMessage
		-- Handle errors
		if errorMessage contains "User canceled" then
			return
		else
			display dialog "Error: " & errorMessage buttons {"OK"} default button 1
		end if
	end try
end run