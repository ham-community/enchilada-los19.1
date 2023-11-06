#!/usr/bin/bash -i
#
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

cd /ham-output

export TODAY=$(date +"%Y%m%d%H%M%S")
ghr -delete -t "${GITHUB_TOKEN}" -u "${GITHUB_USER}" -r "${GITHUB_REPO}" "${TODAY}" /ham-output/
