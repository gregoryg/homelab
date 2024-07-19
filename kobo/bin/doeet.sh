#!/bin/sh

# echo $0
dir=$(dirname $(readlink -f "$0"))
# echo $dir
keyfile="$dir/openai-temp.key"

if [ -r "$keyfile" ]; then
  keyval=$(cat "$keyfile" | base64 -d)
  echo $keyval
else
  echo "ERROR: No keyfile found for the API"
  # exit 1
fi
