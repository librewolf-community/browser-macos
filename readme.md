# LibreWolf macOS

OSX version of LibreWolf.

The browser can be built from source or it can be installed using a disk image, links to both methods are available below.
In case of feedback, suggestions or trouble fill an issue and let's solve it togheter. I would, in particular, appreciate feedback and contribution on the bulding process which so far has been tested on BigSur.

## Useful links
- [Releases](https://gitlab.com/librewolf-community/browser/macos/-/releases): download the latest .dmg for an easy install process. Releases are available for x86 and aarch64, although the second ones might show up as broken on the first launch, as macOS sets an extended attribute on our cross-compiled builds (troubleshooting and discussion take place [here](https://gitlab.com/librewolf-community/browser/macos/-/issues/19). aarch64 releases are also not tested directly by us (lack of hardware), and if you prefer x86 releases will still work on M1.
- [Build guide](./build_guide.md): if you want to build from source. The build process supports both x86 and aarch64, as well as cross-compiling for aarch64 on x86 machines.
- [HomeBrew tap](https://gitlab.com/fxbrit/homebrew-librewolf): we now have an experimental brew tap (it doesn't handle updates yet), which means that you can add it entering `brew tap fxbrit/librewolf https://gitlab.com/fxbrit/homebrew-librewolf` and the install LibreWolf with `brew install librewolf`. Give it a try!
- [Issue tracker](https://gitlab.com/librewolf-community/browser/macos/-/issues)
- LibreWolf [settings repository](https://gitlab.com/librewolf-community/settings)
- Our community on [gitter](https://gitter.im/librewolf-community/librewolf)
- [Website](https://librewolf-community.gitlab.io/)
- [FAQ](https://gitlab.com/librewolf-community/settings/-/wikis/FAQ)
- [r/LibreWolf](https://www.reddit.com/r/LibreWolf/)

## Notes and thanks
The `./patches` are partially taken from the [Windows](https://gitlab.com/librewolf-community/browser/windows/) repository, I mainly removed some Windows related stuff and added a new patch. The build script is also mostly based on the above mentioned Windows repository, a ton of thanks to the maintainer who basically made this possible. More in general thank you to all the LibreWolf users and contributors as this is entirely a community effort.

As previously stated we also provide releases for M1 powered machines, but please notice that they have been built on Intel based machines and they have not been tested before release. For this reason the disk image for this kind of releases is marked as experimental.

## License
Mozilla Public License Version 2.0. See `LICENSE.txt` for details.
