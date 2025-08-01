#!/bin/bash

# Guardamos el fondo de pantalla como symlink
ln -s $1 ~/current-wallpaper

# Seleccionamos el fondo
swww img ~/current-wallpaper

# Cambiamos el tema
wal -i ~/current-wallpaper

# Actualizamos Waybar
waybar_reload
