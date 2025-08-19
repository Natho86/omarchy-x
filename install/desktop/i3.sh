#!/bin/bash

# Install i3 window manager and X11 ecosystem for Omarchy-X
yay -S --noconfirm --needed \
  xorg-server xorg-xinit xorg-xrandr xorg-xsetroot \
  i3-wm i3status-rust i3lock \
  rofi dunst picom feh scrot \
  xss-lock brightnessctl playerctl \
  polkit-gnome \
  xdg-desktop-portal-gtk \
  virtualbox-guest-utils \
  rxvt-unicode alacritty