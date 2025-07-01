#!/usr/bin/env python3
"""
Main script to download YouTube video and generate summary.
"""

import sys
import argparse
from pathlib import Path
from download_video import YouTubeDownloader
from summarize import summarize_with_gemini


def main():
    parser = argparse.ArgumentParser(description='Download and summarize YouTube videos')
    parser.add_argument('url', help='YouTube video URL')
    parser.add_argument('--output-dir', default='downloads', help='Output directory (default: downloads)')
    parser.add_argument('--cleanup', action='store_true', help='Delete interim files (audio, transcript) after summarization')
    parser.add_argument('--prompt', default='prompts/basic.md', help='Path to prompt file (default: prompts/basic.md)')
    
    args = parser.parse_args()
    
    try:
        print(f"Processing YouTube video: {args.url}")
        
        # Download and extract transcript
        downloader = YouTubeDownloader(args.output_dir)
        video_id, transcript = downloader.download_with_transcript(args.url, cleanup=args.cleanup)
        
        if not transcript:
            print("Could not extract transcript from video")
            sys.exit(1)
            
        # Save transcript
        transcript_file = downloader.output_dir / f"{video_id}_transcript.txt"
        transcript_file.write_text(transcript, encoding='utf-8')
        print(f"Transcript saved to: {transcript_file}")
        
        # Check if summary already exists
        summary_file = transcript_file.with_suffix('.summary.txt')
        if summary_file.exists():
            print(f"Found existing summary: {summary_file}")
            summary = summary_file.read_text(encoding='utf-8')
        else:
            # Generate summary
            print("Generating summary with Gemini...")
            summary = summarize_with_gemini(transcript, args.prompt)
            
            # Save summary
            summary_file.write_text(summary, encoding='utf-8')
        
        print(f"Summary saved to: {summary_file}")
        print("\n" + "="*50)
        print("SUMMARY:")
        print("="*50)
        print(summary)
        
        # Clean up transcript file if cleanup requested
        if args.cleanup:
            transcript_file.unlink()
            print(f"\nTranscript file removed: {transcript_file}")
            
    except Exception as e:
        print(f"Error: {e}")
        sys.exit(1)


if __name__ == "__main__":
    main()