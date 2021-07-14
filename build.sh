#!/bin/sh

pkgver=90.0
objdir=obj-*/dist/librewolf
ospkg=app
bold=$(tput bold)
normal=$(tput sgr0)


fetch() {
    
    echo "\n${bold}-> Fetching Firefox source code${normal}\n"
    wget https://archive.mozilla.org/pub/firefox/releases/$pkgver/source/firefox-$pkgver.source.tar.xz
    if [ $? -ne 0 ]; then exit 1; fi
    if [ ! -f firefox-$pkgver.source.tar.xz ]; then exit 1; fi
    echo "${bold}-> Retrieved firefox-$pkgver.source.tar.xz ${normal}"

}

extract() {

    echo "\n${bold}-> Extracting firefox-$pkgver.source.tar.xz (might take a while)${normal}"
    tar xf firefox-$pkgver.source.tar.xz
    if [ $? -ne 0 ]; then exit 1; fi
    if [ ! -d firefox-$pkgver ]; then exit 1; fi
    echo "${bold}-> Extracted successfully ${normal}"

}

apply_patches() {

    echo "\n${bold}-> Creating mozconfig${normal}"
    if [ ! -d firefox-$pkgver ]; then exit 1; fi
    cd firefox-$pkgver
    
    cat >../mozconfig <<END
ac_add_options --enable-application=browser

# This supposedly speeds up compilation (We test through dogfooding anyway)
ac_add_options --disable-tests
ac_add_options --disable-debug

ac_add_options --enable-release
ac_add_options --enable-hardening
ac_add_options --enable-rust-simd
ac_add_options --enable-optimize


# Branding
ac_add_options --enable-update-channel=release
ac_add_options --with-app-name=librewolf
ac_add_options --with-app-basename=LibreWolf
ac_add_options --with-branding=browser/branding/librewolf
ac_add_options --with-distribution-id=io.gitlab.librewolf-community
ac_add_options --with-unsigned-addon-scopes=app,system
ac_add_options --allow-addon-sideload

# Features
ac_add_options --disable-crashreporter
ac_add_options --disable-updater

# Disables crash reporting, telemetry and other data gathering tools
mk_add_options MOZ_CRASHREPORTER=0
mk_add_options MOZ_DATA_REPORTING=0
mk_add_options MOZ_SERVICES_HEALTHREPORT=0
mk_add_options MOZ_TELEMETRY_REPORTING=0

END

    echo "\n${bold}-> Applying Librewolf patches${normal}"
    patch -p1 -i ../common/patches/about-dialog.patch
    if [ $? -ne 0 ]; then exit 1; fi
    patch -p1 -i ../common/patches/allow_dark_preference_with_rfp.patch
    if [ $? -ne 0 ]; then exit 1; fi
    patch -p1 -i ../common/patches/context-menu.patch
    if [ $? -ne 0 ]; then exit 1; fi
    patch -p1 -i ../common/patches/megabar.patch
    if [ $? -ne 0 ]; then exit 1; fi
    patch -p1 -i ../common/patches/mozilla-vpn-ad.patch
    if [ $? -ne 0 ]; then exit 1; fi
    patch -p1 -i ../common/patches/remove_addons.patch
    if [ $? -ne 0 ]; then exit 1; fi
    patch -p1 -i ../common/patches/search-config.patch
    if [ $? -ne 0 ]; then exit 1; fi
    patch -p1 -i ../common/patches/urlbarprovider-interventions.patch
    if [ $? -ne 0 ]; then exit 1; fi

    patch -p1 -i ../common/patches/sed-patches/allow-searchengines-non-esr.patch
    if [ $? -ne 0 ]; then exit 1; fi
    patch -p1 -i ../common/patches/sed-patches/disable-pocket.patch
    if [ $? -ne 0 ]; then exit 1; fi
    patch -p1 -i ../common/patches/sed-patches/remove-internal-plugin-certs.patch
    if [ $? -ne 0 ]; then exit 1; fi
    patch -p1 -i ../common/patches/sed-patches/stop-undesired-requests.patch
    if [ $? -ne 0 ]; then exit 1; fi
    echo "${bold}-> Patches applied successfully${normal}"

    if ([[ -d ~/.mozbuild/macos-sdk/MacOSX11.1.sdk ]])
    then
        echo "ac_add_options --with-macos-sdk=$HOME/.mozbuild/macos-sdk/MacOSX11.1.sdk" >> ../mozconfig
        echo "${bold}-> Using SDK from .mozbuild${normal}"
    fi

    cd ..

}

xcomp() {

    echo "ac_add_options --target=aarch64" >> mozconfig
    echo "${bold}-> Prepared to cross-compile${normal}"

}

