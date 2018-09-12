status=`exec playerctl status 2> /dev/null`

if [ ! "$status" = "" ]; then
    title=`exec playerctl metadata xesam:title`
    artist=`exec playerctl metadata xesam:artist`
    full="$title - $artist"

    echo "$full"
else
    echo ""
fi
