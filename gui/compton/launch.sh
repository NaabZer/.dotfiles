nate already running bar instances
killall -qw compton

# Launch picom
compton --config ~/.config/compton.conf -b --blur-method kawase &

echo "Comtpon launched..."
