#!/usr/bin/env bash

json_file=$(ls *.info.json|head -1)
transcript_file=$(ls *txt|head -1)

jq -r '. | { "title": .title, "url": .webpage_url, "channel": .channel, "upload_date": .upload_date, "thumbnail": .thumbnail, "tags": .tags}' \
   "${json_file}" > short_meta.json

newid=$(calibredb add \
                  --authors "$(jq -r '.channel' short_meta.json)" \
                  --cover $(ls *png|head -1) \
                  --languages $(jq -r '.language' short_meta.json) \
                  --series YouTube \
                  --title "$(jq -r '.title' short_meta.json)" \
                  --tags "$(jq -r '.tags' short_meta.json)" \
                  "${transcript_file}" \
                  | grep 'Added book ids:' | cut -d ':' -f2 | tr -d ' ')
echo "New book was added with id ${newid}"

calibredb set_metadata \
          --field comments:"$(cat *.description)" \
          --field tags:"$(jq -r '.tags' short_meta.json | jq @csv|sed 's,\\",,g' | tr -d '"')" \
          ${newid}
