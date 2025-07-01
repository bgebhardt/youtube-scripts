#!/bin/bash
# Setup script for YouTube Summarizer using brew and pip

echo "Setting up YouTube Summarizer with brew and pip..."

# Check if brew is installed
if ! command -v brew &> /dev/null; then
    echo "Homebrew not found. Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Install ffmpeg for audio processing
echo "Installing ffmpeg..."
brew install ffmpeg

# Create virtual environment if it doesn't exist
if [ ! -d "venv" ]; then
    echo "Creating virtual environment..."
    python3 -m venv venv
fi

# Activate virtual environment and install packages
echo "Installing Python packages..."
source venv/bin/activate
pip install -r requirements.txt

echo ""
echo "Installation complete!"
echo ""
echo "Usage:"
echo "  source venv/bin/activate"
echo "  python youtube_summarize.py <youtube_url>"
echo ""
echo "Or use the wrapper script:"
echo "  ./run.sh <youtube_url>"
echo ""
echo "Examples:"
echo "  ./run.sh https://www.youtube.com/watch?v=dQw4w9WgXcQ"
echo "  ./run.sh https://youtu.be/dQw4w9WgXcQ --output-dir my_downloads"
echo ""
echo "Setup complete!"
echo ""
echo "IMPORTANT: Set your Gemini API key:"
echo "  export GEMINI_API_KEY=your_api_key_here"
echo "  Get your API key from: https://aistudio.google.com/app/apikey"
echo ""
echo "You can add it to your shell profile (~/.bashrc, ~/.zshrc) to make it permanent."