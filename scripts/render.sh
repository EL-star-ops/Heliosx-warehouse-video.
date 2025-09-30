#!/usr/bin/env bash
set -euo pipefail

BG="${1:-assets/images/warehouse_loop.mp4}"
VO="assets/audio/VO_HeliosX.mp3"
MUSIC="assets/music/bed.mp3"
SRT="captions/HeliosX_Logistics_Final_EN.srt"
OUT="build/heliosx_warehouse.mp4"

mkdir -p build

if [ ! -f "$VO" ]; then
  echo "❌ Missing voiceover: $VO"
  exit 1
fi

# Mix VO + optional music
if [ -f "$MUSIC" ]; then
  ffmpeg -y -i "$VO" -i "$MUSIC" -filter_complex "[1:a]volume=0.25[a2];[0:a][a2]amix=inputs=2:duration=first:dropout_transition=2,volume=1.0[aout]" -map "[aout]" -c:a aac -b:a 192k build/audio_mix.m4a
else
  ffmpeg -y -i "$VO" -c:a aac -b:a 192k build/audio_mix.m4a
fi

FONT_LINUX="/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf"
if [ -f "$SRT" ]; then
  SUB="subtitles=${SRT},"
else
  SUB=""
fi

if [ ! -f "$FONT_LINUX" ]; then
  FONT_OPT="fontcolor=white"
else
  FONT_OPT="fontfile=${FONT_LINUX}:fontcolor=white"
fi

VF="${SUB}"
VF="${VF}drawbox=x=40:y=40:w=260:h=64:color=0x1e3a8a@0.85:t=fill,"
VF="${VF}drawtext=${FONT_OPT}:text='HeliosX Logistics Hub':x=60:y=60:fontsize=28,"
VF="${VF}drawbox=x=w-420:y=40:w=380:h=50:color=0xf97316@0.85:t=fill,"
VF="${VF}drawtext=${FONT_OPT}:text='Pharma Fulfilment':x=w-400:y=58:fontsize=24,"

VF="${VF}drawbox=enable='between(t,20,25)':x=w-360:y=100:h=48:w=320:color=red@0.82:t=fill,"
VF="${VF}drawtext=enable='between(t,20,25)':${FONT_OPT}:text='Royal Mail Elevated Ramp':x=w-340:y=112:fontsize=22,"

VF="${VF}drawbox=enable='between(t,40,50)':x=40:y=h-140:w=540:h=80:color=0x16a34a@0.88:t=fill,"
VF="${VF}drawtext=enable='between(t,40,50)':${FONT_OPT}:text='Dermatica — packaging line':x=60:y=h-110:fontsize=30,"

VF="${VF}drawbox=enable='between(t,50,60)':x=40:y=h-140:w=580:h=80:color=0x2563eb@0.88:t=fill,"
VF="${VF}drawtext=enable='between(t,50,60)':${FONT_OPT}:text='MedExpress — packaging line':x=60:y=h-110:fontsize=30,"

VF="${VF}drawbox=enable='between(t,60,70)':x=40:y=h-140:w=560:h=80:color=0x1d4ed8@0.88:t=fill,"
VF="${VF}drawtext=enable='between(t,60,70)':${FONT_OPT}:text='ZipHealth — digital health line':x=60:y=h-110:fontsize=30"

ffmpeg -y -i "$BG" -i build/audio_mix.m4a -vf "$VF" -c:v libx264 -preset medium -crf 18 -pix_fmt yuv420p -map 0:v -map 1:a -shortest "$OUT"

echo "✔ Rendered $OUT"
