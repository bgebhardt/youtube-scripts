#!/usr/bin/env python3
"""
YouTube video downloader with transcript extraction and audio fallback.
"""

import os
import sys
import json
import tempfile
from pathlib import Path
from typing import Optional, Tuple, Dict
import yt_dlp
import whisper


class YouTubeDownloader:
    def __init__(self, output_dir: str = "downloads"):
        self.output_dir = Path(output_dir)
        self.output_dir.mkdir(exist_ok=True)
        
    def download_with_transcript(self, url: str, cleanup: bool = False) -> Tuple[str, Optional[str], Dict]:
        """
        Download YouTube video and extract transcript.
        Returns: (video_id, transcript_text or None, metadata)
        """
        # Extract metadata first
        metadata = self._extract_metadata(url)
        video_id = metadata['id']
        
        # Save metadata to file
        metadata_file = self.output_dir / f"{video_id}_metadata.json"
        if not metadata_file.exists():
            metadata_file.write_text(json.dumps(metadata, indent=2, ensure_ascii=False), encoding='utf-8')
            print(f"Metadata saved to: {metadata_file}")
        else:
            print(f"Found existing metadata: {metadata_file}")
        
        # Check if transcript file already exists
        transcript_file = self.output_dir / f"{video_id}_transcript.txt"
        if transcript_file.exists():
            print(f"Found existing transcript: {transcript_file}")
            transcript = transcript_file.read_text(encoding='utf-8')
            return video_id, transcript, metadata
        
        # Try to get transcript/subtitles from YouTube
        transcript = self._extract_transcript(url)
        
        if transcript:
            return video_id, transcript, metadata
            
        # Fallback: download audio and transcribe with Whisper
        video_id, transcript = self._download_and_transcribe(url, cleanup)
        return video_id, transcript, metadata
    
    def _extract_transcript(self, url: str) -> Optional[str]:
        """Extract transcript/subtitles if available."""
        ydl_opts = {
            'writesubtitles': True,
            'writeautomaticsub': True,
            'subtitleslangs': ['en'],
            'skip_download': True,
            'outtmpl': str(self.output_dir / '%(id)s.%(ext)s'),
        }
        
        try:
            with yt_dlp.YoutubeDL(ydl_opts) as ydl:
                info = ydl.extract_info(url, download=False)
                video_id = info['id']
                
                # Try to download subtitles
                ydl.download([url])
                
                # Look for subtitle files
                for ext in ['en.vtt', 'en.srt']:
                    subtitle_file = self.output_dir / f"{video_id}.{ext}"
                    if subtitle_file.exists():
                        return self._parse_subtitle_file(subtitle_file)
                        
        except Exception as e:
            print(f"Could not extract transcript: {e}")
            
        return None
    
    def _parse_subtitle_file(self, subtitle_file: Path) -> str:
        """Parse VTT or SRT subtitle file to extract text."""
        content = subtitle_file.read_text(encoding='utf-8')
        lines = content.split('\n')
        
        transcript_lines = []
        for line in lines:
            line = line.strip()
            # Skip timestamp lines and empty lines
            if (not line or 
                line.startswith('WEBVTT') or 
                line.startswith('NOTE') or
                '-->' in line or
                line.isdigit()):
                continue
            transcript_lines.append(line)
        
        # Clean up the transcript file
        subtitle_file.unlink()
        
        return ' '.join(transcript_lines)
    
    def _download_and_transcribe(self, url: str, cleanup: bool = False) -> Tuple[str, str]:
        """Download audio and transcribe with Whisper."""
        print("No transcript found. Downloading audio for transcription...")
        
        # Download audio only
        audio_file = self._download_audio(url)
        video_id = self._get_video_id(url)
        
        # Transcribe with Whisper
        transcript = self._transcribe_audio(audio_file)
        
        # Clean up audio file only if cleanup is requested
        if cleanup:
            audio_file.unlink()
            print(f"Audio file removed: {audio_file}")
        else:
            print(f"Audio file saved: {audio_file}")
        
        return video_id, transcript
    
    def _download_audio(self, url: str) -> Path:
        """Download audio only."""
        ydl_opts = {
            'format': 'bestaudio/best',
            'outtmpl': str(self.output_dir / '%(id)s.%(ext)s'),
            'postprocessors': [{
                'key': 'FFmpegExtractAudio',
                'preferredcodec': 'wav',
            }],
        }
        
        with yt_dlp.YoutubeDL(ydl_opts) as ydl:
            info = ydl.extract_info(url, download=True)
            video_id = info['id']
            
        audio_file = self.output_dir / f"{video_id}.wav"
        return audio_file
    
    def _transcribe_audio(self, audio_file: Path) -> str:
        """Transcribe audio using OpenAI Whisper."""
        print("Transcribing audio with Whisper...")
        
        model = whisper.load_model("base")
        result = model.transcribe(str(audio_file))
        
        return result["text"]
    
    def _extract_metadata(self, url: str) -> Dict:
        """Extract video metadata."""
        ydl_opts = {
            'quiet': True,
            'no_warnings': True,
        }
        
        with yt_dlp.YoutubeDL(ydl_opts) as ydl:
            info = ydl.extract_info(url, download=False)
            
            metadata = {
                'id': info.get('id'),
                'title': info.get('title'),
                'uploader': info.get('uploader'),
                'channel': info.get('channel'),
                'channel_id': info.get('channel_id'),
                'upload_date': info.get('upload_date'),
                'description': info.get('description'),
                'duration': info.get('duration'),
                'view_count': info.get('view_count'),
                'webpage_url': info.get('webpage_url'),
                'thumbnail': info.get('thumbnail'),
            }
            
            return metadata
    
    def _get_video_id(self, url: str) -> str:
        """Extract video ID from URL."""
        with yt_dlp.YoutubeDL() as ydl:
            info = ydl.extract_info(url, download=False)
            return info['id']


def main():
    if len(sys.argv) != 2:
        print("Usage: python download_video.py <youtube_url>")
        sys.exit(1)
        
    url = sys.argv[1]
    downloader = YouTubeDownloader()
    
    try:
        video_id, transcript, metadata = downloader.download_with_transcript(url)
        
        # Save transcript to file
        transcript_file = downloader.output_dir / f"{video_id}_transcript.txt"
        transcript_file.write_text(transcript, encoding='utf-8')
        
        print(f"Transcript saved to: {transcript_file}")
        
    except Exception as e:
        print(f"Error: {e}")
        sys.exit(1)


if __name__ == "__main__":
    main()