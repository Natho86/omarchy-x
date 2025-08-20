# Test Configurations for Omarchy-X

This directory contains test configurations that can be applied to a running Omarchy-X installation without reinstalling.

## Quick Test Application

Run this command in your VM to apply test configurations:

```bash
# Apply test configs
cp -r /home/nath/.local/share/omarchy/test-configs/. ~/

# Reload X resources for urxvt
xrdb -merge ~/.Xresources

# Restart polybar
killall polybar
~/.config/polybar/launch.sh &

# Restart i3 to apply changes
i3-msg restart
```

## Test Files Included

- `urxvt-minimal.xresources` - Minimal urxvt config for testing terminal issues
- `polybar-test.ini` - Test polybar configuration
- `rofi-config-fix/` - Fixed rofi configuration files

## Reverting Changes

To revert back to the installed configuration:
```bash
# Remove test configs and relink to defaults
rm ~/.Xresources
ln -snf ~/.config/omarchy/current/theme/urxvt.xresources ~/.Xresources
xrdb -merge ~/.Xresources
i3-msg restart
```