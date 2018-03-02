#!/usr/bin/env bash
#
## blame(ken)
#

set -eu

[[ ! -z $(which ffmpeg) ]] || {
  sudo apt-get -qy install \
    ffmpeg
}

DURATION=$(ffprobe -i audio.* \
                   -show_entries format=duration \
                   -sexagesimal \
                   -v quiet \
                   -of csv="p=0")

[[ ! -z ${DURATION:+x} ]] || {
  echo "ERROR: no audio duration detected"
  exit 1
}

MAXTIME=$(date -d "00:00:59" +%s)
[[ $MAXTIME -lt $(date -d "$DURATION" +%s) ]] && DURATION="00:00:59"

#for IMG in image.*;do convert -resize 128x128 $PNG ${PNG};done

# clobber any existing output file without asking
# there must be exactly one image file named like image.* (or you'll get a
#   mashup)
# there must be exactly one audio file named like audio.*
# the output video is always truncated at 60s and optimized for instagram video
#   spec
ffmpeg -hide_banner \
       -y \
       -pattern_type glob \
       -loop 1 \
       -fflags +genpts \
       -i image.* \
       -i audio.* \
       -t $DURATION \
       -c:a aac \
       -c:v libx264 \
       -pix_fmt yuv420p \
       -vf "scale=trunc(iw/2)*2:trunc(ih/2)*2" \
       audiogram.mp4
