#!/bin/bash

# Color definitions
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}   Installing network utilities...${NC}"
yay -S --noconfirm --needed wget curl unzip inetutils

echo -e "${CYAN}   Installing file management tools...${NC}"
yay -S --noconfirm --needed fd eza fzf ripgrep zoxide

echo -e "${CYAN}   Installing text processing tools...${NC}"
yay -S --noconfirm --needed bat jq xmlstarlet

echo -e "${CYAN}   Installing system monitoring...${NC}"
yay -S --noconfirm --needed fastfetch btop

echo -e "${CYAN}   Installing documentation and help...${NC}"
yay -S --noconfirm --needed man tldr less whois plocate bash-completion

echo -e "${CYAN}   Installing terminal emulator...${NC}"
yay -S --noconfirm --needed alacritty

echo -e "${CYAN}   Installing clipboard tools...${NC}"
yay -S --noconfirm --needed wl-clipboard

echo -e "${CYAN}   Installing search optimization...${NC}"
yay -S --noconfirm --needed impala

echo -e "${GREEN}   ✅ Terminal tools installation complete${NC}"
