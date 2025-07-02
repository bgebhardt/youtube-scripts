# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Structure

This repository contains two main Python projects:

### 1. YouTube Summarizer (`youtube-summarize/`)
A comprehensive tool for downloading YouTube videos and generating AI-powered summaries with multiple LLM options.

**Core Architecture:**
- `youtube_summarize.py` - Main entry point with argument parsing and workflow orchestration
- `download_video.py` - YouTube video/audio downloading and transcript extraction using yt-dlp and Whisper
- `summarize.py` - LLM integration for Gemini and Ollama APIs
- `prompts/` - Template system for different summary types (technical, review, short, etc.)
- `downloads/` - Output directory with video-specific folders containing metadata, transcripts, and summaries

### 2. YouTube Playlist Manager (`move-from-watchlater/`)
A YouTube API integration tool for managing playlists programmatically.

## Common Development Commands

### YouTube Summarizer Setup
```bash
cd youtube-summarize
./setup.sh                # Install dependencies via brew and pip, create venv
source venv/bin/activate   # Manual venv activation
```

### YouTube Summarizer Usage
```bash
# Basic usage with wrapper script (recommended)
./run.sh <youtube_url>

# Advanced usage examples
./run.sh <url> --prompt prompts/review.md --llm ollama --model llama3.1
./run.sh <url> --metadata none --cleanup
```

### Direct Python Usage
```bash
cd youtube-summarize
source venv/bin/activate
python youtube_summarize.py <url> [options]
```

## Environment Configuration

### Secure Credential Setup
1. Copy the example environment file: `cp .env.example .env`
2. Edit `.env` with your actual API keys (this file is gitignored)
3. The `run.sh` script automatically loads variables from `.env`

### Required Environment Variables
- `GEMINI_API_KEY` - For Gemini AI summarization (get from https://aistudio.google.com/app/apikey)
- `OPENAI_API_KEY` - For OpenAI integration (optional)

### Optional Setup for Ollama (Local LLM)
```bash
brew install ollama
ollama serve
ollama pull llama3.2  # or preferred model
```

## Key Dependencies

### YouTube Summarizer
- `yt-dlp` - YouTube video/audio downloading
- `openai-whisper` - Audio transcription when subtitles unavailable  
- `google-genai` - Gemini API integration
- `ollama` - Local LLM integration
- `ffmpeg` - Audio processing (installed via brew)

### YouTube Playlist Manager
- `google-auth`, `google-auth-oauthlib`, `google-auth-httplib2` - Google OAuth
- `google-api-python-client` - YouTube Data API v3

## Prompt System Architecture

The YouTube Summarizer uses a sophisticated prompt template system located in `prompts/`:

- `default.md` - General purpose summaries
- `review.md` - Product reviews with pros/cons structure
- `short.md` - Ultra-brief summaries for quick scanning
- `prompt-types.md` - Documentation of specialized prompt types

Prompts support metadata injection via `{transcript_text}` and `{metadata}` placeholders.

## Output Structure

Video processing creates organized output in `downloads/{video_id}-{channel}-{title}/`:
- `metadata.json` - Video metadata from YouTube
- `transcript.txt` - Extracted or transcribed text
- `summary.{prompt_name}.md` - Generated summary with metadata

## Git Workflow Notes

The repository tracks changes to core Python files. Common modified files include:
- `youtube-summarize/download_video.py` 
- `youtube-summarize/youtube_summarize.py`

Development should focus on extending the prompt system, improving LLM integrations, or enhancing the download/transcription pipeline.