#!/bin/bash

release_ver=$1
private_token=$2
bold=$(tput bold)
normal=$(tput sgr0)

if [ -z $release_ver ]; then
    echo "Missing release version."
    echo "Format should be ${bold}./release.sh release_ver token ${normal}"
    exit 1
fi
if [ -z $private_token ]; then
    echo "Missing gitlab private token."
    echo "Format should be ${bold}./release.sh release_ver token${normal}"
    exit 1
fi

curl --request POST --header "PRIVATE-TOKEN: ${private_token}" --form "file=@librewolf-${release_ver}.dmg" "https://gitlab.com/api/v4/projects/13853965/uploads"
echo ""
