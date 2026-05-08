#!/usr/bin/env bash
set -euo pipefail

echo "==> Setting up local image generation on Apple Silicon..."

# Check MLX availability
if python3 -c "import mlx.core" 2>/dev/null; then
  echo "  ✓ MLX available"
else
  echo "  Installing MLX..."
  python3 -m pip install mlx mlx-lm --break-system-packages -q 2>/dev/null || \
    python3 -m pip install mlx mlx-lm -q
fi

# Create image generation script
mkdir -p "$HOME/.hermes/bin"

cat > "$HOME/.hermes/bin/hermes-image-gen" << 'PYEOF'
#!/usr/bin/env python3
"""Local image generation on Apple Silicon via MLX.

Usage:
  hermes-image-gen "a cute cat" output.png
  hermes-image-gen "landscape" output.png --steps 30 --cfg 7.5
"""

import argparse
import sys
import os

def main():
    parser = argparse.ArgumentParser(description="Generate images locally on Apple Silicon")
    parser.add_argument("prompt", help="Text prompt")
    parser.add_argument("output", nargs="?", default="output.png", help="Output file")
    parser.add_argument("--steps", type=int, default=20)
    parser.add_argument("--cfg", type=float, default=7.5)
    parser.add_argument("--size", default="512x512")
    args = parser.parse_args()

    print(f"Generating: '{args.prompt}' -> {args.output}")

    try:
        import mlx.core as mx
        print(f"  MLX device: {mx.default_device()}")
    except ImportError:
        print("  MLX not available. Install: pip install mlx mlx-lm")
        print("  Falling back: suggest using FAL.ai free tier or ComfyUI")
        sys.exit(1)

    try:
        from diffusers import StableDiffusionPipeline
        import torch
        print("  Using diffusers + Metal Performance Shaders...")
        pipe = StableDiffusionPipeline.from_pretrained("runwayml/stable-diffusion-v1-5")
        pipe = pipe.to("mps")
        image = pipe(args.prompt, num_inference_steps=args.steps).images[0]
        image.save(args.output)
        print(f"  ✓ Saved to {args.output}")
    except ImportError:
        print("  diffusers not installed. Install: pip install diffusers transformers")
        # Fallback: inform about available alternatives
        print("")
        print("  Alternative free options for image gen on Mac:")
        print("  1. ComfyUI (local, powerful): brew install --cask comfyui")
        print("  2. Draw Things App (GUI): https://drawthings.ai")
        print("  3. FAL.ai free credits: sign up at https://fal.ai")
        sys.exit(1)

if __name__ == "__main__":
    main()
PYEOF

chmod +x "$HOME/.hermes/bin/hermes-image-gen"
echo "  ✓ Created ~/.hermes/bin/hermes-image-gen"

# Enable image_gen toolset if FAL key exists, otherwise offer guidance
if grep -q "FAL_KEY" "$HOME/.hermes/.env" 2>/dev/null && ! grep -q "^#.*FAL_KEY" "$HOME/.hermes/.env" 2>/dev/null; then
  echo "  ✓ FAL_KEY found — image_gen toolset is ready"
else
  echo ""
  echo "  For cloud-based image gen (free tier):"
  echo "    1. Sign up at https://fal.ai (free credits on signup)"
  echo "    2. Add to ~/.hermes/.env: FAL_KEY=your_key"
  echo "    3. Run: hermes tools (enable image_gen toolset)"
  echo ""
  echo "  For local image gen:"
  echo "    Install ComfyUI: brew install --cask comfyui"
  echo "    Or use: python3 ~/.hermes/bin/hermes-image-gen 'prompt' output.png"
fi

echo "==> Image generation setup complete."
