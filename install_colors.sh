#!/bin/bash

. base16colorscheme.conf

# Download termite colors
colorurl="https://raw.githubusercontent.com/khamer/base16-termite/master/themes/base16-${colorscheme}.config"
echo "downloading colorscheme for termite"
$(curl $colorurl > terminal/termite/colors)
$(cat terminal/termite/base terminal/termite/colors > terminal/termite/config)


