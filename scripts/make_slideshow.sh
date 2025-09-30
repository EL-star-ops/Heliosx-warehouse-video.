#!/usr/bin/env bash
set -euo pipefail
mkdir -p build
# 5s per image; change 1/5 to 1/N for N seconds per image
ffmpeg -y -framerate 1/5 -pattern_type glob -i 'assets/images/*.*' \
  -c:v libx264 -r 30 -pix_fmt yuv420p build/warehouse_loop.mp4
cp build/warehouse_loop.mp4 assets/images/warehouse_loop.mp4 || true
echo "✔ Created assets/images/warehouse_loop.mp4"
