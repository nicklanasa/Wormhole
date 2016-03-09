#! /usr/bin/env bash
set -e

if [[ $TRAVIS_PULL_REQUEST == "false" && ($TRAVIS_BRANCH == "master" || $TRAVIS_BRANCH == "development") ]] ; then
	tag=$(($TRAVIS_BUILD_NUMBER_OFFSET+$TRAVIS_BUILD_NUMBER))
	git push origin "${tag}"
else
	echo "Skipping, only pushing tags for commits to master."
	echo "Branch: ${TRAVIS_BRANCH}"
	echo "Pull Request: ${TRAVIS_PULL_REQUEST}"
fi
