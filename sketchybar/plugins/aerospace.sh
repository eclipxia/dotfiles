#!/bin/bash

# Debugging marker (uncomment next line to log events to a file if needed)
# echo "Event fired! NAME=$NAME FOCUSED=$FOCUSED_WORKSPACE" >> /tmp/sketchybar_debug.log

if [ "$NAME" = "space.$FOCUSED_WORKSPACE" ]; then
    sketchybar --set "$NAME" background.drawing=on \
                             icon.color=0xff50fa7b \
                             label.color=0xff50fa7b
else
    sketchybar --set "$NAME" background.drawing=off \
                             icon.color=0xfff8f8f2 \
                             label.color=0xfff8f8f2
fi
