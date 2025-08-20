#!/bin/bash

# Test urxvt terminal without picom compositor
# This will help identify if picom is causing the terminal display issues

echo "Testing urxvt without picom compositor..."
echo "This will temporarily disable picom to test if it's causing terminal issues."
echo ""

# Kill picom
echo "Stopping picom..."
killall -q picom
sleep 1

echo "Picom stopped. Now test urxvt terminal:"
echo "1. Open terminal with Alt+Enter"
echo "2. Check if cursor appears correctly"
echo "3. Type commands and see if output displays immediately"
echo "4. Try opening multiple terminals"
echo ""
echo "If urxvt works correctly without picom, then picom config needs fixing."
echo ""
echo "To restart picom when done testing:"
echo "  picom &"
echo ""
echo "To make this change permanent (disable picom autostart):"
echo "  Comment out picom line in ~/.local/share/omarchy/default/i3/autostart.conf"