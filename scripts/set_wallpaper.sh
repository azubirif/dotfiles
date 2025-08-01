#!/bin/bash

# Borramos el antiguo symlink
rm ~/current-wallpaper

# Guardamos el fondo de pantalla como symlink
ln -s $1 ~/current-wallpaper

# Seleccionamos el fondo
swww img ~/current-wallpaper --transition-type center

# Cambiamos el tema
wal -i $1 -n > /dev/null 2>&1 &

# Actualizamos Mako
. "${HOME}/.cache/wal/colors.sh"

conffile="${HOME}/dotfiles/.config/mako/config"

# Associative array, color name -> color code.
declare -A colors
colors=(
    ["background-color"]="${background}89"
    ["text-color"]="$foreground"
    ["border-color"]="$color13"
)

for color_name in "${!colors[@]}"; do
  # replace first occurance of each color in config file
  sed -i "0,/^$color_name.*/{s//$color_name=${colors[$color_name]}/}" $conffile
done

makoctl reload

# Actualizamos Waybar
pkill waybar
waybar > /dev/null 2>&1 &

notify-send "Wallpaper actualizado" "Nuevo: $1"
