#!/bin/sh

# Build the Android apk in debug/release mode or deploy the game to the Love2d app (from the play store)

LOVE_MACOS=../love-macos

# debug/release
BUILD=debug

BUNDLE_ID="com.voodoocactus.games.clamp"
BUNDLE_NAME="Clamp"

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

BUNDLE="$LOVE_MACOS/$BUNDLE_NAME.app"
cp -r "$LOVE_MACOS/love.app" $BUNDLE

# Create the game zip. Must not contain the root folder
zip -r $BUNDLE/Contents/Resources/game.love $FILES -x *.DS_Store

# Install Frameworks
cp libpolyclipping.dylib $BUNDLE/Contents/Frameworks

pushd $LOVE_MACOS

PLIST="$BUNDLE_NAME.app/Contents/Info.plist"

# Update Info.plist
plutil -remove UTExportedTypeDeclarations $PLIST
plutil -replace CFBundleIdentifier -string "$BUNDLE_ID" $PLIST
plutil -replace CFBundleName -string "$BUNDLE_NAME" $PLIST

zip -ry "$BUNDLE_NAME.osx.zip" "$BUNDLE_NAME.app"

open love.app

popd
