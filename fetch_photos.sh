#!/bin/bash
# Fetch WikiTree profile photos and save locally
# Maps ahnentafel number -> WikiTree ID for profiles with known images

PHOTO_DIR="/Users/edwardblake/Documents/Personal/family_history/photos"
BASE="https://www.wikitree.com"
mkdir -p "$PHOTO_DIR"

declare -A PROFILES
# From GEDCOM OBJE records - only profiles that have images
PROFILES[6]="Dower-348"       # Jim Dower
PROFILES[7]="Hurn-212"        # Tink Hurn
PROFILES[4]="Blake-13353"     # Thomas Blake
PROFILES[5]="Penning-246"     # Louise Penning
PROFILES[8]="Blake-13354"     # Charles Blake
PROFILES[9]="Foy-1459"        # Mary Foy
PROFILES[10]="Penning-247"    # Frank Penning
PROFILES[11]="Hermsdorf-2"    # Gertrude Hermsdorf
PROFILES[13]="Kane-4876"      # Idella Kane
PROFILES[22]="Hermsdorf-3"    # Frederick Hermsdorf
PROFILES[23]="Grossmann-339"  # Auguste Marie Grossmann
PROFILES[26]="Kane-4877"      # John J Kane
PROFILES[12]="Foy-1466"       # Patrick Foy (has comment image)

for A in "${!PROFILES[@]}"; do
  WIKI_ID="${PROFILES[$A]}"
  OUTFILE="$PHOTO_DIR/${A}.jpg"

  if [ -f "$OUTFILE" ]; then
    echo "[$A] $WIKI_ID - already exists, skipping"
    continue
  fi

  echo -n "[$A] $WIKI_ID - fetching... "

  # Get the image page and extract the actual photo URL
  IMG_PATH=$(curl -s "${BASE}/photo/jpg/${WIKI_ID}" 2>/dev/null | grep -o 'src="/photo\.php/[^"]*"' | head -1 | sed 's/src="//;s/"//')

  if [ -z "$IMG_PATH" ]; then
    echo "no image found"
    continue
  fi

  # Download the image
  curl -s "${BASE}${IMG_PATH}" -o "$OUTFILE" 2>/dev/null

  if [ -f "$OUTFILE" ] && [ -s "$OUTFILE" ]; then
    SIZE=$(wc -c < "$OUTFILE" | tr -d ' ')
    echo "OK (${SIZE} bytes)"
  else
    echo "download failed"
    rm -f "$OUTFILE"
  fi

  sleep 0.5
done

echo ""
echo "Done! Photos saved to $PHOTO_DIR"
ls -la "$PHOTO_DIR"/*.jpg 2>/dev/null
