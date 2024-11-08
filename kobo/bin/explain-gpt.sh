#!/bin/sh
scriptdir=$(dirname $(readlink -f "$0"))
phrase="$1"
# timestamp in org mode format
timestamp=$(LANG=en_US date +'<%F %a %R>')
json_phrase=$(printf '<phrase>%s</phrase>' "${phrase}" | jq -R .)
model=gpt-4o
# model=gpt-3.5-turbo
# echo "|${json_phrase}|"
# exit 0
OPENAI_API_KEY=$("$scriptdir/doeet.sh")
# exit 0
curl -s  https://api.openai.com/v1/chat/completions \
     -H "Authorization: Bearer ${OPENAI_API_KEY}" \
     -H "Content-Type: application/json" \
     -d '{
           "model": "'${model}'",
           "messages": [{"role": "system", "content": "explain this phrase, give examples of its use if appropriate, historical context if appropriate.  Reply only in the language of the phrase."},
                        {"role": "user", "content": '"${json_phrase}"'}],
           "temperature": 0.7}'|jq -r '.choices[0].message.content' | tee ${scriptdir}/latest-explain-reply.txt

# Record this phrase+explanation to a Markdown document
# Kobo can't display this, but Calibre can convert it to RTF simply enough
explaindocpath="/mnt/onboard/GPTChat/Explain.md"
echo "## ${timestamp}" >> ${explaindocpath}
echo ${phrase} >> ${explaindocpath}
echo "### ${model}" >> ${explaindocpath}
echo $(cat ${scriptdir}/latest-explain-reply.txt) >> ${explaindocpath}
