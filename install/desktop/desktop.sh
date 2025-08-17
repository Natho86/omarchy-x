#!/bin/bash

# Color definitions
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}   Installing system controls...${NC}"
yay -S --noconfirm --needed brightnessctl playerctl pamixer wiremix wireplumber

echo -e "${CYAN}   Installing input methods...${NC}"
yay -S --noconfirm --needed fcitx5 fcitx5-gtk fcitx5-qt

echo -e "${CYAN}   Installing clipboard tools...${NC}"
yay -S --noconfirm --needed xclip clipit

echo -e "${CYAN}   Installing file manager...${NC}"
yay -S --noconfirm --needed nautilus sushi ffmpegthumbnailer gvfs-mtp

echo -e "${CYAN}   Installing media tools...${NC}"
yay -S --noconfirm --needed simplescreenrecorder mpv evince imv

echo -e "${CYAN}   Installing web browser...${NC}"
yay -S --noconfirm --needed chromium

echo -e "${GREEN}   ✅ Desktop applications installation complete${NC}"
