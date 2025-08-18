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
  
  # Test both general DNS and AUR-specific domains 
  if ! nslookup google.com >/dev/null 2>&1 || ! nslookup aur.archlinux.org >/dev/null 2>&1; then
    echo -e "${YELLOW}WARNING: DNS resolution issues detected. Fixing systemd-resolved...${NC}"
    
    # Try to fix systemd-resolved properly first
    sudo systemctl start systemd-resolved 2>/dev/null || true
    sudo systemctl enable systemd-resolved 2>/dev/null || true
    
    # Configure systemd-resolved with fallback DNS
    if [ ! -f /etc/systemd/resolved.conf.d/omarchy.conf ]; then
      sudo mkdir -p /etc/systemd/resolved.conf.d
      cat <<EOF | sudo tee /etc/systemd/resolved.conf.d/omarchy.conf >/dev/null
[Resolve]
DNS=8.8.8.8 1.1.1.1
FallbackDNS=8.8.8.8 1.1.1.1
EOF
    fi
    
    # Ensure proper resolv.conf symlink
    sudo ln -sf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf 2>/dev/null || true
    
    # Restart with new config
    sudo systemctl restart systemd-resolved 2>/dev/null || true
    sleep 3
    
    # Test again - both general and AUR-specific domains
    if ! nslookup google.com >/dev/null 2>&1 || ! nslookup aur.archlinux.org >/dev/null 2>&1; then
      echo -e "${YELLOW}systemd-resolved fix failed. Using direct DNS fallback...${NC}"
      # Fallback: direct DNS (more aggressive fix)
      sudo rm -f /etc/resolv.conf
      echo "nameserver 8.8.8.8" | sudo tee /etc/resolv.conf >/dev/null
      echo "nameserver 1.1.1.1" | sudo tee -a /etc/resolv.conf >/dev/null
      
      # Test critical domains for AUR download
      sleep 1
      if ! nslookup aur.archlinux.org >/dev/null 2>&1; then
        echo -e "${RED}Critical: Cannot resolve aur.archlinux.org - AUR download will fail${NC}"
        echo "You may need to fix DNS manually before continuing"
        return 1
      fi
    else
      echo -e "${GREEN}DNS resolution fixed!${NC}"
    fi
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
  
  # Final DNS verification before download
  echo -e "   ${BLUE}🔍 Verifying DNS resolution for AUR download...${NC}"
  if ! nslookup aur.archlinux.org >/dev/null 2>&1; then
    echo -e "   ${RED}❌ Cannot resolve aur.archlinux.org - attempting emergency DNS fix...${NC}"
    sudo rm -f /etc/resolv.conf
    echo "nameserver 8.8.8.8" | sudo tee /etc/resolv.conf >/dev/null
    echo "nameserver 1.1.1.1" | sudo tee -a /etc/resolv.conf >/dev/null
    sleep 2
    
    if ! nslookup aur.archlinux.org >/dev/null 2>&1; then
      echo -e "   ${RED}❌ Emergency DNS fix failed - AUR download will likely fail${NC}"
      echo "You may need to fix DNS manually and retry installation"
    else
      echo -e "   ${GREEN}✅ Emergency DNS fix successful${NC}"
    fi
  else
    echo -e "   ${GREEN}✅ DNS resolution working - proceeding with download${NC}"
  fi

  # Build and install yay with retry logic
  max_attempts=3
  attempt=1
  
  # Refresh sudo timestamp to prevent timeouts during build
  sudo -v
  
  while [ $attempt -le $max_attempts ]; do
    echo -e "   ${YELLOW}🔨 Attempt $attempt of $max_attempts to build yay...${NC}"
    
    # Refresh sudo session before each attempt
    sudo -v
    
    # Change to temp directory for build
    cd /tmp
    rm -rf yay-bin
    
    # Clone with timeout - using yay-bin for faster installation (like original Omarchy)
    echo -e "      ${CYAN}📥 Downloading yay-bin (pre-compiled binary)...${NC}"
    if timeout 300 git clone https://aur.archlinux.org/yay-bin.git; then
      cd yay-bin
      
      # Build and install with timeout - much faster since it's pre-compiled
      echo -e "      ${BLUE}🔧 Installing yay-bin (pre-compiled, no compilation needed)...${NC}"
      
      # Refresh sudo session right before makepkg
      sudo -v
      
      if timeout 300 makepkg -si --noconfirm; then
        echo -e "      ${GREEN}✅ Successfully installed yay-bin on attempt $attempt${NC}"
        break  # Exit the retry loop on success
      else
        echo -e "      ${RED}❌ Installation failed on attempt $attempt${NC}"
        cd /tmp  # Return to temp directory for next attempt
      fi
    else
      echo -e "      ${RED}❌ Git clone failed on attempt $attempt${NC}"
    fi
    
    # Check if yay was successfully installed
    if command -v yay &>/dev/null; then
      echo -e "   ${GREEN}✅ yay successfully installed on attempt $attempt${NC}"
      break
    fi
    
    if [ $attempt -eq $max_attempts ]; then
      echo -e "${RED}All attempts to build yay failed. This may be due to:${NC}"
      echo "1. Network connectivity issues"
      echo "2. DNS resolution problems" 
      echo "3. Go proxy timeouts"
      echo "4. Insufficient disk space"
      echo "Please check your internet connection and try again later."
      break
    fi
    
    echo "Waiting 10 seconds before next attempt..."
    sleep 10
    ((attempt++))
  done
  
  # Clean up
  rm -rf /tmp/yay-bin
  
  # Calculate and display build time
  yay_end_time=$(date +%s)
  yay_duration=$((yay_end_time - yay_start_time))
  yay_minutes=$((yay_duration / 60))
  yay_seconds=$((yay_duration % 60))
  
  if command -v yay &>/dev/null; then
    echo -e "   ${GREEN}⏱️  yay-bin installation completed in ${yay_minutes}m ${yay_seconds}s${NC}"
    echo -e "${GREEN}Successfully installed yay-bin from AUR!${NC}"
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
