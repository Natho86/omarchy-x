#!/bin/bash

# Color definitions (using bright colors for better visibility)
GREEN='\033[1;32m'        # Bright Green
BLUE='\033[1;94m'         # Bright Light Blue
CYAN='\033[1;96m'         # Bright Light Cyan
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
