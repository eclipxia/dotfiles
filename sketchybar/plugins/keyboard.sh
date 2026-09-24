#!/bin/bash

SRC=$(defaults read ~/Library/Preferences/com.apple.HIToolbox.plist AppleCurrentKeyboardLayoutInputSourceID 2>/dev/null)
LABEL="${SRC##*.}"

sketchybar -m --set "$NAME" label="${LABEL:-??}"
