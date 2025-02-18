#!/bin/sh
scriptdir=$(dirname $(readlink -f "$0"))
phrase="$1"
json_phrase=$(printf '<phrase>%s</phrase>' "${phrase}" | jq -R .)
model=gpt-4o-mini
# model=gpt-3.5-turbo
# echo "|${json_phrase}|"
# exit 0
OPENAI_API_KEY=$("$scriptdir/doeet.sh")
# exit 0
curl -s  https://api.openai.com/v1/chat/completions \
     -H "Authorization: Bearer ${OPENAI_API_KEY}" \
     -H "Content-Type: application/json" \
     -d '{
           "model": "gpt-4o",
           "messages": [{"role": "system", "content": "Give a definition of the word or phrase.\nWhen the word or phrase is unusual or has multiple uses, or is something used in colloquial speech,give examples with terse explanations.\n\nReply only in the language of the word or phrase."},
                        {"role": "user", "content": '"${json_phrase}"'}],
           "temperature": 0.7}'|jq -r '.choices[0].message.content'  | tee ${scriptdir}/latest-fancy-define.txt
