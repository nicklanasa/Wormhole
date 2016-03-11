#! /usr/bin/env bash
set -e

tag=$(($TRAVIS_BUILD_NUMBER_OFFSET+$TRAVIS_BUILD_NUMBER))

git_user_name=`git log -1 --pretty=format:%an`
git_user_email=`git log -1 --pretty=format:%ae`

git config --local user.name $git_user_name
git config --local user.email $git_user_email

echo "Tagging branch ${TRAVIS_BRANCH} with ${tag}…"
git tag -m "build-${tag} [skip ci]" -a "${tag}"

new_tag=`git describe`
echo "Branched tagged with ${new_tag}"
