#!/home/gregj/.local/python-venvs/ytaudio/bin/python3
import os
import subprocess
import json
import argparse
import sys
from configparser import ConfigParser
from pathlib import Path
import logging
from typing import Tuple, List

# Initialize constants
CONFIG_PATH = Path.home() / '.config' / 'ytaudio' / 'config.ini'
LOG_DIR = Path.home() / '.config' / 'ytaudio' / 'logs'
LOG_DIR.mkdir(parents=True, exist_ok=True)
LOG_FILE = LOG_DIR / 'ytaudio.log'

# Setup logging
logging.basicConfig(
    filename=LOG_FILE,
    level=logging.DEBUG,
    format='%(asctime)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

def clean_whitespace(text: str) -> str:
    lines = text.splitlines()
    stripped_lines = [line.rstrip() for line in lines]
    return '\n'.join(stripped_lines)

def run_command(command: str) -> Tuple[str, str]:
    """
    Executes a shell command and returns its stdout and stderr.

    Args:
        command (str): The shell command to execute.

    Returns:
        Tuple[str, str]: A tuple containing the standard output and standard error.

    Raises:
        subprocess.CalledProcessError: If the command exits with a non-zero status.
    """
    logger.debug(f"Executing command: {command}")
    try:
        result = subprocess.run(
            command,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            shell=True,
            check=True,
            text=True
        )
        logger.debug(f"Command stdout: {result.stdout}")
        if result.stderr:
            logger.warning(f"Command stderr: {result.stderr}")
        return result.stdout, result.stderr
    except subprocess.CalledProcessError as e:
        print(f"Command failed with exit code {e.returncode}\n Error: {e.stderr}")
        logger.error(f"Command '{command}' failed with exit code {e.returncode}. Error: {e.stderr}")
        raise

def download_audio(video_url: str) -> Path:
    """
    Use the yt-dlp command to download audio from a video URL

    If the video has sections or chapters, segment the audio files by chapter

    Download thumbnail image and metadata in JSON format.

    Args:
        video_url (str): The URL to the video (usually YouTube)

    Returns: Path object: The path to the audio file for the whole video
    """
    command = (
        f"yt-dlp -f 'bestaudio' "
        "--write-thumbnail "
        "--cookies-from-browser edge "
        "--convert-thumbnails png "
        "--embed-metadata "
        "--check-formats "
        "--no-mtime "
        "--write-description "
        "--write-info-json "
        "--restrict-filenames "
        "--extract-audio --audio-format opus "
        f"'{video_url}' "
        "--paths home:~/YouTube/ "
        "-o '%(channel)s/%(title)s/%(title)s.%(ext)s' "
        "--print after_move:filepath "
        "--split-chapters "
        "-o 'chapter:%(channel)s/%(title)s/[%(section_number)02d]-%(section_title)s.%(ext)s' "
    )
    output, error = run_command(command)
    audio_path = Path(output.strip())
    logger.info(f"Downloaded audio to {audio_path}")
    return audio_path

def load_video_info(audio_path: Path) -> dict:
    """
    Load the video metadata info file from yt-dlp.

    Args:
        audio_path (Path): the path to the audio file generated by yt-dlp.  The info file will be in that directory.

    Returns:
        dict: parsed JSON info file
    """
    info_dir = audio_path.parent
    info_file = next((f for f in info_dir.glob('*.info.json')), None)
    if not info_file:
        logger.error(f"No info.json found in directory {info_dir}")
        raise FileNotFoundError("Info JSON file not found.")
    with info_file.open('r') as f:
        video_info = json.load(f)
    logger.debug(f"Loaded video info: {video_info}")
    return video_info

def transcribe_audio_file(audio_path: Path, ssh_host: str, ssh_user: str, whisper_model: str) -> Path:
    """
    Transcribe an audio file using Whisper AI, either locally or on a remote host.

    Depending on whether an `ssh_host` is provided, the transcription can be carried out locally or
    via passwordless SSH on a remote server (for example with the use of `ssh-agent`).

    Args:
        audio_path (str): The file path to the audio file to be transcribed.
        ssh_host (str): The SSH host where the transcription should be executed.
                        If None, transcription is performed locally.
        ssh_user (str): The username to be used for SSH access to the remote host.
        whisper_model (str): The model name for Whisper AI to use for audio transcription.

    Returns:
        None

    Side Effects:
        Executes commands to either synchronize files to a remote host and execute the
        Whisper AI transcription there, or directly runs the transcription locally.
        The function prints the output and error messages from these command executions.
    """
    logger.info(f"Transcribing {audio_path}")
    transcribe_command = (
        f"/home/{ssh_user}/.local/bin/whisper --task transcribe --model {whisper_model} "
        "--word_timestamps True --output_format all --output_dir /tmp/transcribedir"
    )
    if ssh_host:
        rsync_command = f"rsync -av {audio_path} {ssh_user}@{ssh_host}:/tmp/transcribedir/"
        run_command(rsync_command)
        # Special instruction to unload Ollama model from GPU if running
        remote_command = f"""ssh {ssh_user}@{ssh_host} "ollama ps | tail -1 | head -1 | cut -d' ' -f1 |sed s,NAME,,|xargs -r ollama stop" """
        output, error = run_command(remote_command)

        remote_command = f"ssh {ssh_user}@{ssh_host} '{transcribe_command} /tmp/transcribedir/{audio_path.name}'"
        output, error = run_command(remote_command)
    else:
        full_command = f"{transcribe_command} {audio_path}"
        output, error = run_command(full_command)
    transcript_path = Path('/tmp/transcribedir') / f"{audio_path.stem}.txt"
    logger.info(f"Transcript saved to {transcript_path}")
    return transcript_path

def format_transcript(transcript_path: Path, ssh_host: str, ssh_user: str) -> str:
    """
    Format a transcript using a Python script and the `wtpsplit` library,
    either locally or on a remote host. `wtpsplit` is used here to take
    the result of the Whisper AI transcript and format it into reasonable
    sentences and paragraphs.  The `format_paragraphs.py` script assumes
    use of a GPU.

    Args:
        transcript_path (str): The file path to the transcript text file.
        ssh_host (str): The SSH host where the formatting should be executed.
                        If None, formatting is performed locally.
        ssh_user (str): The username to be used for SSH access to the remote host.

    Returns:
        str: A string formatted into paragraphs with extraneous whitespace removed.

    Side Effects:
        Executes a command to either format the transcript locally or remotely,
        and processes any output or error messages from these command executions.

    External Dependencies:
        wtpsplit: Library used for text segmentation and formatting.
    """
    if ssh_host:
        command = f"ssh {ssh_user}@{ssh_host} ~/.local/python-venvs/wtpsplit/bin/python ~/format_paragraphs.py {transcript_path}"
    else:
        command = f"python ~/format_paragraphs.py {transcript_path}"
    output, error = run_command(command)
    formatted = clean_whitespace(output)
    logger.debug(f"Formatted transcript: {formatted}")
    return formatted

def process_transcription(audio_path: Path, video_info: dict, whisper_model: str, ssh_host: str, ssh_user: str) -> List[Tuple[str, str]]:
    """
    Manage the transcription process for an audio file, optionally segmented by chapters.

    For a given audio file and its associated video metadata, this function oversees
    the transcription using Whisper AI, either locally or on a remote SSH host, and
    formats the output. It captures and processes either the entire video or its
    individual chapters, appending each transcription to a list of tuples respecting
    chapter segmentation if present.

    Args:
        audio_path (Path): The path to the audio file.
        video_info (dict): Metadata of the video, including possible chapters.
        whisper_model (str): The Whisper AI model for audio transcription.
        ssh_host (str): SSH host for running transcription, if applicable.
        ssh_user (str): Username for SSH access.

    Returns:
        List[Tuple[str, str]]: A list of tuples each containing the title and
                               formatted transcript of the audio (or its chapters).

    Side Effects:
        Executes transcription and formatting commands, possibly remotely,
        handling output and error messages during execution.

    Raises:
        FileNotFoundError: If no audio file is found for a chapter.
    """

    transcripts = []
    num_chapters = len(video_info.get('chapters', []))
    video_title = video_info.get('title', 'Video')

    print(f"Beginning to transcribe video {video_title}")
    if num_chapters == 0:
        logger.info("No chapters found in the video.")
        logger.info(f"Transcribing {audio_path.name}")
        print(f"Transcribing {audio_path.name}")
        transcript_path = transcribe_audio_file(audio_path, ssh_host, ssh_user, whisper_model)
        formatted_transcript = format_transcript(transcript_path, ssh_host, ssh_user)
        transcripts.append((video_title, formatted_transcript))
    else:
        logger.info(f"Found {num_chapters} chapters in the video.")
        print(f"Found {num_chapters} chapters in the video.")
        for index, chapter in enumerate(video_info['chapters'], start=1):
            chap_title = chapter['title']
            chap_file = next((f for f in audio_path.parent.glob(f"[[]{index:02d}]*.opus")), None)
            if not chap_file:
                logger.warning(f"No audio file found for chapter {index}: {chap_title}")
                continue
            print(f"Transcribing chapter {index}: {chap_title} - file {chap_file.name}")
            logger.info(f"Transcribing chapter {index}: {chap_title} - file {chap_file.name}")
            transcript_path = transcribe_audio_file(chap_file, ssh_host, ssh_user, whisper_model)
            formatted_transcript = format_transcript(transcript_path, ssh_host, ssh_user)
            transcripts.append((chap_title, formatted_transcript))

    return transcripts

def write_final_document(finaldoc_path: Path, video_title: str, video_url: str, transcripts: List[Tuple[str, str]]):
    # see if we can grab the downloaded thumbnail
    thumbnail_dir = finaldoc_path.parent
    thumbnail_file = next((f for f in thumbnail_dir.glob('*.png')), None)

    with finaldoc_path.open('w') as f:
        f.write(f"#+title: {video_title}\n")
        f.write(f"#+source: {video_url}\n\n")
        for title, transcript in transcripts:
            f.write(f"* {title}\n")
            if thumbnail_file:
                f.write(f"\n[[file:{thumbnail_file}]]\n\n")
                thumbnail_file = None
            f.write(transcript + "\n")
    logger.info(f"Final document written to {finaldoc_path}")
    print(f"Formatted Org Mode transcript written to {finaldoc_path}")

def parse_args(config: ConfigParser):
    parser = argparse.ArgumentParser(
        description='Transcribe YouTube videos using Whisper AI',
        epilog='Add optional config file at ~/.config/ytaudio/config.ini'
    )
    parser.add_argument('video_url', help='URL of the YouTube video to transcribe')
    parser.add_argument('--model', default=config.get('ytaudio', 'model', fallback='base'),
                        choices=['turbo', 'base.en', 'medium.en', 'large-v3'],
                        help='Whisper AI model to use for transcription')
    parser.add_argument('--ssh-host', default=config.get('ytaudio', 'ssh_host', fallback=None),
                        help='SSH host to run the transcription on')
    parser.add_argument('--ssh-user', default=os.getenv('USER'),
                        help='SSH username')
    parser.add_argument('--debug', action='store_true', help='Enable debug mode for increased logging')

    args = parser.parse_args()

    if not args.ssh_host and not is_whisper_installed_locally():
        parser.error("Whisper is not installed locally. Provide --ssh-host to use remote transcription.")

    return args

def is_whisper_installed_locally() -> bool:
    try:
        run_command("whisper --version")
        return True
    except:
        logger.warning("Whisper is not installed locally.")
        return False

def load_config() -> ConfigParser:
    config = ConfigParser()
    if CONFIG_PATH.exists():
        config.read(CONFIG_PATH)
        logger.info(f"Loaded configuration from {CONFIG_PATH}")
    else:
        logger.warning(f"Config file {CONFIG_PATH} not found. Using default settings.")
    return config

def main():
    config = load_config()
    args = parse_args(config)
    print(args)
    # Update logging level based on debug flag
    if args.debug:
        logger.setLevel(logging.DEBUG)
        logger.debug("Debug mode enabled.")

    try:
        audio_path = download_audio(args.video_url)
        video_info = load_video_info(audio_path)
        transcripts = process_transcription(
            audio_path, video_info, args.model, args.ssh_host, args.ssh_user
        )
        finaldoc_path = audio_path.with_suffix('.org')
        write_final_document(finaldoc_path, video_info.get('title', 'Video'), video_info.get('webpage_url', 'Unknown'), transcripts)
    except Exception as e:
        logger.exception("An error occurred during processing.")
        sys.exit(1)

if __name__ == '__main__':
    main()
