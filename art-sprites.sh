#!/usr/bin/env bash

# Rigorous error handling
set -eo pipefail

CACHE_DIR="$HOME/.cache/art_viewer"
# The target number of images to maintain in the cache.
INITIAL_MET_IMAGES=3  #No. of images from the METMuseum API to be maintained in the cache
INITIAL_AIC_IMAGES=2  #No. of images from the Art Institute of Chicago API to be maintained in the cache  

# --- Dependency Check ---
# Ensures required tools are installed before running.
# curl:  for API calling
# jq:  for handling JSON
# viu:  enables image-rendering in the terminal
check_deps() {
  local missing_deps=0
  for dep in curl jq viu; do
    if ! command -v "$dep" &> /dev/null; then
      echo "Error: Required command '$dep' is not installed."
      missing_deps=1
    fi
  done
  if [ "$missing_deps" -eq 1 ]; then
    echo "Please install the missing dependencies and try again."
    exit 1
  fi
}

# --- Single Image Fetching Functions ---

# Fetches one random painting from The Met.
fetch_one_met_image() {
  local obj_id
  obj_id=$(curl -s "https://collectionapi.metmuseum.org/public/collection/v1/search?hasImages=true&q=painting" | jq '.objectIDs | .[]' | shuf -n 1)
  
  # If we failed to get an ID, exit the function.
  if [[ -z "$obj_id" ]]; then
    return 1
  fi

  local art_data
  art_data=$(curl -s "https://collectionapi.metmuseum.org/public/collection/v1/objects/$obj_id")
  
  local image_url title artist
  image_url=$(echo "$art_data" | jq -r '.primaryImageSmall')
  title=$(echo "$art_data" | jq -r '.title')
  artist=$(echo "$art_data" | jq -r '.artistDisplayName')

  if [[ -n "$image_url" && "$image_url" != "null" ]]; then
    curl -sL "$image_url" -o "$CACHE_DIR/$obj_id.jpg"
    echo -e "Title: $title\nArtist: $artist\nSource: The Metropolitan Museum of Art" > "$CACHE_DIR/$obj_id.txt"
  fi
}

# Fetches one random painting from the Art Institute of Chicago (AIC).
fetch_one_aic_image() {
  local random_page art_data image_id
  # Retry loop in case we find an artwork without an image
  for ((i=0; i<5; i++)); do
    random_page=$(shuf -i 1-1000 -n 1)
    art_data=$(curl -s "https://api.artic.edu/api/v1/artworks?fields=id,title,artist_display,image_id&page=$random_page&limit=1")
    image_id=$(echo "$art_data" | jq -r '.data[0].image_id')
    if [[ -n "$image_id" && "$image_id" != "null" ]]; then
      break
    fi
    sleep 1 # Be polite and wait before retrying
  done

  # If the loop failed to find an image, abort this function.
  if [[ -z "$image_id" || "$image_id" == "null" ]]; then
    return 1
  fi
  
  local title artist art_id
  title=$(echo "$art_data" | jq -r '.data[0].title')
  artist=$(echo "$art_data" | jq -r '.data[0].artist_display' | sed 's/\n/ /g')
  art_id=$(echo "$art_data" | jq -r '.data[0].id')
  
  local image_url="https://www.artic.edu/iiif/2/$image_id/full/843,/0/default.jpg"
  curl -sL "$image_url" -o "$CACHE_DIR/$art_id.jpg"
  echo -e "Title: $title\nArtist: $artist\nSource: Art Institute of Chicago" > "$CACHE_DIR/$art_id.txt"
}


# --- Cache Management Functions ---

# This runs silently in the background to replace a viewed image.
replenish_cache_in_background() {
  if (( RANDOM % 2 == 0 )); then
    fetch_one_met_image
  else
    fetch_one_aic_image
  fi
}

# This runs synchronously (blocking) to fill the cache from scratch.
populate_initial_cache() {
  echo "Populating art cache for the first time. Please wait..."
  rm -f "$CACHE_DIR"/*
  
  echo "Fetching from The Met..."
  for ((i=1; i<=INITIAL_MET_IMAGES; i++)); do
    fetch_one_met_image &
  done
  
  echo "Fetching from Art Institute of Chicago..."
  for ((i=1; i<=INITIAL_AIC_IMAGES; i++)); do
    fetch_one_aic_image &
  done
  wait
  echo "Cache populated successfully."
}

# --- Main Display Logic ---

# Displays a random image, deletes it, and triggers a background replacement.
display_and_replace_art() {
  local all_images=("$CACHE_DIR"/*.jpg)
  if [ ${#all_images[@]} -eq 0 ] || [ ! -f "${all_images[0]}" ]; then
    echo "No images found in cache. Repopulating..."
    populate_initial_cache
    echo
  fi
  
  local random_image
  random_image=$(ls -1 "$CACHE_DIR"/*.jpg | shuf -n 1)
  local base_name
  base_name=$(basename "$random_image" .jpg)
  local metadata_file="$CACHE_DIR/$base_name.txt"

  clear
  viu -w 40 "$random_image"
  echo -e "${GREEN} ====================================================================== ${NC}"
  if [ -f "$metadata_file" ]; then
    cat "$metadata_file"
  fi
  echo -e "${GREEN} ====================================================================== ${NC}"

  rm -f "$random_image" "$metadata_file"
  (replenish_cache_in_background >/dev/null 2>&1) &
}


# --- Script Execution ---

check_deps
mkdir -p "$CACHE_DIR"

if [[ "$1" == "--update" ]]; then
  populate_initial_cache
  exit 0
fi

display_and_replace_art