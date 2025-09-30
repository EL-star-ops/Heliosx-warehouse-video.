param([string]$BgVideo = "assets/images/warehouse_loop.mp4")
$ErrorActionPreference = "Stop"
$VO    = "assets/audio/VO_HeliosX.mp3"
$MUSIC = "assets/music/bed.mp3"
$SRT   = "captions/HeliosX_Logistics_Final_EN.srt"
$OUT   = "build\heliosx_warehouse.mp4"

New-Item -ItemType Directory -Force -Path build | Out-Null
if (!(Test-Path $VO)) { throw "Missing voiceover: $VO" }

if (Test-Path $MUSIC) {
  ffmpeg -y -i "$VO" -i "$MUSIC" -filter_complex "[1:a]volume=0.25[a2];[0:a][a2]amix=inputs=2:duration=first:dropout_transition=2,volume=1.0[aout]" -map "[aout]" -c:a aac -b:a 192k build\audio_mix.m4a
} else {
  ffmpeg -y -i "$VO" -c:a aac -b:a 192k build\audio_mix.m4a
}

$FONT = "C:\Windows\Fonts\arial.ttf"
$SUB = (Test-Path $SRT) ? "subtitles=$SRT," : ""

$VF  = $SUB
$VF += "drawbox=x=40:y=40:w=260:h=64:color=0x1e3a8a@0.85:t=fill,"
$VF += "drawtext=fontfile=${FONT}:fontcolor=white:text='HeliosX Logistics Hub':x=60:y=60:fontsize=28,"
$VF += "drawbox=x=w-420:y=40:w=380:h=50:color=0xf97316@0.85:t=fill,"
$VF += "drawtext=fontfile=${FONT}:fontcolor=white:text='Pharma Fulfilment':x=w-400:y=58:fontsize=24,"

$VF += "drawbox=enable='between(t,20,25)':x=w-360:y=100:h=48:w=320:color=red@0.82:t=fill,"
$VF += "drawtext=enable='between(t,20,25)':fontfile=${FONT}:fontcolor=white:text='Royal Mail Elevated Ramp':x=w-340:y=112:fontsize=22,"

$VF += "drawbox=enable='between(t,40,50)':x=40:y=h-140:w=540:h=80:color=0x16a34a@0.88:t=fill,"
$VF += "drawtext=enable='between(t,40,50)':fontfile=${FONT}:fontcolor=white:text='Dermatica — packaging line':x=60:y=h-110:fontsize=30,"

$VF += "drawbox=enable='between(t,50,60)':x=40:y=h-140:w=580:h=80:color=0x2563eb@0.88:t=fill,"
$VF += "drawtext=enable='between(t,50,60)':fontfile=${FONT}:fontcolor=white:text='MedExpress — packaging line':x=60:y=h-110:fontsize=30,"

$VF += "drawbox=enable='between(t,60,70)':x=40:y=h-140:w=560:h=80:color=0x1d4ed8@0.88:t=fill,"
$VF += "drawtext=enable='between(t,60,70)':fontfile=${FONT}:fontcolor=white:text='ZipHealth — digital health line':x=60:y=h-110:fontsize=30"

ffmpeg -y -i "$BgVideo" -i build\audio_mix.m4a -vf "$VF" -c:v libx264 -preset medium -crf 18 -pix_fmt yuv420p -map 0:v -map 1:a -shortest "$OUT"
Write-Host "✔ Rendered $OUT"
