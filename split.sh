#! /usr/bin/env bash
set -euo pipefail

SRC='/mnt/d/Users/ryan/Media/Wesley Willis/Isolated Vocals'
DEST='/mnt/d/Users/ryan/Media/Wesley Willis/trainingdata'
declare -a categories=(verse chorus outro)

function split() {
  local _in="$1"
  local _out="$2"
  mkdir -p "$_out"
  echo "splitting $_in"
  sox "$_in" "$_out/seg.wav" silence 1 0.15 1% 1 0.15 1% : newfile : restart
}

function playAndSelect() {
  local _inDir="$1"
  local -a _segments
  mapfile -t _segments < <(find "$_inDir" -type f -name "*.wav")
  for _s in "${_segments[@]}"; do
    local _playTask
    local _segName
    _segName=$(basename "$_s")
    echo "Playing $_segName. Select [1] verse [2] chorus [3] outro [4] discard:"
    paplay "$_s" &
    _playTask=$!
    read -rsn1 _resp
    case "$_resp" in 
      1)
        echo "verse"
        mkdir -p "$_inDir/verse"
        kill $_playTask || true
	mv "$_s" "$_inDir/verse/$_segName"
	;;
      2)
        echo "chorus"
        mkdir -p "$_inDir/chorus"
        kill $_playTask || true
	mv "$_s" "$_inDir/chorus/$_segName"
	;;
      3)
        echo "outro"
        mkdir -p "$_inDir/outro"
        kill $_playTask || true
	mv "$_s" "$_inDir/outro/$_segName"
	;;
      4)
        echo "discard"
        kill $_playTask || true
	rm "$_s"
	;;
      *)
        echo "Unknown response $_resp. Aborting..."
        kill $_playTask || true
	exit 1
	;;
    esac
  done
}

mapfile -t vocals < <(find "$SRC" -type f -name "vocals.wav")
for v in "${vocals[@]}"; do
  dir=$(dirname "$(dirname -- "$v")")
  songDir=$(basename "$dir")
  outDir="$DEST/$songDir"
  if [ -d "$outDir" ]; then
    echo "$outDir already processed..."
    continue
  fi
  split "$v" "$outDir"
  playAndSelect "$outDir"
done
