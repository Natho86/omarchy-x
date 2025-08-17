#!/bin/bash

# Color definitions
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}   Installing programming languages...${NC}"
yay -S --noconfirm --needed cargo clang llvm mise

echo -e "${CYAN}   Installing image processing...${NC}"
yay -S --noconfirm --needed imagemagick

echo -e "${CYAN}   Installing database libraries...${NC}"
yay -S --noconfirm --needed mariadb-libs postgresql-libs

echo -e "${CYAN}   Installing Git tools...${NC}"
yay -S --noconfirm --needed github-cli lazygit

echo -e "${CYAN}   Installing Docker tools...${NC}"
yay -S --noconfirm --needed lazydocker-bin

echo -e "${GREEN}   ✅ Development tools installation complete${NC}"
