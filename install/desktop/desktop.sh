#!/bin/bash

yay -S --noconfirm --needed \
  brightnessctl playerctl pamixer wiremix wireplumber \
  fcitx5 fcitx5-gtk fcitx5-qt xclip \
  nautilus sushi ffmpegthumbnailer gvfs-mtp \
  slop satty \
  mpv evince imv \
  chromium

# Add screen recorder for X11
yay -S --noconfirm --needed obs-studio
