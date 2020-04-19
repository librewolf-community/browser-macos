#!/bin/bash

# Usage: 
# ./package.sh [/path/to/Firefox.dmg]
# If path is not defined, the first occurence of Firefox ".dmg" in the local dir will be used.
# if there is no Firefox ".dmg" file, latest release of Firefox will be downloaded and used
#
# LibreWolf.dmg will be created next to Firefox.dmg

url="https://download.mozilla.org/?product=firefox-latest-ssl&os=osx"
namefile=""

if [[ $# -eq 0 ]]; then
	namefile=$(find Firefox*.dmg &> /dev/null | head -1)
	if [ -z "$namefile" ]; then
		echo "Downloading latest Firefox from mozilla..."
		namefile="Firefox.dmg"
		curl --location-trusted "$url" -o "$namefile"
	fi
else
	namefile=$1
fi

repo="$(pwd)"

vol=$(hdiutil attach "$namefile" -shadow | tail -n 1 | cut -f 3)
app="$(basename "$vol").app"

cd "$vol" || exit 1
codesign --remove-signature "$app"

cd "$app/Contents" || exit 1
rm -rf _CodeSignature Library/LaunchServices/org.mozilla.updater
rm CodeResources

cd MacOS || exit 1
rm -rf plugin-container.app/Contents/_CodeSignature \
  crashreporter.app \
  updater.app \
  pingsender

cd ../Resources || exit 1
rm -rf update-settings.ini updater.ini
cp -aX "$repo/settings/." .
cp "$repo/media/librewolf.icns" ./firefox.icns

cd browser/features || exit 1
rm -rf aushelper@mozilla.org.xpi \
  firefox@getpocket.com.xpi \
  onboarding@mozilla.org.xpi

cd "$vol" || exit 1
mv "$app" "LibreWolf.app"
cp "$repo/media/VolumeIcon.icns" ./.VolumeIcon.icns
cp "$repo/media/background.png" .background/background.png
rm -rf .fseventsd

cd "$repo" || exit 1

hdiutil detach "$vol"

out_dir=$(dirname "$namefile")
rm -f "$out_dir/LibreWolf.dmg"
hdiutil convert -format UDZO -o "$out_dir/LibreWolf.dmg" "$namefile" -shadow
