#!/bin/sh

# Build mac osx distribution bundle

LOVE_MACOS=../love-macos

# debug/release
BUILD=release

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

rm -rf "$LOVE_MACOS/$BUNDLE_NAME.app"
# Duplicate the original love.app
cp -r "$LOVE_MACOS/love.app" "$LOVE_MACOS/$BUNDLE_NAME.app"

# Create the game zip (game.love). Must not contain the root folder
rm "$LOVE_MACOS/game.love"
zip -r $LOVE_MACOS/game.love $FILES -x *.DS_Store

# Install Frameworks
cp libpolyclipping.dylib "$LOVE_MACOS/$BUNDLE_NAME.app/Contents/Frameworks"

cp design/osx.icns "$LOVE_MACOS/$BUNDLE_NAME.app/Contents/Resources/OS X AppIcon.icns"

cp -r licenses "$LOVE_MACOS/$BUNDLE_NAME.app/Contents/Resources"

pushd $LOVE_MACOS

# Create a "fused" game
cat love.app/Contents/MacOS/love game.love > $BUNDLE_NAME.app/Contents/MacOS/love

PLIST="$BUNDLE_NAME.app/Contents/Info.plist"

# Update Info.plist
plutil -remove UTExportedTypeDeclarations $PLIST
plutil -replace CFBundleIdentifier -string "$BUNDLE_ID" $PLIST
plutil -replace CFBundleName -string "$BUNDLE_NAME" $PLIST

# Create the distributable zip
zip -ry "$BUNDLE_NAME.osx.zip" "$BUNDLE_NAME.app"

# open the app for testing
open $BUNDLE_NAME.app

popd
