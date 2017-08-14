convert=/Users/lzubiaur/dev/tools/ImageMagick-6.8.3/bin/convert
mogrify=/Users/lzubiaur/dev/tools/ImageMagick-6.8.3/bin/mogrify
folder=design/osx.iconset
image=design/icon.png

# export from gimp to png
# transparency doesnt work
# $mogrify -format png -flatten -alpha on design/icon.xcf

mkdir $folder
$convert $image -resize 1024x1024 $folder/icon_512x512@2x.png
$convert $image -resize 521x512 $folder/icon_512x512.png
$convert $image -resize 512x512 $folder/icon_256x256@2x.png
$convert $image -resize 256x256 $folder/icon_256x256.png
$convert $image -resize 256x256 $folder/icon_128x128@2x.png
$convert $image -resize 128x128 $folder/icon_128x128.png
$convert $image -resize 64x64 $folder/icon_32x32@2x.png
$convert $image -resize 32x32 $folder/icon_32x32.png
$convert $image -resize 32x32 $folder/icon_16x16@2x.png
$convert $image -resize 16x16 $folder/icon_16x16.png

iconutil -c icns $folder
