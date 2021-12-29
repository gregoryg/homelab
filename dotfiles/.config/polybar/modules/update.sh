#!/bin/bash

# Dependencies:
# pacman-contrib, yay for AUR updates

ENA_UPDATES=$(command -v checkupdates)
CNT_UPDATES="0"
UPDATES="nA"

if [[ "$1" != *"count"* ]]; then
  echo "Fetching updates..."
fi

if [ "$ENA_UPDATES" ]; then
    UPDATES=$(checkupdates 2>/dev/null)
    CNT_UPDATES=$(echo "$UPDATES" | wc -l)
fi

ENA_UPDATES_AUR=$(command -v yay)
CNT_UPDATES_AUR="0"
UPDATES_AUR="nA"

if [ "$ENA_UPDATES_AUR" ]; then
    UPDATES_AUR=$(yay -Qua)
    CNT_UPDATES_AUR=$(echo "$UPDATES_AUR" | wc -l)
fi

CNT_UPDATES_TOTAL=$(("$CNT_UPDATES" + "$CNT_UPDATES_AUR"))

if [[ "$1" != *"count"* ]]; then
  clear
fi

if [ "$1" == "--count" ]; then
    echo "Official: $CNT_UPDATES, AUR: $CNT_UPDATES_AUR, Total: $CNT_UPDATES_TOTAL"
fi
if [ "$1" == "--count-short" ]; then
    echo "$CNT_UPDATES / $CNT_UPDATES_AUR"
fi
if [ "$1" == "--count-total" ]; then
    echo "$CNT_UPDATES_TOTAL"
fi
if [ "$1" == "--count-official" ]; then
    echo "$CNT_UPDATES"
fi
if [ "$1" == "--count-aur" ]; then
    echo "$CNT_UPDATES"
fi

if [ "$1" == "--update" ]; then
    echo "--- Update all packages ($CNT_UPDATES_TOTAL) via yay ---"
    echo

    yay -Syu --sudoflags "--stdin" --sudoloop

    echo
    read -rp "Press any key to exit..."
fi
if [ "$1" == "--update-noconfirm" ]; then
    echo "--- Update all packages ($CNT_UPDATES_TOTAL) via yay [noconfirm] ---"
    echo

    yay -Syu --sudoflags "--stdin" --sudoloop --noconfirm

    echo
    read -rp "Press any key to exit..."
fi

if [ "$1" == "--list" ]; then
    echo "--- List of updates ($CNT_UPDATES_TOTAL) ---"
    echo

    if [ "$ENA_UPDATES" ]; then
        echo "-- Official ($CNT_UPDATES):"
        echo "$UPDATES"
        echo 
    else
        echo "-- Package 'checkupdates' is not installed!"
        echo
    fi

    if [ "$ENA_UPDATES_AUR" ]; then
        echo "-- AUR ($CNT_UPDATES_AUR):"
        echo "$UPDATES_AUR"
        echo 
    else
        echo "-- Package 'yay' is not installed!"
        echo
    fi

    echo
    read -rp "Press any key to exit..."
fi

exit
