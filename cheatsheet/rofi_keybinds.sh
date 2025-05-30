#!/bin/bash

###########################################
# Credits to https://github.com/jason9075 #
# Made some changes to fit my config file #
# #########################################

HYPR_CONF="../hypr/conf/binds.hl"

# extract the keybinding from hyprland.conf
mapfile -t BINDINGS < <(grep '^bind = ' "$HYPR_CONF" |
    sed -e 's/  */ /g' -e 's/bind = //g' -e 's/, /,/g' -e 's/ # /,/' |
    awk -F, -v q="'" '{cmd=""; for(i=3;i<NF;i++) cmd=cmd $(i) " ";print "<b>"$1 " + " $2 "</b>  <i>" $NF ",</i><span color=" q "gray" q ">" cmd "</span>"}')

CHOICE=$(printf '%s\n' "${BINDINGS[@]}" | rofi -dmenu -i -markup-rows -p "Hyprland Keybinds:")

# extract cmd from span <span color='gray'>cmd</span>
CMD=$(echo "$CHOICE" | sed -n 's/.*<span color='\''red'\''>\(.*\)<\/span>.*/\1/p')

# execute it if first word is exec else use hyprctl dispatch
if [[ $CMD == exec* ]]; then
    eval "$CMD"
else
    hyprctl dispatch "$CMD"
fi
