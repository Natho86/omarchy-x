#!/bin/bash

# Color definitions (using bright colors for better visibility)
GREEN='\033[1;32m'        # Bright Green
BLUE='\033[1;94m'         # Bright Light Blue
CYAN='\033[1;96m'         # Bright Light Cyan
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
