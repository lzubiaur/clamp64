convert="/Users/lzubiaur/Dev/tools/ImageMagick-6.8.3"
ios=design/ios-icons
ios2x=design/ios-icons-2x
icon=design/icon.png

mkdir $ios
mkdir $ios2x

$convert $icon -resize 29x29 $ios/app_icon_29.png
$convert $icon -resize 40x40 $ios/app_icon_40.png
$convert $icon -resize 50x50 $ios/app_icon_50.png
$convert $icon -resize 57x57 $ios/app_icon_57.png
$convert $icon -resize 60x60 $ios/app_icon_60.png
$convert $icon -resize 72x72 $ios/app_icon_72.png
$convert $icon -resize 76x76 $ios/app_icon_76.png

$convert $icon -resize 58x58 $ios2x/app_icon_29_x2.png
$convert $icon -resize 80x80 $ios2x/app_icon_40_x2.png
$convert $icon -resize 100x100 $ios2x/app_icon_50_x2.png
$convert $icon -resize 114x114 $ios2x/app_icon_57_x2.png
$convert $icon -resize 120x120 $ios2x/app_icon_60_x2.png
$convert $icon -resize 144x144 $ios2x/app_icon_72_x2.png
$convert $icon -resize 152x152 $ios2x/app_icon_76_x2.png
