## Utilities
This directory contains a collection of utility scripts that can be in the context of building and releasing LibreWolf.

#### disk-image
The script allows to generate a good looking .dmg before a release, by using [create-dmg](https://github.com/sindresorhus/create-dmg).
To use it install the dependencies:
```
brew install node@14
npm install --global create-dmg
```
then:
```
./release.sh release_ver
```
where `release_ver` could be for example `78.0-1`.

#### release
The script allows to upload the previously created .dmg in preparation for a release.
To use it:
```
./release.sh release_ver token
```
where `release_ver` is the same one of the previous script and `token` is a GitLab private token .
