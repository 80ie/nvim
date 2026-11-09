#!/usr/bin/env bash
# ./splash/generate.sh [source_dir]
# With source_dir: clean its PNGs into splash/img (flatten on black, trim, fit 640x640).
# Always: render splash/img into splash/art as 40x20 braille text.
set -euo pipefail
here="$(dirname "$(readlink -f "$0")")"
img="$here/img" art="$here/art"
mkdir -p "$img" "$art"
slug() { basename "$1" .png | sed -E 's/^[^_]*_[0-9]+_//; s/[^A-Za-z0-9]+/_/g' | tr 'A-Z' 'a-z'; }

if [ $# -ge 1 ]; then
	for f in "$1"/*.png; do
		magick "$f" -background black -alpha remove -alpha off -fuzz 15% -trim +repage \
			-bordercolor black -border 6 -colorspace Gray -resize 640x640 \
			-gravity center -background black -extent 640x640 -strip "$img/$(slug "$f").png" 2>/dev/null
	done
fi

rm -f "$art"/*.txt
for f in "$img"/*.png; do
	n=$(basename "$f" .png)
	magick "$f" -filter Box -resize 80x80 -threshold 30% png:- 2>/dev/null |
		chafa -f symbols -c none --symbols braille --size 40x20 --dither none - 2>/dev/null |
		sed 's/⠀/ /g' >"$art/$n.txt"
	echo "$n: $(wc -l <"$art/$n.txt") lines"
done
