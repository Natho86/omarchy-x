#!/bin/bash

# Apply test configurations to running Omarchy-X system
# Run this script in your VM to test configuration changes

echo "Applying Omarchy-X test configurations..."

# Get the script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Apply urxvt minimal config
echo "Applying minimal urxvt configuration..."
cp "$SCRIPT_DIR/.Xresources" ~/
xrdb -merge ~/.Xresources

# Apply polybar test config
echo "Applying polybar test configuration..."
mkdir -p ~/.config/polybar
cp "$SCRIPT_DIR/.config/polybar/config.ini" ~/.config/polybar/

# Apply rofi fix
echo "Applying rofi configuration fix..."
mkdir -p ~/.config/rofi
cp "$SCRIPT_DIR/.config/rofi/config.rasi" ~/.config/rofi/

# Restart services
echo "Restarting polybar..."
killall -q polybar
while pgrep -x polybar >/dev/null; do sleep 1; done
~/.config/polybar/launch.sh &

echo "Restarting i3..."
i3-msg restart

echo ""
echo "Test configurations applied successfully!"
echo ""
echo "Changes made:"
echo "- Minimal urxvt configuration (should fix terminal display issues)"
echo "- Simple polybar with text-based workspace indicators and system info"
echo "- Fixed rofi configuration (removes deprecated theme syntax)"
echo ""
echo "For urxvt terminal issues, try these picom options:"
echo "1. No picom: ./disable-picom-test.sh"
echo "2. Minimal picom: cp .config/picom/picom-minimal.conf ~/.config/picom/picom.conf && killall picom && picom &"
echo "3. VirtualBox-optimized: cp .config/picom/picom-vbox-optimized.conf ~/.config/picom/picom.conf && killall picom && picom &"
echo ""
echo "To revert back to original configs, run:"
echo "ln -snf ~/.config/omarchy/current/theme/urxvt.xresources ~/.Xresources"
echo "ln -snf ~/.config/omarchy/current/theme/polybar.ini ~/.config/polybar/config.ini"
echo "xrdb -merge ~/.Xresources && i3-msg restart"