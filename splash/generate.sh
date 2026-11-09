#!/usr/bin/env bash
# Regenerate splash/art/*.txt from images: ./splash/generate.sh [source_dir]
# Each image is flattened onto black, trimmed to its content, fit into an 80x80 square,
# then rendered as braille (40x20 cells), so every art file has identical dimensions.
set -euo pipefail
src="${1:-$HOME/pictures/dots}"
out="$(dirname "$(readlink -f "$0")")/art"
mkdir -p "$out"
rm -f "$out"/*.txt
for img in "$src"/*.png; do
	name=$(basename "$img" .png | sed -E 's/^[^_]*_[0-9]+_//; s/[^A-Za-z0-9]+/_/g' | tr 'A-Z' 'a-z')
	magick "$img" -background black -alpha remove -alpha off -fuzz 15% -trim +repage \
		-bordercolor black -border 6 -colorspace Gray -filter Box -resize 80x80 \
		-gravity center -background black -extent 80x80 -threshold 30% png:- 2>/dev/null |
		chafa -f symbols -c none --symbols braille --size 40x20 --dither none - 2>/dev/null |
		sed 's/⠀/ /g' >"$out/$name.txt"
	echo "$name: $(wc -l <"$out/$name.txt") lines"
done
