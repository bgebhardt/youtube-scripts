#!/bin/bash
"""
Setup script for YouTube Summarizer
"""

echo "Setting up YouTube Summarizer..."

# Install Python dependencies
echo "Installing Python dependencies..."
pip3 install -r requirements.txt

echo ""
echo "Installation complete!"
echo ""
echo "Usage:"
echo "  python youtube_summarize.py <youtube_url>"
echo "  python youtube_summarize.py --help"
echo ""
echo "Examples:"
echo "  python youtube_summarize.py https://www.youtube.com/watch?v=dQw4w9WgXcQ"
echo "  python youtube_summarize.py https://youtu.be/dQw4w9WgXcQ --output-dir my_downloads"
echo ""
echo "Note: Make sure you have Gemini CLI installed and configured:"
echo "  Visit: https://ai.google.dev/gemini-api/docs/quickstart"