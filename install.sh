#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export PATH="$SCRIPT_DIR/bin:$PATH"
OMARCHY_INSTALL="$SCRIPT_DIR/install"

# Give people a chance to retry running the installation
catch_errors() {
  echo -e "\n\e[31mOmarchy-X installation failed!\e[0m"
  echo "You can retry by running: ./install.sh"
  echo "Get help from the community: https://discord.gg/tXFUdasqhY"
}

trap catch_errors ERR

show_logo() {
  clear
  tte -i "$SCRIPT_DIR/logo.txt" --frame-rate ${2:-120} ${1:-expand}
  echo
}

show_subtext() {
  echo "$1" | tte --frame-rate ${3:-640} ${2:-wipe}
  echo
}

# Install prerequisites
echo "🔧 [PREFLIGHT] Checking system requirements..."
source $OMARCHY_INSTALL/preflight/guard.sh
echo "📦 [PREFLIGHT] Setting up AUR helper (yay)..."
source $OMARCHY_INSTALL/preflight/aur.sh
echo "🎨 [PREFLIGHT] Installing presentation tools..."
source $OMARCHY_INSTALL/preflight/presentation.sh
echo "🔄 [PREFLIGHT] Setting up migration system..."
source $OMARCHY_INSTALL/preflight/migrations.sh

# Configuration
show_logo beams 240
show_subtext "Let's install Omarchy! [1/5]"
echo "👤 [CONFIG] Setting up user identification..."
source $OMARCHY_INSTALL/config/identification.sh
echo "⚙️  [CONFIG] Copying base configuration files..."
source $OMARCHY_INSTALL/config/config.sh
echo "⌨️  [CONFIG] Detecting keyboard layout..."
source $OMARCHY_INSTALL/config/detect-keyboard-layout.sh
echo "🔧 [CONFIG] Configuring function keys..."
source $OMARCHY_INSTALL/config/fix-fkeys.sh
echo "🌐 [CONFIG] Setting up network configuration..."
source $OMARCHY_INSTALL/config/network.sh
echo "🔋 [CONFIG] Configuring power management..."
source $OMARCHY_INSTALL/config/power.sh
echo "🕐 [CONFIG] Setting timezone..."
source $OMARCHY_INSTALL/config/timezones.sh
echo "🎮 [CONFIG] Checking for NVIDIA graphics..."
source $OMARCHY_INSTALL/config/nvidia.sh

# Development
show_logo decrypt 920
show_subtext "Installing terminal tools [2/5]"
echo "💻 [TERMINAL] Installing terminal applications..."
source $OMARCHY_INSTALL/development/terminal.sh
echo "🛠️  [DEV] Installing development tools..."
source $OMARCHY_INSTALL/development/development.sh
echo "📝 [DEV] Setting up Neovim..."
source $OMARCHY_INSTALL/development/nvim.sh
echo "💎 [DEV] Installing Ruby..."
source $OMARCHY_INSTALL/development/ruby.sh
echo "🐳 [DEV] Setting up Docker..."
source $OMARCHY_INSTALL/development/docker.sh
echo "🔥 [SECURITY] Configuring firewall..."
source $OMARCHY_INSTALL/development/firewall.sh

# Desktop
show_logo slice 60
show_subtext "Installing desktop tools [3/5]"
echo "🖥️  [DESKTOP] Installing base desktop tools..."
source $OMARCHY_INSTALL/desktop/desktop.sh
echo "🪟 [DESKTOP] Setting up i3 window manager..."
source $OMARCHY_INSTALL/desktop/i3-desktop.sh
echo "🎨 [DESKTOP] Configuring themes..."
source $OMARCHY_INSTALL/desktop/theme.sh
echo "📶 [DESKTOP] Setting up Bluetooth..."
source $OMARCHY_INSTALL/desktop/bluetooth.sh
echo "🎵 [DESKTOP] Installing audio controls..."
source $OMARCHY_INSTALL/desktop/asdcontrol.sh
echo "🔤 [DESKTOP] Installing fonts..."
source $OMARCHY_INSTALL/desktop/fonts.sh
echo "🖨️  [DESKTOP] Setting up printer support..."
source $OMARCHY_INSTALL/desktop/printer.sh
echo "🔐 [LOGIN] Configuring auto-login with LightDM..."
source $OMARCHY_INSTALL/config/login-x11.sh

# Apps
show_logo expand
show_subtext "Installing default applications [4/5]"
echo "🌐 [APPS] Installing web applications..."
source $OMARCHY_INSTALL/apps/webapps.sh
echo "🎯 [APPS] Installing extra applications..."
source $OMARCHY_INSTALL/apps/xtras.sh
echo "📄 [APPS] Setting up file associations..."
source $OMARCHY_INSTALL/apps/mimetypes.sh

# Updates
show_logo highlight
show_subtext "Updating system packages [5/5]"
echo "🔍 [FINAL] Updating locate database..."
sudo updatedb
echo "⬆️  [FINAL] Updating all packages..."
yay -Syu --noconfirm --ignore uwsm

# Reboot
show_logo laseretch 920
show_subtext "You're done! So we'll be rebooting now..."
sleep 2
reboot
