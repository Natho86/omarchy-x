#!/bin/bash

# Terminal configuration for Omarchy-X
# Using urxvt as default terminal for VirtualBox compatibility
TERMINAL="urxvt"
echo "Setting terminal: urxvt (CPU-based, VirtualBox-friendly)"

# Update the terminal setting in i3 bindings
sed -i "s/set \$terminal .*/set \$terminal $TERMINAL/" ~/.config/i3/bindings.conf

echo "Terminal preference saved: $TERMINAL"