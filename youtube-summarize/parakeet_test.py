#!/usr/bin/env python3
"""
Test script for Parakeet-MLX transcription.
"""
import sys
from parakeet_mlx import from_pretrained

if len(sys.argv) != 2:
    print("Usage: python parakeet_test.py <audio_file>")
    sys.exit(1)

audio_file = sys.argv[1]

model = from_pretrained("mlx-community/parakeet-tdt-0.6b-v3")

result = model.transcribe(audio_file)

print(result.text)
