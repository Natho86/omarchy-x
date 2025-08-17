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

# Function to check network connectivity
check_network() {
  echo "Checking network connectivity..."
  if ! ping -c 1 -W 5 8.8.8.8 >/dev/null 2>&1; then
    echo "ERROR: No internet connectivity detected. Please check your network connection."
    return 1
  fi
  
  if ! nslookup proxy.golang.org >/dev/null 2>&1; then
    echo "WARNING: DNS issues detected. Trying to use alternative DNS..."
    # Temporarily use Google DNS for this session
    echo "nameserver 8.8.8.8" | sudo tee /etc/resolv.conf.backup >/dev/null
    sudo cp /etc/resolv.conf.backup /etc/resolv.conf
  fi
  return 0
}

# Manually install yay from AUR if not already available
if ! command -v yay &>/dev/null; then
  echo "Installing yay manually from AUR..."
  
  # Check network connectivity first
  if ! check_network; then
    echo "Failed to establish network connectivity - manual intervention required"
    exit 1
  fi
  
  # Install build tools
  echo "   📦 Installing build dependencies (base-devel, git)..."
  sudo pacman -Sy --needed --noconfirm base-devel git
  
  # Build and install yay with retry logic
  max_attempts=3
  attempt=1
  
  while [ $attempt -le $max_attempts ]; do
    echo "   🔨 Attempt $attempt of $max_attempts to build yay..."
    
    (
      cd /tmp
      rm -rf yay
      
      # Clone with timeout
      echo "      📥 Downloading yay source code..."
      if timeout 300 git clone https://aur.archlinux.org/yay.git; then
        cd yay
        
        # Set Go proxy timeout and retry settings
        export GOPROXY="https://proxy.golang.org,direct"
        export GOSUMDB="sum.golang.org"
        export GOTIMEOUT="300s"
        
        # Build with timeout and better error handling
        echo "      🔧 Building yay (this may take a few minutes)..."
        if timeout 600 makepkg -si --noconfirm; then
          echo "      ✅ Successfully built yay on attempt $attempt"
          exit 0
        else
          echo "      ❌ Build failed on attempt $attempt"
          exit 1
        fi
      else
        echo "      ❌ Git clone failed on attempt $attempt"
        exit 1
      fi
    )
    
    if [ $? -eq 0 ]; then
      break
    fi
    
    if [ $attempt -eq $max_attempts ]; then
      echo "All attempts to build yay failed. This may be due to:"
      echo "1. Network connectivity issues"
      echo "2. DNS resolution problems"
      echo "3. Go proxy timeouts"
      echo "Please check your internet connection and try again later."
      break
    fi
    
    echo "Waiting 10 seconds before next attempt..."
    sleep 10
    ((attempt++))
  done
  
  # Clean up
  rm -rf /tmp/yay
  
  if command -v yay &>/dev/null; then
    echo "Successfully installed yay from AUR!"
  else
    echo "Failed to install yay after $max_attempts attempts - manual intervention required"
    echo "You can try installing yay manually with: sudo pacman -S yay"
    exit 1
  fi
fi

# Add fun and color to the pacman installer
if ! grep -q "ILoveCandy" /etc/pacman.conf; then
  sudo sed -i '/^\[options\]/a Color\nILoveCandy' /etc/pacman.conf
fi
