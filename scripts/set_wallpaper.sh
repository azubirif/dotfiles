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
bash ./update_mako.sh
makoctl reload

# Actualizamos Waybar
killall -SIGUSR2 waybar

notify-send "Wallpaper actualizado" "Nuevo: $1"
