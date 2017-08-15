#!/bin/sh

# Build Windows 32bit distribution package

LOVE_WIN32=../love-0.10.2-win32

# debug/release
BUILD=release

# BUNDLE_ID="com.voodoocactus.games.clamp"
EXE_NAME="Clamp.exe"
PKG_NAME="Clamp"

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

PKG_FILES="
$EXE_NAME
license.txt
OpenAL32.dll
SDL2.dll
love.dll
lua51.dll
mpg123.dll
msvcp120.dll
msvcr120.dll
polyclipping.dll
licenses
"

# Write the debug/release configuration
echo "return '$BUILD'" > common/build.lua

# Create the game zip. Must not contain the root folder
zip -r $LOVE_WIN32/game.love $FILES -x *.DS_Store

# Install Frameworks
cp polyclipping.dll $LOVE_WIN32

cp -r licenses $LOVE_WIN32

pushd $LOVE_WIN32

cat love.exe game.love > $EXE_NAME
zip -ry "$PKG_NAME.win32.zip" $PKG_FILES

popd
