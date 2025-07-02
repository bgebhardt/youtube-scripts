#!/usr/bin/env python3
"""
Main script to download YouTube video and generate summary.
"""

import sys
import argparse
from pathlib import Path
from download_video import YouTubeDownloader
from summarize import summarize_with_gemini, summarize_with_ollama


def main():
    parser = argparse.ArgumentParser(description='Download and summarize YouTube videos')
    parser.add_argument('url', help='YouTube video URL')
    parser.add_argument('--output-dir', default='downloads', help='Output directory (default: downloads)')
    parser.add_argument('--cleanup', action='store_true', help='Delete interim files (audio, transcript) after summarization')
    parser.add_argument('--prompt', default='prompts/default.md', help='Path to prompt file (default: prompts/default.md)')
    parser.add_argument('--metadata', choices=['none', 'before', 'after'], default='before', 
                       help='Where to include metadata in summary file: none, before, or after (default: before)')
    parser.add_argument('--llm', choices=['gemini', 'ollama'], default='gemini',
                       help='LLM to use for summarization: gemini or ollama (default: gemini)')
    parser.add_argument('--model', default=None,
                       help='Model name (default: gemini-2.5-flash for gemini, llama3.2 for ollama)')
    
    args = parser.parse_args()
    
    try:
        print(f"Processing YouTube video: {args.url}")
        
        # Download and extract transcript
        downloader = YouTubeDownloader(args.output_dir)
        video_id, transcript, metadata, folder_name = downloader.download_with_transcript(args.url, cleanup=args.cleanup)
        
        if not transcript:
            print("Could not extract transcript from video")
            sys.exit(1)
            
        # Save transcript
        video_dir = downloader.output_dir / folder_name
        transcript_file = video_dir / "transcript.txt"
        transcript_file.write_text(transcript, encoding='utf-8')
        print(f"Transcript saved to: {transcript_file}")
        
        # Check if summary already exists
        prompt_name = Path(args.prompt).stem  # Get filename without extension
        summary_file = video_dir / f"summary.{prompt_name}.md"
        if summary_file.exists():
            print(f"Found existing summary: {summary_file}")
            summary = summary_file.read_text(encoding='utf-8')
        else:
            # Generate summary
            if args.llm == 'gemini':
                model = args.model or 'gemini-2.5-flash'
                print(f"Generating summary with Gemini ({model})...")
                summary = summarize_with_gemini(transcript, metadata, args.prompt, model)
            else:  # ollama
                model = args.model or 'llama3.2'
                print(f"Generating summary with Ollama ({model})...")
                summary = summarize_with_ollama(transcript, metadata, args.prompt, model)
            
            # Format metadata section
            metadata_section = f"""Video Information:
- Title: {metadata.get('title', 'N/A')}
- Channel: {metadata.get('channel', 'N/A')}
- Upload Date: {metadata.get('upload_date', 'N/A')}
- Duration: {metadata.get('duration', 'N/A')} seconds
- View Count: {metadata.get('view_count', 'N/A')}
- URL: {metadata.get('webpage_url', 'N/A')}
- Prompt Used: {args.prompt}
- LLM Used: {args.llm} ({model})

Description:
{metadata.get('description', 'N/A')}

{"="*60}"""
            
            # Build final content based on metadata option
            if args.metadata == 'none':
                final_content = summary
            elif args.metadata == 'before':
                final_content = f"""{metadata_section}
SUMMARY:
{"="*60}

{summary}"""
            else:  # after
                final_content = f"""{"="*60}
SUMMARY:
{"="*60}

{summary}

{"="*60}
VIDEO INFORMATION:
{"="*60}

{metadata_section}"""
            
            # Save summary
            summary_file.write_text(final_content, encoding='utf-8')
        
        print(f"Summary saved to: {summary_file}")
        print("\n" + "="*50)
        print("SUMMARY:")
        print("="*50)
        # Display the full content (metadata + summary) if it was just generated
        if summary_file.exists():
            full_content = summary_file.read_text(encoding='utf-8')
            print(full_content)
        
        # Clean up transcript file if cleanup requested
        if args.cleanup:
            transcript_file.unlink()
            print(f"\nTranscript file removed: {transcript_file}")
            # Also clean up the directory if it's empty (except for summary)
            remaining_files = [f for f in video_dir.iterdir() if not f.name.startswith("summary.")]
            if not remaining_files:
                print(f"Video directory cleaned up: {video_dir}")
            
    except Exception as e:
        print(f"Error: {e}")
        sys.exit(1)


if __name__ == "__main__":
    main()