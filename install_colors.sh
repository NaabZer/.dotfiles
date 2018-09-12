#!/bin/bash

. base16colorscheme.conf

# Download termite colors
termiteurl="https://raw.githubusercontent.com/khamer/base16-termite/master/themes/base16-${colorscheme}.config"
echo "downloading colorscheme for termite"
$(curl $termiteurl > terminal/termite/colors)
#Add opacity to colorscheme
sed -i -r "s/rgba\((.*)\)/rgba\(\1\, 0.8\)/g" "terminal/termite/colors"

$(cat terminal/termite/base terminal/termite/colors > terminal/termite/config)


# Download rofi colors
rofiurl="https://raw.githubusercontent.com/0xdec/base16-rofi/master/themes/base16-${colorscheme}.config"
echo "downloading colorscheme for rofi"
$(curl $rofiurl > gui/rofi/colors)

#Add opacity to colorscheme
sed -i -r "s/rofi.color-window:.*#(.*), #(.*), #(.*)/rofi.color-window:  #88\1, #88\2, #88\3/g" "gui/rofi/colors"
sed -i -r "/^rofi.color-(window|enabled)/! s/rofi.color-(.*):.*#(.*), #(.*), #(.*), #(.*), #(.*)/rofi.color-\1:  #00\2, #\3, #00\4, #88\5, #\6/g" "gui/rofi/colors"

$(cat gui/rofi/base gui/rofi/colors > gui/rofi/config)

    


