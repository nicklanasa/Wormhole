#!/usr/bin/env bash
set -e

SIMULATOR_ID=$(xcrun instruments -s | grep -o "iPhone 6 (9.2) \[.*\]" | grep -o "\[.*\]" | sed "s/^\[\(.*\)\]$/\1/")
open -b com.apple.iphonesimulator --args -CurrentDeviceUDID $SIMULATOR_ID
