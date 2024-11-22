#!/usr/bin/env bash
set -euo pipefail

json_file=$(ls *.info.json|head -1)
# epub=$(ls *txt|head -1)
epub=$(ls *epub|head -1)
if [[ ! -a  "${epub}" ]] ; then
   echo "Cannot find an epub file in this directory."
   exit 1
fi
convert $(ls *png|head -1) -gravity center -extent 3:4 /tmp/cropped-cover-3-4.png

newid=$(calibredb add \
                  --authors "$(jq -r '.channel' ${json_file})" \
                  --cover /tmp/cropped-cover-3-4.png \
                  --languages "$(jq -r '.language' ${json_file})" \
                  --series YouTube \
                  --title "$(jq -r '.title' ${json_file})" \
                  "${epub}" \
                  | grep 'Added book ids:' | cut -d ':' -f2 | tr -d ' ')
echo "New book was added with id ${newid}"

calibredb set_metadata \
          --field comments:"$(cat *.description)" \
          --field tags:"$(jq -r '.tags' ${json_file} | jq @csv|sed 's,\\",,g' | tr -d '"')" \
          ${newid}
