#!/bin/bash

###########
## Settings
#
# Name of the bar in polybar (e.g. [bar/BARNAME]) which should be used as popup
POPUP_NAME="floating_popup"
#
# Set labels to indicate whether the corresponding popup is shown. These will appear in your main polybar
POPUP_LABEL_ACTIVE="󰋽"
POPUP_LABEL_INACTIVE="󰋼"
#
# For each polypopup, a statusfile is created based on its name. You can set the path and prefix here
# Be careful, as clearing all statusfiles happens with 'rm -f "$STATUSFILE_PATH$STATUSFILE_PREFIX*" '
STATUSFILE_PATH="$HOME/.config/polybar/scripts/"
STATUSFILE_PREFIX=".polypopup."
#
###########

POPUP_PID=-1
STATUSFILE=$STATUSFILE_PATH$STATUSFILE_PREFIX

function removeLocks() {
    # Clears all lock files
    echo "$STATUSFILE_PATH$STATUSFILE_PREFIX*"
}

function mapPID() {
    # Fetches the PID for the process with a name equal to 'POPUP_NAME' and stores it in 'POPUP_PID'

    POPUP_PID=$(ps -ef | grep $POPUP_NAME | grep -v grep | awk '{print $2}')
}

function setVisibility() {
    # Uses polybar-msg to hide or show the polybar with PID equal to 'POPUP_PID'.
    # Also creates a status file as indicator, using the name stored in 'POPUP_NAME' and
    # echos the specified active/inactive indicator label ('POPUP_LABEL_ACTIVE' / 'POPUP_LABEL_INACTIVE')
    #
    # Args:
    #       $1: visibility (0 = hide / 1 = show)

    if [ "$POPUP_PID" -eq -1 ]; then
        mapPID
    fi

    if [ "$1" -eq 0 ] ; then

        # Hide
        rm -f "$STATUSFILE$POPUP_NAME"
        polybar-msg -p "$POPUP_PID" cmd hide
        echo "$POPUP_LABEL_INACTIVE"

    else 

        #Show
        touch "$STATUSFILE$POPUP_NAME"
        polybar-msg -p "$POPUP_PID" cmd show
        echo "$POPUP_LABEL_ACTIVE"

    fi
}

if [ "$1" == "--toggle" ]; then
    if [ -f "$STATUSFILE$POPUP_NAME" ]; then
        # File exists -> hide
        setVisibility 0
    else
        # File does not exist -> show
        setVisibility 1
    fi
    exit
fi

if [ "$1" == "--hide" ]; then
    setVisibility 0
    exit
fi
if [ "$1" == "--show" ]; then
    setVisibility 1
    exit
fi

if [ "$1" == "--remove-locks" ]; then
    removeLocks
    exit
fi

if [ -f "$STATUSFILE$POPUP_NAME" ]; then
    echo "$POPUP_LABEL_ACTIVE"
else
    echo "$POPUP_LABEL_INACTIVE"
fi
exit
