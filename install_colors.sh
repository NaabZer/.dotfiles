#!/bin/bash

. base16colorscheme.conf

# Download alacritty colors
alacrittyurl="https://raw.githubusercontent.com/aarowill/base16-alacritty/master/colors/base16-${colorscheme}.toml"
echo "downloading colorscheme for alacritty"
$(curl $alacrittyurl > terminal/alacritty/colors)
$(cat terminal/alacritty/base terminal/alacritty/colors > terminal/alacritty/alacritty.toml)

# Download rofi colors
rofiurl="https://gitlab.com/jordiorlando/base16-rofi/-/raw/master/themes/base16-${colorscheme}.rasi"
echo "downloading colorscheme for rofi"
$(curl $rofiurl > gui/rofi/color.rasi)

#Add opacity to colorscheme
perl -p -i -e "s/(?<=lightbg:\s{1,30}rgba \( \d{1,3}, \d{1,3}, \d{1,3}, )100 %/0 %/g" "gui/rofi/color.rasi"
perl -p -i -e "s/(?<=background:\s{1,20}rgba \( \d{1,3}, \d{1,3}, \d{1,3}, )100 %/0 %/g" "gui/rofi/color.rasi"
perl -p -i -e "s/(?<=selected\-normal\-foreground:\s{2})\@lightbg/\@black/g" "gui/rofi/color.rasi"
    
# Download xrdb colors
#xrdburl="https://raw.githubusercontent.com/janoamaral/Xresources-themes/master/base16-${colorscheme}.Xresources"
xrdburl="https://raw.githubusercontent.com/tinted-theming/tinted-xresources/refs/heads/main/xresources/base16-${colorscheme}.Xresources"
$(curl $xrdburl > gui/xresources/Xresources_col)
base00=$(cat gui/xresources/Xresources_col | grep "#define base00" | cut -d' ' -f3 | cut -c2-)
base01=$(cat gui/xresources/Xresources_col | grep "#define base01" | cut -d' ' -f3 | cut -c2-)

$(echo "#define base00alpha #cc$base00" >> gui/xresources/Xresources_col)
$(echo "#define base01alpha #cc$base01" >> gui/xresources/Xresources_col)
$(echo "*background-trans: base00alpha" >> gui/xresources/Xresources_col)
$(echo "*background-alt-trans: base01alpha" >> gui/xresources/Xresources_col)

$(cat gui/xresources/Xresources_base gui/xresources/Xresources_col > gui/xresources/Xresources)

# Download Zathura colors
zathuraurl="https://raw.githubusercontent.com/HaoZeke/base16-zathura/main/build_schemes/colors/base16-${colorscheme}.config"
$(curl $zathuraurl > gui/zathura/zathurarc)

# apply base16-shell
script=~/.config/base16-shell/scripts/base16-${colorscheme}.sh
[ -f $script ] && . $script
echo $script
ln -fs $script ~/.base16_theme
echo -e "if \0041exists('g:colors_name') || g:colors_name != 'base16-$colorscheme'\n  colorscheme base16-$colorscheme\nendif" >| ~/.vimrc_background
if [ -n ${BASE16_SHELL_HOOKS:+s} ] && [ -d "${BASE16_SHELL_HOOKS}" ]; then
    for hook in $BASE16_SHELL_HOOKS/*; do
      [ -f "$hook" ] && [ -x "$hook" ] && "$hook"
    done
fi

export BASE16_THEME=${colorscheme}
