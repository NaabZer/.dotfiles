#!/bin/bash

. base16colorscheme.conf

# Download alacritty colors
alacrittyurl="https://raw.githubusercontent.com/aarowill/base16-alacritty/master/colors/base16-${colorscheme}.toml"
echo "downloading colorscheme for alacritty"
$(curl $alacrittyurl > terminal/alacritty/colors)
$(cat terminal/alacritty/base terminal/alacritty/colors > terminal/alacritty/alacritty.toml)

# Download rofi colors
rofiurl="https://raw.githubusercontent.com/tinted-theming/base16-rofi/refs/heads/main/colors/base16-${colorscheme}.rasi"
echo "downloading colorscheme for rofi"
$(curl $rofiurl > gui/rofi/color.rasi)

#Add opacity to colorscheme
perl -p -i -e "s/(?<=lightbg:\s{1,30}rgba \( \d{1,3}, \d{1,3}, \d{1,3}, )100 %/50 %/g" "gui/rofi/color.rasi"
perl -p -i -e "s/(?<=background:\s{1,20}rgba \( \d{1,3}, \d{1,3}, \d{1,3}, )100 %/50 %/g" "gui/rofi/color.rasi"
#perl -p -i -e "s/(?<=selected\-normal\-foreground:\s{2})\@lightbg/\@black/g" "gui/rofi/color.rasi"

# Download i3 colors
# base16 `set $baseXX` vars go first, then the hand-edited config_base, since
# i3 substitutes variables in a single top-down pass (must be defined before use).
i3url="https://raw.githubusercontent.com/tinted-theming/base16-i3/main/colors/base16-${colorscheme}.config"
echo "downloading colorscheme for i3"
$(curl $i3url > gui/i3/colors)
$(cat gui/i3/colors gui/i3/config_base > gui/i3/config)

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

# set_dunst_color <urgency> <background|foreground> <#rrggbb>
# Rewrites one color in the [base16_<urgency>] section of gui/dunst/colors.
set_dunst_color() {
    local urgency="$1" field="$2" color="$3"
    if [ "$field" = "background" ]; then
        perl -0777 -p -i -e "s/(msg_urgency = \"$urgency\"\n\s*background = \")#[0-9a-fA-F]{6}(\")/\${1}$color\$2/" "gui/dunst/colors"
    else
        perl -0777 -p -i -e "s/(msg_urgency = \"$urgency\"\n\s*background = \"[^\"]*\"\n\s*foreground = \")#[0-9a-fA-F]{6}(\")/\${1}$color\$2/" "gui/dunst/colors"
    fi
}

# Download dunst colors
dunsturl="https://raw.githubusercontent.com/tinted-theming/base16-dunst/main/themes/base16-${colorscheme}.dunstrc"
echo "downloading colorscheme for dunst"
$(curl $dunsturl > gui/dunst/colors)

# base16 slot used for critical notifications; base08 is the semantic "red"
# slot but apathy puts teal there and purple in base0B, so use base0B instead
dunst_critical_bg=base0B

base06=$(cat gui/xresources/Xresources_col | grep "#define base06" | cut -d' ' -f3)
base07=$(cat gui/xresources/Xresources_col | grep "#define base07" | cut -d' ' -f3)
dunst_critical_bg_color=$(cat gui/xresources/Xresources_col | grep "#define $dunst_critical_bg" | cut -d' ' -f3)

# Swap the critical background for the slot picked above
set_dunst_color critical background "$dunst_critical_bg_color"

# Add alpha to backgrounds (60% opaque, same style as the Xresources trans colors above)
perl -p -i -e 's/^(\s*background\s*=\s*"#[0-9a-fA-F]{6})"/${1}99"/g' "gui/dunst/colors"

# Rewrite foregrounds: low uses base06, normal/critical use base07 (brighter,
# for better contrast against the darker/critical backgrounds)
set_dunst_color low foreground "$base06"
set_dunst_color normal foreground "$base07"
set_dunst_color critical foreground "$base07"

$(cat gui/dunst/colors gui/dunst/dunstrc_base > gui/dunst/dunstrc)
# dunst is dbus-activated: `killall dunst` is needed to pick up changes, it
# respawns on the next notification. Not run here.

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
