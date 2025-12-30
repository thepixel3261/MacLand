#!/bin/env bash
 
# Options for powermenu
lock=""
logout=""
shutdown=""
reboot=""
sleep=""
 
# Get answer from user via rofi
selected_option=$(echo "$lock
$logout
$sleep
$reboot
$shutdown" | rofi -dmenu\
                  -i\
                  -p "Power"\
		  -theme "~/.config/rofi/themes/glass-power.rasi")
# Do something based on selected option
if [ "$selected_option" == "$lock" ]
then
    hyprlock
elif [ "$selected_option" == "$logout" ]
then
    loginctl kill-session $XDG_SESSION_ID
elif [ "$selected_option" == "$shutdown" ]
then
    systemctl poweroff
elif [ "$selected_option" == "$reboot" ]
then
    systemctl reboot
elif [ "$selected_option" == "$sleep" ]
then
    amixer set Master mute
    systemctl suspend
else
    echo "No match"
fi
