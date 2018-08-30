#!/bin/bash

. base16colorscheme.conf

# Download termite colors
termiteurl="https://raw.githubusercontent.com/khamer/base16-termite/master/themes/base16-${colorscheme}.config"
echo "downloading colorscheme for termite"
$(curl $termiteurl > terminal/termite/colors)
$(cat terminal/termite/base terminal/termite/colors > terminal/termite/config)


# Download rofi colors
rofiurl="https://raw.githubusercontent.com/0xdec/base16-rofi/master/themes/base16-${colorscheme}.config"
echo "downloading colorscheme for rofi"
$(curl $rofiurl > gui/rofi/colors)
$(cat gui/rofi/base gui/rofi/colors > gui/rofi/config)

    


