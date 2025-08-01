#!/bin/bash

echo "Setting  $1"

# Borramos el antiguo symlink
rm ~/current-wallpaper

# Guardamos el fondo de pantalla como symlink
ln -s $1 ~/current-wallpaper

# Seleccionamos el fondo
swww img ~/current-wallpaper --transition-type center

# Cambiamos el tema
wal -i $1

# Actualizamos Waybar
killall -SIGUSR2 waybar
