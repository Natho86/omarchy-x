#!/bin/bash

# Only add Chaotic-AUR if the architecture is x86_64 so ARM users can build the packages
if [[ "$(uname -m)" == "x86_64" ]] && ! command -v yay &>/dev/null; then
  # Try installing Chaotic-AUR keyring and mirrorlist
  chaotic_key_success=false
  
  # Check if key already exists
  if pacman-key --list-keys 3056513887B78AEB >/dev/null 2>&1; then
    chaotic_key_success=true
  else
    # Try multiple keyservers for better reliability
    keyservers=(
      "keyserver.ubuntu.com"
      "keys.openpgp.org"
      "pgp.mit.edu"
      "keyring.debian.org"
    )
    
    for keyserver in "${keyservers[@]}"; do
      echo "Trying keyserver: $keyserver"
      if sudo pacman-key --keyserver "$keyserver" --recv-key 3056513887B78AEB 2>/dev/null; then
        sudo pacman-key --lsign-key 3056513887B78AEB
        chaotic_key_success=true
        break
      fi
    done
  fi
  
  if $chaotic_key_success &&
    sudo pacman -U --noconfirm 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst' 2>/dev/null &&
    sudo pacman -U --noconfirm 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst' 2>/dev/null; then

    # Add Chaotic-AUR repo to pacman config
    if ! grep -q "chaotic-aur" /etc/pacman.conf; then
      echo -e '\n[chaotic-aur]\nInclude = /etc/pacman.d/chaotic-mirrorlist' | sudo tee -a /etc/pacman.conf >/dev/null
    fi

    # Install yay directly from Chaotic-AUR
    sudo pacman -Sy --needed --noconfirm yay
    echo "Successfully installed Chaotic-AUR and yay!"
  else
    echo "Failed to install Chaotic-AUR (keyserver issues are common), falling back to manual yay installation..."
  fi
fi

# Manually install yay from AUR if not already available
if ! command -v yay &>/dev/null; then
  echo "Installing yay manually from AUR..."
  # Install build tools
  sudo pacman -Sy --needed --noconfirm base-devel git
  
  # Build and install yay-bin in tmp directory
  (
    cd /tmp
    rm -rf yay
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si --noconfirm
  )
  
  # Clean up
  rm -rf /tmp/yay
  
  if command -v yay &>/dev/null; then
    echo "Successfully installed yay from AUR!"
  else
    echo "Failed to install yay - manual intervention required"
    exit 1
  fi
fi

# Add fun and color to the pacman installer
if ! grep -q "ILoveCandy" /etc/pacman.conf; then
  sudo sed -i '/^\[options\]/a Color\nILoveCandy' /etc/pacman.conf
fi
