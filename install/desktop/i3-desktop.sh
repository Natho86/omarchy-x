#!/bin/bash

# Color definitions
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}   Installing i3 window manager...${NC}"
yay -S --noconfirm --needed i3 i3lock-color

echo -e "${CYAN}   Installing compositor and effects...${NC}"
yay -S --noconfirm --needed picom

echo -e "${CYAN}   Installing status bar and launcher...${NC}"
yay -S --noconfirm --needed polybar rofi

echo -e "${CYAN}   Installing notifications and utilities...${NC}"
yay -S --noconfirm --needed dunst xss-lock xidlehook

echo -e "${CYAN}   Installing screen tools...${NC}"
yay -S --noconfirm --needed redshift flameshot gpick feh

echo -e "${CYAN}   Installing display manager...${NC}"
yay -S --noconfirm --needed lightdm lightdm-gtk-greeter

echo -e "${CYAN}   Installing desktop integration...${NC}"
yay -S --noconfirm --needed polkit-gnome xdg-desktop-portal-gtk

echo -e "${GREEN}   ✅ i3 desktop environment installation complete${NC}"