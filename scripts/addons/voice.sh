#!/usr/bin/env bash
set -euo pipefail

echo "==> Setting up voice and TTS capabilities..."

# Edge TTS is already configured in config.yaml (provider: edge)
# This is free and built into macOS

# Install edge-tts Python package for CLI usage
if python3 -c "import edge_tts" 2>/dev/null; then
  echo "  ✓ edge-tts already installed"
else
  echo "  Installing edge-tts..."
  python3 -m pip install edge-tts --break-system-packages -q 2>/dev/null || \
    python3 -m pip install edge-tts -q
fi

# Create a convenient TTS script
mkdir -p "$HOME/.hermes/bin"

cat > "$HOME/.hermes/bin/hermes-speak" << 'TTSEOF'
#!/usr/bin/env python3
"""Text-to-speech using Edge TTS (free, no API key).

Usage:
  hermes-speak "Hello world"
  hermes-speak "Hello" --voice en-US-JennyNeural --rate +20%
  hermes-speak "Hello" --output hello.mp3
"""

import argparse
import sys
import asyncio

async def main():
    parser = argparse.ArgumentParser(description="Free TTS via Edge")
    parser.add_argument("text", help="Text to speak")
    parser.add_argument("--voice", default="en-US-JennyNeural",
                        help="Voice (see: edge-tts --list-voices)")
    parser.add_argument("--rate", default="+0%", help="Speaking rate")
    parser.add_argument("--output", help="Output file (default: play directly)")
    args = parser.parse_args()

    try:
        import edge_tts
    except ImportError:
        print("edge-tts not installed. Run: pip install edge-tts")
        sys.exit(1)

    communicate = edge_tts.Communicate(args.text, args.voice, rate=args.rate)

    if args.output:
        await communicate.save(args.output)
        print(f"  ✓ Saved to {args.output}")
    else:
        # Play directly using macOS afplay
        import tempfile
        import subprocess
        with tempfile.NamedTemporaryFile(suffix=".mp3", delete=False) as f:
            tmp = f.name
        await communicate.save(tmp)
        subprocess.run(["afplay", tmp])
        import os
        os.unlink(tmp)

if __name__ == "__main__":
    asyncio.run(main())
TTSEOF

chmod +x "$HOME/.hermes/bin/hermes-speak"
echo "  ✓ Created ~/.hermes/bin/hermes-speak"

# Voice transcription (STT) - local whisper
if python3 -c "import whisper" 2>/dev/null; then
  echo "  ✓ whisper already installed"
else
  echo "  Note: For local speech-to-text, install: pip install openai-whisper"
  echo "  Or use Hermes' built-in local STT (already configured in config.yaml)"
fi

echo "==> Voice setup complete. Say 'hermes-speak \"hello\"' to test."
