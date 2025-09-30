New-Item -ItemType Directory -Force -Path build | Out-Null
ffmpeg -y -framerate 1/5 -pattern_type glob -i "assets/images/*.*" -c:v libx264 -r 30 -pix_fmt yuv420p build\warehouse_loop.mp4
Copy-Item build\warehouse_loop.mp4 assets\images\warehouse_loop.mp4 -Force
Write-Host "✔ Created assets/images/warehouse_loop.mp4"
