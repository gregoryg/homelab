#!/home/gregj/.local/python-venvs/ytaudio/bin/python3
# Python code
#      This started from a gpt-4o session asking to transform all functionality from the bash script into python
#      + TODO: trim trailing whitespace from formatted transcript

# [[file:../README.org::*Python code][Python code:1]]
import os
import subprocess
import json
import argparse
from configparser import ConfigParser

# TODO: add exception handling and logging overall (replace print with logging)
# TODO: check for non-zero exit status for all SSH and RSYNC
# TODO: check for non-zero exit status for shell command
def clean_whitespace(text):
    # Split the text into individual lines
    lines = text.splitlines()
    # Strip trailing whitespace from each line
    stripped_lines = [line.rstrip() for line in lines]
    # Rejoin the lines
    return '\n'.join(stripped_lines)

def run_command(command):
    process = subprocess.Popen(command, stdout=subprocess.PIPE, stderr=subprocess.PIPE, shell=True)
    output, error = process.communicate()
    return output.decode('utf-8'), error.decode('utf-8')

def transcribe_audio_file(audio_path, ssh_host, ssh_user, whisper_model):
    print(f"Transcribing {audio_path}")
    # make the "skeleton" of the whisper command to do the transcription
    transcribe_command = f"/home/{ssh_user}/.local/bin/whisper --task transcribe --model {whisper_model} --word_timestamps True --output_format all --output_dir /tmp/transcribedir"
    if ssh_host:
        command = f"rsync -av {audio_path} {ssh_user}@{ssh_host}:/tmp/transcribedir/"
        print(f"running rsync command: {command}")
        run_command(command)
        transcribe_command = f"ssh {ssh_user}@{ssh_host} " + transcribe_command + f" /tmp/transcribedir/{os.path.basename(audio_path)}"
        print(f"DEBUG: whisper command is '{transcribe_command}'")
        output, error = run_command(transcribe_command)
        print(output)
        print(error)
        # command = f"ssh {ssh_user}@{ssh_host} /home/{ssh_user}/.local/bin/whisper --task transcribe --model {whisper_model} --word_timestamps True --output_format all --output_dir /tmp/transcribedir /tmp/transcribedir/{os.path.basename(audio_path)}"
    else:
        transcribe_command = transcribe_command + f" {audio_path}"
        print(f"DEBUG: whisper command is '{transcribe_command}'")
        output, error = run_command(transcribe_command)
        print(output)
        print(error)

def format_transcript(transcript_path, ssh_host, ssh_user):
    command = f"ssh {ssh_user}@{ssh_host} ~/.local/python-venvs/wtpsplit/bin/python ~/gort.py {transcript_path}"
    output, error = run_command(command)
    return clean_whitespace(output)

def main(video_url, whisper_model, ssh_host, ssh_user):
    command = f"""
    yt-dlp -f 'bestaudio' \
    --write-thumbnail \
    --convert-thumbnails png \
    --embed-metadata \
    --check-formats \
    --no-mtime \
    --write-description \
    --write-info-json \
    --restrict-filenames \
    --extract-audio --audio-format mp3 '{video_url}' \
    --paths home:~/YouTube/  \
    -o '%(channel)s/%(title)s/%(title)s.%(ext)s' \
    --print after_move:filepath \
    --split-chapters \
    -o 'chapter:%(channel)s/%(title)s/[%(section_number)02d]-%(section_title)s.%(ext)s'"""
    output, error = run_command(command)
    audio_path = output.strip()
    print(f"Audio path: {audio_path}")

    info_file = next(f for f in os.listdir(os.path.dirname(audio_path)) if f.endswith('.info.json'))
    with open(os.path.join(os.path.dirname(audio_path), info_file), 'r') as f:
        video_info = json.load(f)

    num_chapters = len(video_info.get('chapters', []))
    video_title = video_info.get('title', 'Video')  # Use 'Video' as a fallback
    finaldoc_path = os.path.join(os.path.dirname(audio_path), os.path.basename(audio_path).removesuffix('.mp3') + '.org')

    if num_chapters == 0:
        print("No chapters found in the video")
        transcribe_audio_file(audio_path, ssh_host, ssh_user, whisper_model)
        transcript_path = os.path.join('/tmp/transcribedir', os.path.splitext(os.path.basename(audio_path))[0] + '.txt')
        formatted_transcript = format_transcript(transcript_path, ssh_host, ssh_user)
        with open(finaldoc_path, 'w') as f:
            f.write(f"#+title: {video_title}\n\n")
            # f.write(f"* {video_title}\n")
            f.write(formatted_transcript)
    else:
        print(f"Found {num_chapters} chapters in the video")
        with open(finaldoc_path, 'w') as f:
            f.write(f"#+title: {video_title}\n\n")
            # f.write(f"* {video_title}\n")
        for index, chapter in enumerate(video_info['chapters'], start=1):
            chap_title = chapter['title']
            print("Debug: Formatted final doc path is " + finaldoc_path)
            chap_file = next(f for f in os.listdir(os.path.dirname(audio_path)) if f.startswith(f"[{index:02d}]") and f.endswith('.mp3'))
            print(f"Chapter {index}: {chap_title} - file {chap_file}")
            transcribe_audio_file(os.path.join(os.path.dirname(audio_path), chap_file), ssh_host, ssh_user, whisper_model)
            transcript_path = os.path.join('/tmp/transcribedir', os.path.splitext(chap_file)[0] + '.txt')
            formatted_transcript = format_transcript(transcript_path, ssh_host, ssh_user)
            with open(finaldoc_path, 'a') as f:
                f.write(f"\n* {chap_title}\n")
                f.write(formatted_transcript)

# TODO: validate args: non-empty URL, valid model names, accessible SSH host
# TODO: check for local whisper - warn user if not present, suggest --ssh_{host,user}
# Load configuration from config.ini

if __name__ == '__main__':
    configp = ConfigParser()
    configp.read(os.path.expanduser('~/.config/ytaudio/config.ini'))

    parser = argparse.ArgumentParser(description='Transcribe YouTube videos using Whisper AI', epilog='Add optional config file at ~/.config/ytaudio/config.ini')
    parser.add_argument('video_url', help='URL of the YouTube video to transcribe')
    parser.add_argument('--model', default=configp.get('ytaudio', 'model'), help='Whisper AI model to use for transcription')
    parser.add_argument('--ssh-host', default=configp.get('ytaudio', 'ssh_host'), help='SSH host to run the transcription on')
    parser.add_argument('--ssh-user', default=os.environ['USER'], help='SSH username')
    args = parser.parse_args()

    main(args.video_url, args.model, args.ssh_host, args.ssh_user)
# Python code:1 ends here