branding() {

    cd firefox-$pkgver

    cp -vr ../common/source_files/* ./
    patch -p1 -i ../patches/browser-branding-configure.patch
    if [ $? -ne 0 ]; then exit 1; fi
    patch -p1 -i ../common/patches/browser-confvars.patch
    if [ $? -ne 0 ]; then exit 1; fi
    echo "${bold}-> Rebranded Librewolf${normal}\n"

    cd ..
    echo "${bold}-> READY TO BUILD${normal}\n"

}


build() {

    echo "\n${bold}-> OK, let's build.${normal}\n"
    if [ ! -d firefox-$pkgver ]; then exit 1; fi
    cd firefox-$pkgver

    cp -v ../mozconfig .
    
    ./mach build
    if [ $? -ne 0 ]; then exit 1; fi
    
    cd ..
    echo "\n${bold}-> BUILD ENDED SUCCESSFULLY${normal}\n"

}

package() {

    if [ ! -d firefox-$pkgver ]; then exit 1; fi
    cd firefox-$pkgver
    ./mach package
    if [ $? -ne 0 ]; then exit 1; fi
    echo "${bold}-> Applying final touches${normal}"

    cp -r $objdir ..
    cd ..
    cp -rv settings/* librewolf/LibreWolf.$ospkg/Contents/Resources
    rm -rf librewolf/LibreWolf.$ospkg/Contents/Resources/docs
    rm librewolf/LibreWolf.$ospkg/Contents/Resources/LICENSE.txt
    rm librewolf/LibreWolf.$ospkg/Contents/Resources/README.md
    echo "${bold}-> Set Librewolf settings${normal}"
    rm librewolf/LibreWolf.$ospkg/Contents/MacOS/pingsender

    echo "\n${bold}-> DONE${normal}\n"

}

add_to_apps() {

    echo "\n${bold}-> Creating .zip${normal}"
    cp -v readme.md librewolf
    zip -qr9 librewolf-$pkgver.zip librewolf
    if [ $? -ne 0 ]; then exit 1; fi

    rm librewolf/readme.md
    cp -r librewolf/* /Applications    
    cp -v librewolf-$pkgver.zip ~/Downloads

    echo "\n${bold}-> LibreWolf.app available in /Applications\n"

}

cleanup() {

    echo "${bold}-> Cleaning (migth take a while)${normal}"
    rm *.patch mozconfig librewolf-$pkgver.zip
    rm -rf firefox-* librewolf
    echo "${bold}-> All leftovers now gone${normal}"

}

full() {
    fetch
    extract
    apply_patches
    branding
    build
    package
}

full_x () {
    fetch
    extract
    apply_patches
    xcomp
    branding
    build
    package
}

# process commandline arguments and do something
done_something=0
if [[ "$*" == *fetch* ]]; then
    fetch
    done_something=1
fi
if [[ "$*" == *extract* ]]; then
    extract
    done_something=1
fi
if [[ "$*" == *apply_patches* ]]; then
    apply_patches
    done_something=1
fi
if [[ "$*" == *branding* ]]; then
    branding
    done_something=1
fi
if [[ "$*" == *build* ]]; then
    build
    done_something=1
fi
if [[ "$*" == *package* ]]; then
    package
    done_something=1
fi
if [[ "$*" == *full* ]]; then
    full
    done_something=1
fi
if [[ "$*" == *add_to_apps* ]]; then
    add_to_apps
    done_something=1
fi
if [[ "$*" == *cleanup* ]]; then
    cleanup
    done_something=1
fi
if [[ "$*" == *xcomp* ]]; then
    xcomp
    done_something=1
fi

if (( done_something == 0 )); then
    cat <<EOF

Build script for the OSX version of LibreWolf.
For more details check the build guide: https://gitlab.com/librewolf-community/browser/macos/-/blob/master/build_guide.md

${bold}BUILD${normal}

    ${bold}./build.sh${normal} [options]

${bold}BUILD OPTIONS${normal}

    ${bold}full${normal}
        The full build process, includes all the build options
    
    ${bold}fetch${normal}
        Fetches the source code

    ${bold}extract${normal}
        Extracts the source code
    
    ${bold}apply_patches${normal}
        Applies LibreWolf patches
    
    ${bold}branding${normal}
        Applies LibreWolf branding
    
    ${bold}build${normal}
        ./mach build
    
    ${bold}package${normal}
        ./mach package and final tweaks

${bold}OTHER OPTIONS${normal}

    ${bold}add_to_apps${normal}
        After the build it can be used to create a .zip and then move LibreWolf to Applications

    ${bold}cleanup${normal}
        Removes leftovers from previous build processes

    ${bold}xcomp${normal}
        Build for aarm64 on x86 machines
    
EOF
    exit 1
fi
