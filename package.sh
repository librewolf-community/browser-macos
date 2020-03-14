#!/bin/bash

# Usage: ./package.sh /path/to/Firefox.dmg
# LibreWolf.dmg will be created next to Firefox.dmg

repo="$(pwd)"

vol=$(hdiutil attach "$1" -shadow | tail -n 1 | cut -f 3)
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
rm firefox.icns
cp "$repo/media/librewolf.icns" ./firefox.icns

cd browser/features || exit 1
rm -rf aushelper@mozilla.org.xpi \
  firefox@getpocket.com.xpi \
  onboarding@mozilla.org.xpi

cd "$vol" || exit 1
mv "$app" "LibreWolf.app"

cd "$repo" || exit 1

hdiutil detach "$vol"

out_dir=$(dirname "$1")
rm -f "$out_dir/LibreWolf.dmg"
hdiutil convert -format UDZO -o "$out_dir/LibreWolf.dmg" "$1" -shadow
