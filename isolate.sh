#! /usr/bin/env bash
set -euo pipefail

SRC='/mnt/d/Users/ryan/Media/Wesley Willis/Albums'
DEST='/mnt/d/Users/ryan/Media/Wesley Willis/Isolated Vocals'

function isolate() {
  local _in="$1"
  local _out="$2"
  local _inDir=$(dirname "$_in")
  local _fileName=$(basename "$_in")
  if [ -d "$_out" ]; then
    echo "Already Processed $_out"
    return
  fi
  mkdir -p "$_out"
  echo "Processing $_in"
  docker run --gpus all -v "$_out":/output -v"$_inDir":/input deezer/spleeter-gpu:3.8-2stems separate -o /output input/"$_fileName"
}

mapfile -t albums < <(find "$SRC" -maxdepth 1 -mindepth 1 -type d )
for d in "${albums[@]}"; do
  dir=$(basename -- "$d")
  mapfile -t tracks < <(find "$d" -type f -name "*.mp3")
  for t in "${tracks[@]}"; do
    echo "$t"
    file=$(basename -- "$t")
    sanitized=$(echo "${dir}_${file}" | sed -e 's/[^A-Za-z0-9._-]/_/g')
    sanitized="${sanitized%.*}"
    out="$DEST/$sanitized"
    isolate "$t" "$out"
  done
  mapfile -t tracks < <(find "$d" -type f -name "*.wma")
  for t in "${tracks[@]}"; do
    echo "$t"
    file=$(basename -- "$t")
    sanitized=$(echo "${dir}_${file}" | sed -e 's/[^A-Za-z0-9._-]/_/g')
    sanitized="${sanitized%.*}"
    out="$DEST/$sanitized"
    isolate "$t" "$out"
  done
done
