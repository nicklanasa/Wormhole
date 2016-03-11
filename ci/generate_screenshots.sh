#! /usr/bin/env bash
set -e

if [[ $TRAVIS_PULL_REQUEST == "false" && ($TRAVIS_BRANCH == "master" || $TRAVIS_BRANCH == "development") ]] ; then
    fastlane ios screenshots
else
    echo "Skipping, only generating screenshots for commits to development or master."
    echo "Branch: ${TRAVIS_BRANCH}"
    echo "Pull Request: ${TRAVIS_PULL_REQUEST}"
fi
