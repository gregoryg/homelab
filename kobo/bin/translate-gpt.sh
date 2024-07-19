#!/bin/sh
scriptdir=$(dirname $(readlink -f "$0"))
phrase="$1"
json_phrase=$(printf '%s' "${phrase}" | jq -R .)
# model=gpt-4o
model=gpt-3.5-turbo
# echo "|${json_phrase}|"
OPENAI_API_KEY=$("$scriptdir/doeet.sh")
# exit 0
curl -s https://api.openai.com/v1/chat/completions \
     -H "Authorization: Bearer ${OPENAI_API_KEY}" \
     -H "Content-Type: application/json" \
     -d '{
           "model": "gpt-3.5-turbo",
           "messages": [{"role": "system", "content": "Translate to English"},
                        {"role": "user", "content": '"${json_phrase}"'}],
           "max_tokens": 400,
           "temperature": 0.7}'|jq -r '.choices[0].message.content'
