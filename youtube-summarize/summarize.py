#!/usr/bin/env python3
"""
Summarize transcript using Gemini Python API.
"""

import os
import sys
from pathlib import Path
from google import genai


def summarize_with_gemini(transcript_text: str) -> str:
    """
    Summarize transcript using Gemini Python API.
    """
    # Check for API key
    if not os.getenv('GEMINI_API_KEY'):
        raise ValueError("GEMINI_API_KEY environment variable not set. Get your API key from https://aistudio.google.com/app/apikey")
    
    client = genai.Client()
    
    prompt = f"""Please provide a comprehensive summary of this YouTube video transcript. 
Include:
- Main topic and key points
- Important details and insights
- Actionable takeaways if any
- Overall conclusion

Transcript:
{transcript_text}
"""
    
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
        
        # Generate summary
        summary = summarize_with_gemini(transcript_text)
        
        # Save summary
        summary_file = transcript_file.with_suffix('.summary.txt')
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