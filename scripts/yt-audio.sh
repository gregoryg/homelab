#!/usr/bin/env bash
vid="$1"

# Warning - files will be saved in $PWD
echo "Downloading audio..."
audiopath=$(
    yt-dlp --write-thumbnail \
           --convert-thumbnails png \
           --check-formats \
           -f 'bestaudio' \
           --extract-audio \
           --audio-format mp3 \
           --no-mtime \
           --write-description \
           --write-info-json \
           --restrict-filenames \
           --trim-filenames 180 \
           --print after_move:filepath \
           "${vid}" \
           -o ~/YouTube/'%(channel)s'/'%(title)s'/'%(title)s.%(ext)s'
         )
audiodir=$(dirname "${audiopath}")
echo "Audio extraction of ${vid} at ${audiopath}"

# exit 0
# ## The OpenAI API way
# if [ -z "${OPENAI_API_KEY}" ] ; then
#     echo "OPENAI_API_KEY is not set - will not attempt extract text."
#     exit 0
# fi

# curl https://api.openai.com/v1/audio/transcriptions \
#      -H "Authorization: Bearer $OPENAI_API_KEY" \
#      -H "Content-Type: multipart/form-data" \
#      -F file="@${audiopath}" \
#      -F model="whisper-1" >  extracted-text-from-video.txt

# echo "Wrote text transcript to extracted-text-from-video.txt"

## The locally-hosted whisper model way
## models: tiny[.en], base[.en], small[.en], medium[.en], large
WHISPER_MODEL=large-v3
# WHISPER_MODEL=medium.en
SSH_HOST=aziriphale # null for hosted on current machine
SSH_USER=gregj

WHISPER_CMD=
if [ -n "${SSH_HOST}" ] ; then
    # use rsync to create new directories on target system
    rsync -av "${audiopath}" "${SSH_USER}@${SSH_HOST}":"${audiodir}/"
    WHISPER_CMD="ssh ${SSH_USER}@${SSH_HOST} "
fi
WHISPER_CMD="${WHISPER_CMD} /home/gregj/.local/bin/whisper --task transcribe --model ${WHISPER_MODEL} --word_timestamps True --output_format all --output_dir ${audiodir} ${audiopath}"
echo ${WHISPER_CMD}
${WHISPER_CMD}

# Copy the transcript to local path (if whisper is on remote host)
if [ -n "${SSH_HOST}" ] ; then
    scp "${SSH_USER}@${SSH_HOST}":"${audiodir}/"'*.txt' $(dirname ${audiopath})
fi



# yt-dlp \
#     -f 'bestaudio' \
#     --write-thumbnail \
#     --convert-thumbnails png \
#     --check-formats \
#     --no-mtime \
#     --write-description \
#     --write-info-json \
#     --restrict-filenames \
#     --extract-audio \
#     --audio-format mp3 \
#     'https://www.youtube.com/watch?v=eoFlbna9-cY' \
#     -o '%(title)s/%(title)s.%(ext)s'  \
#     --print after_move:filepath \
#     --split-chapters \
#     --write-info-json \
#     -o "chapter:%(title)s/[%(section_number)02d] - %(section_title)s.%(ext)s"
