#!/bin/bash

. base16colorscheme.conf

# Download termite colors
termiteurl="https://raw.githubusercontent.com/khamer/base16-termite/master/themes/base16-${colorscheme}.config"
echo "downloading colorscheme for termite"
$(curl $termiteurl > terminal/termite/colors)
#Add opacity to colorscheme
hex=$(perl -lne "while(/(?<=background\s{10}=\s#)\w+/g){print $&;}" "terminal/termite/colors")
rgba=$(printf "rgba(%d, %d, %d, 0.8)\n" 0x${hex:0:2} 0x${hex:2:2} 0x${hex:4:2})
perl -p -i -e "s/(?<=background\s{10}=\s)#\w+/$rgba/g" "terminal/termite/colors"
# sed -i -r "s/(?<=(background\s*=\s*))#(.{2})(.{2})(.{2})/rgba(

$(cat terminal/termite/base terminal/termite/colors > terminal/termite/config)


# Download rofi colors
rofiurl="https://gitlab.com/jordiorlando/base16-rofi/-/raw/master/themes/base16-${colorscheme}.rasi"
echo "downloading colorscheme for rofi"
$(curl $rofiurl > gui/rofi/color.rasi)

#Add opacity to colorscheme
perl -p -i -e "s/(?<=lightbg:\s{1,30}rgba \( \d{1,3}, \d{1,3}, \d{1,3}, )100 %/0 %/g" "gui/rofi/color.rasi"
perl -p -i -e "s/(?<=background:\s{1,20}rgba \( \d{1,3}, \d{1,3}, \d{1,3}, )100 %/0 %/g" "gui/rofi/color.rasi"
perl -p -i -e "s/(?<=selected\-normal\-foreground:\s{2})\@lightbg/\@black/g" "gui/rofi/color.rasi"
    
# Download xrdb colors
xrdburl="https://raw.githubusercontent.com/chriskempson/base16-xresources/master/xresources/base16-${colorscheme}.Xresources"
$(curl $xrdburl > gui/xresources/Xresources_col)
base00=$(cat gui/xresources/Xresources_col | grep "#define base00" | cut -d' ' -f3 | cut -c2-)
base01=$(cat gui/xresources/Xresources_col | grep "#define base01" | cut -d' ' -f3 | cut -c2-)

$(echo "#define base00alpha #cc$base00" >> gui/xresources/Xresources_col)
$(echo "#define base01alpha #cc$base01" >> gui/xresources/Xresources_col)
$(echo "*background-trans: base00alpha" >> gui/xresources/Xresources_col)
$(echo "*background-alt-trans: base01alpha" >> gui/xresources/Xresources_col)

$(cat gui/xresources/Xresources_base gui/xresources/Xresources_col > gui/xresources/Xresources)

# Download Zathura colors
zathuraurl="https://raw.githubusercontent.com/nicodebo/base16-zathura/master/build_schemes/base16-${colorscheme}.config"
$(curl $zathuraurl > gui/zathura/zathurarc)
