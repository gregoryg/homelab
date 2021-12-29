#!/bin/bash
# Based on https://github.com/PrayagS/polybar-spotify/

# Set the max text length.
# Default is 10 characters
LENGTH=${1:-20}    

# Set the source audio player here.
# Players supporting the MPRIS spec are supported.
# Examples: spotify, vlc, chrome, mpv and others.
# Use `playerctld` to always detect the latest player.
# See more here: https://github.com/altdesktop/playerctl/#selecting-players-to-control
PLAYER="playerctld"

# Format of the information displayed
# Eg. {{ artist }} - {{ album }} - {{ title }}
# See more attributes here: https://github.com/altdesktop/playerctl/#printing-properties-and-metadata
FORMAT="{{ title }} - {{ artist }}"

# see man zscroll for documentation of the following parameters
zscroll -l "$LENGTH" \
        --delay 0.2 \
        --scroll-padding " >> " \
        --match-command "playerctl -s --player=$PLAYER status 2>/dev/null" \
        --match-text "Playing" "--scroll 1" \
        --match-text "Paused" "--scroll 0" \
        --update-check true "playerctl -s --player=$PLAYER metadata --format '$FORMAT'" &

wait