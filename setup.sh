#!/bin/sh
# install deps, list apps on program-list file
LANG=C yay --noprovides --answerdiff All --answerclean All --mflags "--noconfirm" -S "$(cat program-list)"

mv "$XDG_CONFIG_HOME/hypr/" "$XDG_CONFIG_HOME/hypr-bak/"
mv "./hypr/" "$XDG_CONFIG_HOME/hypr/"

mv "$XDG_CONFIG_HOME/waybar/" "$XDG_CONFIG_HOME/waybar-bak/"

if [ ! -d "$HOME/bin/" ]; then
    mkdir -pv "$HOME/bin/"
fi

mv "./cheatsheet/rofi_keybinds.sh" "$HOME/bin/rofi_keybinds.sh"
