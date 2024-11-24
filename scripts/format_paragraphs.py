#!/home/gregj/.local/python-venvs/ytaudio/bin/python3
# This simple script formats text into sentences and paragraphs using the wtpsplit package
# It is especially useful for transcripts coming out of AI speech to text, like the whisper model

import os
import argparse
import typing
from wtpsplit import SaT

def main(input_file_path: str):
    sat = SaT("sat-3l")
    sat.half().to("cuda") # this assumes a GPU

    with open(input_file_path, 'r') as file:
        mytext = file.read()

        # Return list of list of string.  Each list is one paragraph
        # sentences are lists within paragraphs, peppered with spurious newlines
        paragraphed_sentences: typing.List[typing.List[str]] = sat.split(mytext, do_paragraph_segmentation=True)
        paragraphs = ["".join(sentences) for sentences in paragraphed_sentences]
        paragraphs = [paragraph.replace("\n", " ") for paragraph in paragraphs]
        paragraphed_text = "\n\n".join(paragraphs)

        print(paragraphed_text)

        with open("mytranscription.txt", "w") as file:
            file.write(paragraphed_text)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Format input text file into sentences and paragprahs using wtpsplit.')
    parser.add_argument('input_file', type=str, help='Path to the input text file')

    args = parser.parse_args()

    input_file_path = os.path.expanduser(args.input_file)
    main(input_file_path)
