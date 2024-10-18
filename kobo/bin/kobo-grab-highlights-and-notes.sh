#!/usr/bin/env bash
username=${USER}

sqlite3 -tabs -header \
        /media/${USER}/KOBOeReader/.kobo/KoboReader.sqlite \
        "select VolumeID, Type, Color, DateCreated, Text, Annotation FROM BookMark where Type != 'dogear' ORDER BY VolumeID"
