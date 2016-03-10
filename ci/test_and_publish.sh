#! /usr/bin/env bash
set -e

fastlane ios test

if [[ $TRAVIS_PULL_REQUEST == "false" && ($TRAVIS_BRANCH == "master" || $TRAVIS_BRANCH == "development" || $TRAVIS_BRANCH == "feature/travis") ]] ; then
    fastlane ios beta
else
    echo "Skipping, only publishing beta builds for commits to development or master."
    echo "Branch: ${TRAVIS_BRANCH}"
    echo "Pull Request: ${TRAVIS_PULL_REQUEST}"
fi
