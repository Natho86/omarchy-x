#!/bin/bash

# Terminal selection for Omarchy-X
echo "Choose your terminal emulator:"
echo "1. urxvt (recommended for VirtualBox - CPU-based, fast)"
echo "2. alacritty (GPU-accelerated, may have VirtualBox issues)"
echo ""

while true; do
    read -p "Enter your choice (1-2, default: 1): " choice
    case $choice in
        "" | "1" | "urxvt")
            TERMINAL="urxvt"
            echo "Selected: urxvt (CPU-based, VirtualBox-friendly)"
            break
            ;;
        "2" | "alacritty")
            TERMINAL="alacritty"
            echo "Selected: alacritty (GPU-accelerated)"
            break
            ;;
        *)
            echo "Invalid choice. Please enter 1 or 2."
            ;;
    esac
done

# Update the terminal setting in i3 bindings
sed -i "s/set \$terminal .*/set \$terminal $TERMINAL/" ~/.config/i3/bindings.conf

echo "Terminal preference saved: $TERMINAL"