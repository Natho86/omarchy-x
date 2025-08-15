#!/bin/bash

# Install i3 window manager and X11 desktop components
yay -S --noconfirm --needed \
  i3 picom polybar rofi dunst i3lock-color \
  xss-lock xidlehook redshift flameshot gpick feh \
  lightdm lightdm-gtk-greeter polkit-gnome \
  xdg-desktop-portal-gtk