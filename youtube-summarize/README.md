# Youtube Summarize scripts

A set of scripts for summarizing youtube videos.

# Summary

  To use:
  1. Run ./setup.sh to install the new dependency
  2. Get an API key from https://aistudio.google.com/app/apikey
  3. Set the environment variable: export GEMINI_API_KEY=your_api_key_here
  4. Run ./run.sh <youtube_url>

  Usage:
  # Use default basic prompt
  ./run.sh https://www.youtube.com/watch?v=example

  # Use the detailed technical prompt
  ./run.sh https://www.youtube.com/watch?v=example --prompt prompts/prompt.md

  # Use a custom prompt file
  ./run.sh https://www.youtube.com/watch?v=example --prompt my_custom_prompt.md

  Prompt file format:
  - Use {transcript_text} as placeholder for the transcript
  - See prompts/basic.md and prompts/prompt.md for examples

# Requirements

In the youtube-summarize directory create a script or set of scripts that will

1. Download a youtube video
1.1. Download the transcript or subtitles if they are available
1.2. If no transcript or subtitles then download the video audio only and transcribe the audio with a tool like whisper
2. take the resulting transcript and summarize it

# Suggested tools to use:

- YouTube Downloader - yt-dlp (best overall); Install: pip install yt-dlp
- Text to speech - Faster-Whisper (for speed); Install: pip install faster-whisper
- AI Summarization - Gemini CLI

# All tools considered

## YouTube Downloaders
yt-dlp (best overall)

Command-line tool, successor to youtube-dl
Supports audio-only downloads
Cross-platform and actively maintained
Install: pip install yt-dlp

## Speech-to-Text

### OpenAI Whisper (recommended)

Excellent accuracy, supports many languages
Free and runs locally
Install: pip install openai-whisper

### Faster-Whisper (for speed)

Optimized version of Whisper
Much faster processing
Install: pip install faster-whisper

# AI Summarization

Gemini CLI
OpenAI API (GPT-4/3.5)
Anthropic API (Claude)
Local models (Ollama with Llama)
