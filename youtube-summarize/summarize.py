#!/usr/bin/env python3
"""
Summarize transcript using Gemini Python API.
"""

import os
import sys
from pathlib import Path
from google import genai


def summarize_with_gemini(transcript_text: str, metadata: dict = None, prompt_file: str = "prompts/default.md") -> str:
    """
    Summarize transcript using Gemini Python API.
    """
    # Check for API key
    if not os.getenv('GEMINI_API_KEY'):
        raise ValueError("GEMINI_API_KEY environment variable not set. Get your API key from https://aistudio.google.com/app/apikey")
    
    client = genai.Client()
    
    # Load prompt from file
    prompt_path = Path(prompt_file)
    if not prompt_path.exists():
        raise FileNotFoundError(f"Prompt file not found: {prompt_file}")
    
    prompt_template = prompt_path.read_text(encoding='utf-8')
    
    # Format metadata for inclusion in prompt
    metadata_text = ""
    if metadata:
        metadata_text = f"""
Video Metadata:
- Title: {metadata.get('title', 'N/A')}
- Channel: {metadata.get('channel', 'N/A')}
- Upload Date: {metadata.get('upload_date', 'N/A')}
- Duration: {metadata.get('duration', 'N/A')} seconds
- Description: {metadata.get('description', 'N/A')[:500]}...

"""
    
    prompt = prompt_template.format(
        transcript_text=transcript_text,
        metadata=metadata_text
    )
    
    try:
        response = client.models.generate_content(
            model="gemini-2.5-flash",
            contents=prompt
        )
        
        return response.text
        
    except Exception as e:
        print(f"Error calling Gemini API: {e}")
        raise


def main():
    if len(sys.argv) != 2:
        print("Usage: python summarize.py <transcript_file>")
        sys.exit(1)
        
    transcript_file = Path(sys.argv[1])
    
    if not transcript_file.exists():
        print(f"Transcript file not found: {transcript_file}")
        sys.exit(1)
        
    try:
        # Read transcript
        transcript_text = transcript_file.read_text(encoding='utf-8')
        
        if not transcript_text.strip():
            print("Transcript file is empty")
            sys.exit(1)
            
        print("Generating summary with Gemini...")
        
        # Use default prompt if running standalone
        prompt_file = "prompts/default.md"
        if len(sys.argv) > 2:
            prompt_file = sys.argv[2]
        
        # Generate summary
        summary = summarize_with_gemini(transcript_text, None, prompt_file)
        
        # Save summary with prompt name
        prompt_name = Path(prompt_file).stem
        summary_file = transcript_file.parent / f"summary.{prompt_name}.md"
        summary_file.write_text(summary, encoding='utf-8')
        
        print(f"Summary saved to: {summary_file}")
        print("\n" + "="*50)
        print("SUMMARY:")
        print("="*50)
        print(summary)
        
    except Exception as e:
        print(f"Error: {e}")
        sys.exit(1)


if __name__ == "__main__":
    main()