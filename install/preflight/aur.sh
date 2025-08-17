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
  
  # Test both general DNS and Go-specific domains that yay build needs
  if ! nslookup google.com >/dev/null 2>&1 || ! nslookup golang.org >/dev/null 2>&1; then
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
    
    # Test again - both general and Go-specific domains
    if ! nslookup google.com >/dev/null 2>&1 || ! nslookup golang.org >/dev/null 2>&1; then
      echo -e "${YELLOW}systemd-resolved fix failed. Using direct DNS fallback...${NC}"
      # Fallback: direct DNS (more aggressive fix)
      sudo rm -f /etc/resolv.conf
      echo "nameserver 8.8.8.8" | sudo tee /etc/resolv.conf >/dev/null
      echo "nameserver 1.1.1.1" | sudo tee -a /etc/resolv.conf >/dev/null
      
      # Test critical domains for Go build
      sleep 1
      if ! nslookup golang.org >/dev/null 2>&1; then
        echo -e "${RED}Critical: Cannot resolve golang.org - Go build will fail${NC}"
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
  echo -e "   ${BLUE}📦 Installing build dependencies (base-devel, git, go)...${NC}"
  sudo pacman -S --needed --noconfirm base-devel git go
  
  # Final DNS verification before build
  echo -e "   ${BLUE}🔍 Verifying DNS resolution for Go build...${NC}"
  if ! nslookup golang.org >/dev/null 2>&1; then
    echo -e "   ${RED}❌ Cannot resolve golang.org - attempting emergency DNS fix...${NC}"
    sudo rm -f /etc/resolv.conf
    echo "nameserver 8.8.8.8" | sudo tee /etc/resolv.conf >/dev/null
    echo "nameserver 1.1.1.1" | sudo tee -a /etc/resolv.conf >/dev/null
    sleep 2
    
    if ! nslookup golang.org >/dev/null 2>&1; then
      echo -e "   ${RED}❌ Emergency DNS fix failed - yay build will likely fail${NC}"
      echo "You may need to fix DNS manually and retry installation"
    else
      echo -e "   ${GREEN}✅ Emergency DNS fix successful${NC}"
    fi
  else
    echo -e "   ${GREEN}✅ DNS resolution working - proceeding with build${NC}"
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
    rm -rf yay
    
    # Clone with timeout
    echo -e "      ${CYAN}📥 Downloading yay source code...${NC}"
    if timeout 300 git clone https://aur.archlinux.org/yay.git; then
      cd yay
      
      # Configure Go to work around DNS/proxy issues
      export GOPROXY="direct"              # Skip proxy, go direct to source
      export GOSUMDB="off"                 # Disable checksum verification
      export GOTIMEOUT="600s"              # Longer timeout for direct downloads
      export CGO_ENABLED=0                 # Disable CGO for faster builds
      export GO111MODULE=on                # Ensure module mode
      
      # Use all available CPU cores for faster compilation
      export MAKEFLAGS="-j$(nproc)"
      
      # Build with timeout and better error handling
      echo -e "      ${BLUE}🔧 Building yay using $(nproc) CPU cores (this may take a few minutes)...${NC}"
      
      # Refresh sudo again right before makepkg to ensure valid session
      sudo -v
      
      if timeout 900 makepkg -si --noconfirm; then
        echo -e "      ${GREEN}✅ Successfully built yay on attempt $attempt${NC}"
        break  # Exit the retry loop on success
      else
        echo -e "      ${RED}❌ Build failed on attempt $attempt${NC}"
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
