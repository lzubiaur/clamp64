#!/bin/sh

# Build the Android apk in debug/release mode or deploy the game to the Love2d app (from the play store)

LOVE_MACOS=../love-macos

# debug/release
BUILD=debug

FILES="common
entities
gamestates
modules
resources
conf.lua
main.lua
hud
tests
"

# Write the debug/release configuration
echo "return '$BUILD'" > common/build.lua

# Create the game zip. Must not contain the root folder
rm $LOVE_MACOS/love.app/Contents/Resources/game.love
zip -r -y $LOVE_MACOS/love.app/Contents/Resources/game.love $FILES -x *.DS_Store

cp libpolyclipping.dylib $LOVE_MACOS/love.app/Contents/Frameworks

pushd $LOVE_MACOS

# TODO edit plist

open love.app

popd
