#!/bin/bash

# Color definitions for console output (using bright colors for better visibility)
GREEN='\033[1;32m'        # Bright Green
RED='\033[1;31m'          # Bright Red
YELLOW='\033[1;33m'       # Bright Yellow
BLUE='\033[1;94m'         # Bright Light Blue
CYAN='\033[1;96m'         # Bright Light Cyan
BOLD='\033[1m'
NC='\033[0m' # No Color

# Skip Chaotic-AUR setup as keyservers are unreliable and slow
# Go directly to building yay from AUR source

# Function to check network connectivity
check_network() {
  echo "Checking network connectivity..."
  if ! ping -c 1 -W 5 8.8.8.8 >/dev/null 2>&1; then
    echo "ERROR: No internet connectivity detected. Please check your network connection."
    return 1
  fi
  
  if ! nslookup google.com >/dev/null 2>&1; then
    echo "WARNING: DNS issues detected. Trying to use alternative DNS..."
    # Temporarily use Google DNS for this session
    echo "nameserver 8.8.8.8" | sudo tee /etc/resolv.conf.backup >/dev/null
    sudo cp /etc/resolv.conf.backup /etc/resolv.conf
  fi
  return 0
}

# Manually install yay from AUR if not already available
if ! command -v yay &>/dev/null; then
  echo "Installing yay from source..."
  
  # Start timer
  yay_start_time=$(date +%s)
  
  # Install DNS utilities first (needed for network check)
  echo -e "   ${BLUE}📦 Installing DNS utilities...${NC}"
  sudo pacman -Sy --needed --noconfirm bind
  
  # Check network connectivity 
  if ! check_network; then
    echo "Failed to establish network connectivity - manual intervention required"
    exit 1
  fi
  
  # Install build tools
  echo -e "   ${BLUE}📦 Installing build dependencies (base-devel, git)...${NC}"
  sudo pacman -S --needed --noconfirm base-devel git
  
  # Build and install yay with retry logic
  max_attempts=3
  attempt=1
  
  while [ $attempt -le $max_attempts ]; do
    echo -e "   ${YELLOW}🔨 Attempt $attempt of $max_attempts to build yay...${NC}"
    
    (
      cd /tmp
      rm -rf yay
      
      # Clone with timeout
      echo -e "      ${CYAN}📥 Downloading yay source code...${NC}"
      if timeout 300 git clone https://aur.archlinux.org/yay.git; then
        cd yay
        
        # Set Go proxy timeout and retry settings for faster builds
        export GOPROXY="https://proxy.golang.org,direct"
        export GOSUMDB="sum.golang.org"
        export GOTIMEOUT="300s"
        export CGO_ENABLED=0  # Disable CGO for faster builds
        
        # Use all available CPU cores for faster compilation
        export MAKEFLAGS="-j$(nproc)"
        
        # Build with timeout and better error handling
        echo -e "      ${BLUE}🔧 Building yay using $(nproc) CPU cores (this may take a few minutes)...${NC}"
        if timeout 600 makepkg -si --noconfirm; then
          echo -e "      ${GREEN}✅ Successfully built yay on attempt $attempt${NC}"
          exit 0
        else
          echo -e "      ${RED}❌ Build failed on attempt $attempt${NC}"
          exit 1
        fi
      else
        echo -e "      ${RED}❌ Git clone failed on attempt $attempt${NC}"
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
  
  # Calculate and display build time
  yay_end_time=$(date +%s)
  yay_duration=$((yay_end_time - yay_start_time))
  yay_minutes=$((yay_duration / 60))
  yay_seconds=$((yay_duration % 60))
  
  if command -v yay &>/dev/null; then
    echo -e "   ${GREEN}⏱️  yay installation completed in ${yay_minutes}m ${yay_seconds}s${NC}"
    echo -e "${GREEN}Successfully installed yay from AUR!${NC}"
  else
    echo -e "${RED}Failed to install yay after $max_attempts attempts - manual intervention required${NC}"
    echo "You can try installing yay manually with: sudo pacman -S yay"
    exit 1
  fi
fi

# Add fun and color to the pacman installer
if ! grep -q "ILoveCandy" /etc/pacman.conf; then
  sudo sed -i '/^\[options\]/a Color\nILoveCandy' /etc/pacman.conf
fi
