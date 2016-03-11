#! /usr/bin/env bash
set -e

VERSION=$(git describe)
FILE="Kickserv/Info.plist"

/usr/libexec/PlistBuddy -c "Set :CFBundleVersion $VERSION" $FILE
