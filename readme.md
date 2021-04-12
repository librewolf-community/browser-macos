# LibreWolf macOS

OSX version of LibreWolf.

The `./patches` are partially taken from the [Windows](https://gitlab.com/librewolf-community/browser/windows/) repository, I mainly removed some Windows related stuff and added a new patch. The build script is mostly based on the above mentioned Windows repository, a ton of thanks to the maintainer who basically made this possible, and in general to all the LW community.

In case of feedback, suggestions or trouble fill an issue and let's solve it togheter! I would in particular appreciate feedback and contribution on the bulding process which so far has been tested on BigSur.

## Useful links
- [Releases](https://gitlab.com/librewolf-community/browser/macos/-/releases)
- [Build guide](./build_guide.md)
- [Issue tracker](https://gitlab.com/librewolf-community/browser/macos/-/issues)
- LibreWolf [settings repository](https://gitlab.com/librewolf-community/settings)
- Our community on [gitter](https://gitter.im/librewolf-community/librewolf)
- [r/LibreWolf](https://www.reddit.com/r/LibreWolf/)
- [Docs](https://librewolf.readthedocs.io/en/latest/)

## Building
This section is a condesed version of the build guide](./build_guide.md). I suggest to check it out in full, at least before your first build.

### Prerequisites
Below I'll list the partial prerequisites to build the browser. This section was finally tested on a clean osx device running BigSur. Ideally you will need to perform the following actions only once, when building for the first time.

#### Homebrew
Install [Homebrew](https://brew.sh/) using:
```
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```
then:
```
brew install mercurial wget yasm
```
#### Xcode
Install Xcode from the App Store, then:
```
sudo xcode-select --switch /Applications/Xcode.app
sudo xcodebuild -license
```
#### .mozbuild
Use the following commands to create `~/.mozbuild`:
```
curl https://hg.mozilla.org/mozilla-central/raw-file/default/python/mozboot/bin/bootstrap.py -O
python3 bootstrap.py
```
When prompted to select a mode enter 2 so that most dependencies will be included. After the process is finished remove useless files with `rm -rf bootstrap.py mozilla-unified`.

### Instructions
Clone this repo and enter the directory:
```
git clone --recursive https://gitlab.com/fxbrit/macos
cd macos
```
then:
```
./build.sh fetch extract get_patches apply_patches other_patches branding build package
```
or the shorter and equivalent `./build.sh full` .

At the end of the process, inside your `Applications` you will find `LibreWolf.app`. A .zip of the app will also be available in `~/Downloads`.

## License

Mozilla Public License Version 2.0. See `LICENSE.txt` for details.
