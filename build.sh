#!/bin/sh

pkgver=87.0
objdir=obj-x86_64-apple-darwin20.3.0/dist/librewolf
ospkg=app


fetch() {
    
    echo "--- Fetching Firefox source code ---"
    wget https://archive.mozilla.org/pub/firefox/releases/$pkgver/source/firefox-$pkgver.source.tar.xz
    if [ $? -ne 0 ]; then exit 1; fi
    if [ ! -f firefox-$pkgver.source.tar.xz ]; then exit 1; fi
    echo "--- Retrieved firefox-$pkgver.source.tar.xz ---\n"

}

extract() {

    echo "--- Extracting firefox-$pkgver.source.tar.xz (might take a while) ---"
    tar xf firefox-$pkgver.source.tar.xz
    if [ $? -ne 0 ]; then exit 1; fi
    if [ ! -d firefox-$pkgver ]; then exit 1; fi
    echo "--- Extracted successfully ---\n"

}

get_patches() {

    echo "--- Fetching Librewolf patches ---"
    wget -q https://gitlab.com/librewolf-community/browser/linux/-/raw/master/context-menu.patch
    if [ $? -ne 0 ]; then exit 1; fi
    if [ ! -f context-menu.patch ]; then exit 1; fi
    wget -q https://gitlab.com/librewolf-community/browser/linux/-/raw/master/megabar.patch
    if [ $? -ne 0 ]; then exit 1; fi
    if [ ! -f megabar.patch ]; then exit 1; fi
    wget -q https://gitlab.com/librewolf-community/browser/linux/-/raw/master/mozilla-vpn-ad.patch
    if [ $? -ne 0 ]; then exit 1; fi
    if [ ! -f mozilla-vpn-ad.patch ]; then exit 1; fi
    wget -q https://gitlab.com/librewolf-community/browser/linux/-/raw/master/remove_addons.patch
    if [ $? -ne 0 ]; then exit 1; fi
    if [ ! -f remove_addons.patch ]; then exit 1; fi
    echo "--- Patches retrieved successfully ---\n"

}

apply_patches() {

    echo "--- Creating mozconfig ---"
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
export MOZ_REQUIRE_SIGNING=0

# Features
ac_add_options --disable-crashreporter
ac_add_options --disable-updater

# Disables crash reporting, telemetry and other data gathering tools
mk_add_options MOZ_CRASHREPORTER=0
mk_add_options MOZ_DATA_REPORTING=0
mk_add_options MOZ_SERVICES_HEALTHREPORT=0
mk_add_options MOZ_TELEMETRY_REPORTING=0

END

    echo "--- Applying Librewolf patches ---\n"
    patch -p1 -i ../context-menu.patch
    if [ $? -ne 0 ]; then exit 1; fi
    patch -p1 -i ../megabar.patch
    if [ $? -ne 0 ]; then exit 1; fi
    patch -p1 -i ../mozilla-vpn-ad.patch
    if [ $? -ne 0 ]; then exit 1; fi
    patch -p1 -i ../remove_addons.patch
    if [ $? -ne 0 ]; then exit 1; fi
    echo "--- Patches applied successfully ---\n"

    cd ..

}

other_patches() {

    cd firefox-$pkgver

    patch -p1 -i ../patches/allow-searchengines-non-esr.patch
    if [ $? -ne 0 ]; then exit 1; fi
    echo "--- Enabled search engines options ---"
    patch -p1 -i ../patches/disable-pocket.patch
    if [ $? -ne 0 ]; then exit 1; fi
    echo "--- Disabled Pocket ---"
    patch -p1 -i ../patches/remove-internal-plugin-certs.patch
    if [ $? -ne 0 ]; then exit 1; fi
    echo "--- Removed internal plugin certificates ---"
    patch -p1 -i ../patches/stop-undesired-requests.patch
    if [ $? -ne 0 ]; then exit 1; fi
    echo "--- Stopped undesired requests ---\n"

    cd ..

}

branding() {

    cd firefox-$pkgver

    cp -vr ../common/source_files/* ./
    patch -p1 -i ../patches/browser-branding-configure.patch
    if [ $? -ne 0 ]; then exit 1; fi
    patch -p1 -i ../patches/browser-confvars.patch
    if [ $? -ne 0 ]; then exit 1; fi
    echo "--- Rebranded Librewolf ---\n\n"
    
    cp -v ../mozconfig .

    cd ..
    echo "--- READY TO BUILD ---\n\n"

}


build() {

    echo "OK, let's build.\n"
    if [ ! -d firefox-$pkgver ]; then exit 1; fi
    cd firefox-$pkgver
    
    ./mach build
    if [ $? -ne 0 ]; then exit 1; fi
    
    cd ..
    echo "\n--- BUILD ENDED SUCCESSFULLY --- \n"

}

package() {

    if [ ! -d firefox-$pkgver ]; then exit 1; fi
    cd firefox-$pkgver
    ./mach package
    if [ $? -ne 0 ]; then exit 1; fi
    echo "Applying final touches..."

    cp -r $objdir ..
    cd ..
    cp -rv settings/* librewolf/LibreWolf.$ospkg/Contents/Resources 
    echo "--- Set Librewolf settings ---\n"
    rm librewolf/LibreWolf.$ospkg/Contents/MacOS/pingsender
    echo "--- Creating .zip ---\n"
    zip -qr9 librewolf-$pkgver.en-US.zip librewolf
    if [ $? -ne 0 ]; then exit 1; fi

    echo "\n--- DONE ---\n"

    mv -v librewolf/LibreWolf.$ospkg /Applications
    mv -v librewolf-$pkgver.en-US.zip ~/Downloads

    echo "\nLibreWolf.app available in /Applications\n"

}

full() {
    fetch
    extract
    get_patches
    apply_patches
    other_patches
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
if [[ "$*" == *get_patches* ]]; then
    get_patches
    done_something=1
fi
if [[ "$*" == *apply_patches* ]]; then
    apply_patches
    done_something=1
fi
if [[ "$*" == *other_patches* ]]; then
    other_patches
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


# by default, give help..
if (( done_something == 0 )); then
    cat <<EOF

Welcome!
Examples:
    
    ./build.sh full

    or
    
    ./build.sh fetch extract get_patches apply_patches other_patches branding build package
    
EOF
    exit 1
fi
