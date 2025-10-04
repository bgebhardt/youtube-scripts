# Youtube Summarize scripts

A set of scripts for summarizing youtube videos.

# Next steps

Now that first version is working need to figure out a workflow. My desired workflow is:

1. on a youtube url 
2. trigger an AppleScript that gets the url and triggers the run.sh script that will summarize the video. It takes 15-30 seconds so it needs to be an asynchronous UI that notifies me when the script is done.
3. result copied to the clipboard
4. paste the result into an obsidian note (or anywhere else I need it)


Future want the ability to pick different prompts to use.


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

You can create different custom prompts optimized to summarize different types of videos better: technical, roleplaying, video games, etc.

 File Structure:
  downloads/
  └── {video_id}/
      ├── metadata.json
      ├── transcript.txt
      ├── summary.default.md     # Using default.md prompt
      ├── summary.basic.md       # Using basic.md prompt
      └── summary.prompt.md      # Using prompt.md prompt

  Examples:
  - prompts/default.md → summary.default.md
  - prompts/basic.md → summary.basic.md
  - prompts/technical.md → summary.technical.md

LLM Options:
  - --llm gemini - Use Gemini API (default)
  - --llm ollama - Use local Ollama
  - --model <model_name> - Specify model (default: llama3.2 for Ollama, gemini-2.5-flash for Gemini)

Transcription Engine Options:
  - --transcription-engine whisper - Use OpenAI Whisper (default)
  - --transcription-engine parakeet - Use Nvidia Parakeet-MLX (faster, Apple Silicon only)

  Features:
  1. Added ollama dependency to requirements.txt
  2. New summarize_with_ollama() function for local LLM calls
  3. Model parameter support for both Gemini and Ollama
  4. Metadata tracking - Records which LLM and model was used
  5. Error handling with helpful setup instructions for Ollama

  Usage Examples:
  # Use Gemini (default)
  ./run.sh https://youtube.com/watch?v=example

  # Use local Ollama with default llama3.2
  ./run.sh https://youtube.com/watch?v=example --llm ollama

  # Use Ollama with specific model
  ./run.sh https://youtube.com/watch?v=example --llm ollama --model llama3.1

  # Use different Gemini model
  ./run.sh https://youtube.com/watch?v=example --llm gemini --model gemini-1.5-pro
  
  # Quiet mode (disable verbose logging)
  ./run.sh https://youtube.com/watch?v=example --no-verbose

  Setup for Ollama:
  1. Install: brew install ollama
  2. Start service: ollama serve
  3. Pull model: ollama pull llama3.2

  Setup for Parakeet (Apple Silicon only):
  1. Install: pip install parakeet-mlx -U
  2. Requires ffmpeg: brew install ffmpeg (usually already installed)
  3. Use: ./run.sh <url> --transcription-engine parakeet


To set up your API keys securely:

  1. Copy the example file:
  cd youtube-summarize
  cp .env.example .env
  2. Edit .env with your actual keys:
  # The .env file is gitignored and won't be committed
  GEMINI_API_KEY=your_actual_gemini_key
  OPENAI_API_KEY=your_actual_openai_key
  3. Use normally - keys load automatically:
  ./run.sh <youtube_url>

  Alternative Options:

  Option 2: Shell Profile (Global)
  Add to your ~/.bashrc or ~/.zshrc:
  export OPENAI_API_KEY="your_key_here"
  export GEMINI_API_KEY="your_key_here"

  Option 3: One-time Environment
  OPENAI_API_KEY=your_key ./run.sh <url>

# Setup Notes

You can get your Gemini API key from: [Get API key | Google AI Studio](https://aistudio.google.com/app/apikey)

- [Gemini API quickstart  |  Google AI for Developers](https://ai.google.dev/gemini-api/docs/quickstart#python)
- [Using Gemini API keys  |  Google AI for Developers](https://ai.google.dev/gemini-api/docs/api-key#set-api-env-var)

[openai/whisper: Robust Speech Recognition via Large-Scale Weak Supervision](https://github.com/openai/whisper)

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
