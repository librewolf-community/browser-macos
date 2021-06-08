# Build guide
This document's goal is to explain more in depth the build process of LibreWolf.

In the first part of this guide we list the prerequisites: ideally those steps are preliminary and should be executed only once, when building LibreWolf for the first absolute time.
The second part of the guide instead includes the real building process, which happens using the [build script](./build.sh).

Further references on how to build Firefox can be found [here](https://firefox-source-docs.mozilla.org/setup/macos_build.html).

## Part I: prerequisites
In this section we will discuss how to install the needed tools to successfully build. This process was tested on macOS BigSur.

#### Homebrew
To build LibreWolf, and in general Firefox, we need [Homebrew](https://brew.sh/), as it will help installing third party tools used by the build script and in the build process.

To install Homebrew open your terminal and enter:
```
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```
When prompted to download and install Command Line Tools for Xcode agree and wait till the process finishes. It is important to install Homebrew before any other prerequisite, as otherwise we might end up changing the developer directory path.

Once the process finished and Homebrew is correctly installed we will then use it to get some required dependencies. Enter:
```
brew install mercurial wget yasm
```
In particular:
- `mercurial`: used by the bootstrap script to get a copy of the Firefox source code, which also includes a bunch of build dependencies.
- `wget`: used by the build script to download the source code of the desired Firefox base version, as well as a bunch of LibreWolf patches.
- `yasm`: used in the build process and unfortunately not included in the build dependencies provided by Mozilla when using the bootstrap script.

**NOTE**: on M1 powered machines the bootstrap script is unable to install some of the dependencies. As a consequence, if you own an ARM based MacBook, you will need to perform two additional steps:
1. `brew install rustup-init`
2. `cargo install cbindgen`

Both dependencies are need during the build process, and these are the only additional steps that M1 users have to perform during the entire building process.

#### Xcode
Install Xcode from the [App Store](https://apps.apple.com/us/app/xcode/id497799835?mt=12). This usually takes a while so grab a coffee and a good book.

Once the installation process is over open the terminal and enter:
```
sudo xcode-select --switch /Applications/Xcode.app
sudo xcodebuild -license
```
The first command will change the developer directory path so, as already mentioned, it is important to run it after installing Homebrew in order to avoid it being changed again. If you want to check your path enter `xcode-select -p`, it should be set to `/Applications/Xcode.app/Contents/Developer`.
The second command will show a license and will then ask us to agree to it.

**NOTE**: in some cases Xcode updates can ship with SDK versions that are not supported by Mozilla build process. In that case it will be necessary to follow the steps at the end of this guide.

#### .mozbuild
We will now download and use the Mozilla `bootstrap.py`, which allows to get most of the dependencies needed to build Firefox from source. This script also downloads the mozilla-unified repository, which we do not need to build LibreWolf, but unfortunately a workaround isn't available, so we will download it and later delete it.

To get the script enter:
```
curl https://hg.mozilla.org/mozilla-central/raw-file/default/python/mozboot/bin/bootstrap.py -O
```
then run it using:
```
python3 bootstrap.py
```
In the Homebrew section we mentioned that this script requires `mercurial` to work, as Mozilla source code is hosted in Mercurial repositories.

Once the script starts it will require to hit enter to use the default clone location, then after waiting for a while, further interactions will be required. In particular:
- We will be required to select a Firefox version that we want to build: enter `2` to select Firefox for Desktop, as it is the option which includes all required dependencies (except for `yasm` that we already installed manually), including `rust` and `cbindgen` (M1 users already installed these dependencies manually in the prerequisites). This is **important**, as it might cause your build process to fail if you do not pick the right option.
- We will be notified that the script wants to create a directory for the build tools: enter `y` to let the script create the default directory.
- We will be asked to run a configuration wizard for Mercurial: enter `n`.
- We will be asked to enable the build telemetry system: enter `n`.
- We will be asked whether we want to submit commits to Mozilla: enter `n`.

When the full process finishes we should see a success message with the suggestion to close the terminal. Do it, then open it again and to verify that the script worked enter `ls -la`: both `.mozbuild` and `mozilla-unified` directories should be in the home folder.
We can now enter `rm -rf bootstrap.py mozilla-unified` as those directories are related to building Firefox and we do not need them to build LibreWolf.

## Part II: the build script
In this section we are going to describe how to start the real build process, but we are also going to dicuss one by one the various steps included in the [build script](./build.sh). This second part of the build process should only be executed when the prerequisites are sucessfully completed.

First of all, clone the repository and move in it, by entering:
```
git clone --recursive https://gitlab.com/librewolf-community/browser/macos
cd macos
```

Entering `./build.sh` will give us a visual output with a list of all the available options in the script.
To build enter:
```
./build.sh full
```
This will take a while, so bring back the coffee and the book from the Xcode section.

The `full` option of the script file will perform the following tasks in order:
```
fetch
extract
apply_patches
branding
build
package
```
They can also be run singularly, by entering them after `./build.sh` instead of `full`, or it is possible to chain them separated by a single space. So for example we can say that `./build.sh full` is equivalent to `./build.sh fetch extract apply_patches branding build package`.
After the build process is completed the script will also allow to generate a .zip, to add LibreWolf to the applications or to remove all the build leftovers, respectively through `add_to_apps` and `cleanup`.

In the rest of the guide we will focus on describing what each function of the build script does.

#### fetch
Uses `wget` to download a certain version of Firefox from Mozilla archive, to use it as a base for LibreWolf.
#### extract
As the code downloaded using fetch is compressed this function will extract it. It usually takes a while for this part to complete and you will need about 4GB of disk space otherwise the process will fail.
#### apply_patches
Creates `mozconfig`, which contains the build options that will be used during the build process. It also applies the patches from the [common directory](./common).
#### branding
Fully rebrands the browser to LibreWolf, by moving the branding files from the [common directory](./common) inside the base Firefox directory. It also applies the branding related patch from the [patches directory](./patches).
#### build
This is the real building process, which should take from 60 to 90 minutes (for M1 users it should take from 20 to 30 minutes). Once it is completed a success message is displayed. It also moves the `mozconfig` file inside the base build directory.
#### package
Performs `./mach package`, then takes the previously built .app, strips some unused stuff from it and applies the LibreWolf settings from the [settings directory](./settings)
#### add_to_apps
As previously mentioned, moves LibreWolf.app in the `Applications` folder and creates a .zip containing LibreWolf.app and readme.md, which can be found in `~/Downloads`.
#### cleanup
Removes leftover files and folders from previous build processes.
#### xcomp
Allows to build for `aarch64` on a `x86` machines. See the next paragraph.
#### old_sdk
Allow to build using a different SDK than the one that comes with Xcode. See the related paragraph below.

## Building for aarch64 on an x86 machine

**Note**: it has been reported that cross-compiling produces builds that fail to launch, despite successfully completing the compile process.

With some tweaks it is possible to succesfully build a LibreWolf version targeted at M1 machines, on an Intel based MacBook.

First of all it is necessary to install the rust target for ARM-based machines, by entering in your terminal:
```
rustup target add aarch64-apple-darwin
```
This is a prerequisite and it should be performed only when cross-compiling for the first absolute time.

After this preliminary step, the only difference with the normal build process is that we should specify inside `mozconfig` that we want to compile for a different architecture, and we can do so by using the `xcomp` part of the build script, which should be obviously applied before the build.
So for example a good set of instructions for this purpose would be:
```
./build.sh fetch extract apply_patches xcomp branding build package
```
which is equivalent to `./build.sh full_x`.

## In case your SDK version is unsupported
With newest Xcode versions it might happen that your macOS SDK is too new to work with the build tools. If that's the case you will need to get an older SDK, place it in `~/.mozbuild/macos-sdk/` and then specify that you want to use it during the build process.
This is achieved by following these steps:
1. Go to [this link](https://developer.apple.com/download/more/), download `Xcode_12.4.xip` and then extract it.
2. Enter:
```
mkdir -p ~/.mozbuild/macos-sdk
cp -aH ~/Downloads/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX11.1.sdk ~/.mozbuild/macos-sdk/
```
3. From now on use the `old_sdk` part of the build script, which should be applied before the build

Steps number 1 and 2 will have to be executed only once, while you will have to execute steps 3 everytime you build.