# LibreWolf macOS

OSX version of LibreWolf.

The browser can be built from source or it can be installed using a disk image, links to both methods are available below.
In case of feedback, suggestions or trouble fill an issue and let's solve it togheter. I would, in particular, appreciate feedback on M1 releases, and contributions on the brew tap.

## Installation
LibreWolf is available via HomeBrew by entering:
```
brew install --cask librewolf
```
If you prefer other install methods check the below section instead.

## Useful links
- [Releases](https://gitlab.com/librewolf-community/browser/macos/-/releases): download the latest .dmg for an easy install process. Releases are available for x86 and aarch64, although the second ones might show up as broken on the first launch, as macOS sets an extended attribute on our cross-compiled builds (if that happens to you, troubleshooting and discussion take place [here](https://gitlab.com/librewolf-community/browser/macos/-/issues/19)). aarch64 releases are also not tested directly by us (lack of hardware), and if you prefer x86 releases will still work on M1.
- [Build guide](./build_guide.md): if you want to build from source. The build process supports both x86 and aarch64, as well as cross-compiling for aarch64 on x86 machines.
- [Issue tracker](https://gitlab.com/librewolf-community/browser/macos/-/issues)
- LibreWolf [settings repository](https://gitlab.com/librewolf-community/settings)
- Our community on [gitter](https://gitter.im/librewolf-community/librewolf)
- [Website](https://librewolf-community.gitlab.io/)
- [FAQ](https://gitlab.com/librewolf-community/settings/-/wikis/FAQ)
- [r/LibreWolf](https://www.reddit.com/r/LibreWolf/)

## Notes and thanks
The main thanks go to:
- @stanzabird who basically paved the way for the build process, and a lot more
- @ohfp who makes a good portion of the changes you see in the browser possible
- @brightly-salty who got the cask on brew up and running
- more in general all librewolf's contributors and members
- the arkenfox project which is a mine of gold
- all the loyal machines that built librewolf at least once
- mozilla which provides the source code that we work on top of
- brew which provides a friendly install method

## License
Mozilla Public License Version 2.0. See `LICENSE.txt` for details.
