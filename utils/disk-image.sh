#!/bin/bash

release_ver=$1
bold=$(tput bold)
normal=$(tput sgr0)

if [ -z $release_ver ]; then
    echo "Missing release version."
    echo "Format should be ${bold}./release.sh release_ver${normal}"
    exit 1
fi

create-dmg ../librewolf/LibreWolf.app
mv -v LibreWolf* librewolf-${release_ver}.dmg
