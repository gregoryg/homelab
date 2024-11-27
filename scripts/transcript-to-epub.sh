#!/usr/bin/env bash
# Org Mode to EPUB using pandoc
# Org Mode file should have a #+title tag, though it's not required
set -euo pipefail

json_file=$(ls *.info.json|head -1)
# transcript_file=$(ls *txt|head -1)
transcript_file=$(ls *org|head -1)
if [[ ! -a  "${transcript_file}" ]] ; then
   echo "Cannot find an org mode transcript file in this directory."
   exit 1
fi

pandoc -f org -t gfm ${transcript_file} > /tmp/mytranscript.md
# TODO: handle lack of thumbnail image
convert $(ls *png|head -1) -gravity center -extent 3:4 /tmp/cropped-cover-3-4.png
# generate YAML file with epub-relevant info for pandoc
echo "---
title:
  - type: main
    text: "'"'$(jq -r '.title' "${json_file}")'"' "
creator:
  - role: author
    text: $(jq -r '.channel' "${json_file}")
publisher: YouTube
date: $(jq -r '.upload_date' "${json_file}")
lang: $(jq -r '.language' "${json_file}")
belongs-to-collection: YouTube
" > metadata.yaml
# description: $(jq -r '.description' "${json_file}")


pandoc -f org -t epub \
       --split-level=1 \
       --epub-cover-image=/tmp/cropped-cover-3-4.png \
       --epub-metadata=metadata.yaml \
       > $(echo "$(basename ${transcript_file})" | sed 's,\.org$,.epub,' ) "${transcript_file}"
echo "wrote epub!"
exit 0
