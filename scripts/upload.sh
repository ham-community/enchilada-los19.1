#!/usr/bin/env bash

set -e

if [[ -z "$GITHUB_TOKEN" ]]; then
   echo "Giving up on uploading, No Github Token Given>"
   exit 0
fi

if [[ -z "$GITHUB_REPO" ]]; then
   echo "Giving up on uploading, No Github Repo Given>"
   exit 0
fi

if [[ -z "$GITHUB_USER" ]]; then
   echo "Giving up on uploading, No Github Username Given>"
   exit 0
fi

cd /ham-build

wget "https://github.com/tcnksm/ghr/releases/download/v0.16.0/ghr_v0.16.0_linux_amd64.tar.gz"
tar -xvf ghr_v0.16.0_linux_amd64.tar.gz
rm -rf ghr_v0.16.0_linux_amd64.tar.gz

mv ghr_v0.16.0_linux_amd64/ghr /usr/bin/ghr
rm -rf ghr_v0.16.0_linux_amd64

# Tag is TODAY
TODAY=$(date +"%Y%m%d")
ghr -u $GITHUB_USER -r $GITHUB_REPO -delete $TODAY /ham-output/*
