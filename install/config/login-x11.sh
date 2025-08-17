#!/bin/bash

# LightDM setup for X11 instead of seamless Hyprland login
if ! command -v lightdm &>/dev/null || ! command -v plymouth &>/dev/null; then
  yay -S --noconfirm --needed lightdm lightdm-gtk-greeter plymouth
fi

# ==============================================================================
# PLYMOUTH SETUP
# ==============================================================================

if ! grep -Eq '^HOOKS=.*plymouth' /etc/mkinitcpio.conf; then
  # Backup original mkinitcpio.conf just in case
  backup_timestamp=$(date +"%Y%m%d%H%M%S")
  sudo cp /etc/mkinitcpio.conf "/etc/mkinitcpio.conf.bak.${backup_timestamp}"

  # Add plymouth to HOOKS array after 'base udev' or 'base systemd'
  if grep "^HOOKS=" /etc/mkinitcpio.conf | grep -q "base systemd"; then
    sudo sed -i '/^HOOKS=/s/base systemd/base systemd plymouth/' /etc/mkinitcpio.conf
  elif grep "^HOOKS=" /etc/mkinitcpio.conf | grep -q "base udev"; then
    sudo sed -i '/^HOOKS=/s/base udev/base udev plymouth/' /etc/mkinitcpio.conf
  else
    echo "Couldn't add the Plymouth hook"
  fi

  # Regenerate initramfs
  sudo mkinitcpio -P
fi

# Add kernel parameters for Plymouth
if [ -d "/boot/loader/entries" ]; then # systemd-boot
  echo "Detected systemd-boot"

  for entry in /boot/loader/entries/*.conf; do
    if [ -f "$entry" ]; then
      # Skip fallback entries
      if [[ "$(basename "$entry")" == *"fallback"* ]]; then
        echo "Skipped: $(basename "$entry") (fallback entry)"
        continue
      fi

      # Skip if splash it already present for some reason
      if ! grep -q "splash" "$entry"; then
        sudo sed -i '/^options/ s/$/ splash quiet/' "$entry"
      else
        echo "Skipped: $(basename "$entry") (splash already present)"
      fi
    fi
  done
elif [ -f "/etc/default/grub" ]; then # Grub
  echo "Detected grub"

  # Backup GRUB config before modifying
  backup_timestamp=$(date +"%Y%m%d%H%M%S")
  sudo cp /etc/default/grub "/etc/default/grub.bak.${backup_timestamp}"

  # Check if splash is already in GRUB_CMDLINE_LINUX_DEFAULT
  if ! grep -q "GRUB_CMDLINE_LINUX_DEFAULT.*splash" /etc/default/grub; then
    # Get current GRUB_CMDLINE_LINUX_DEFAULT value
    current_cmdline=$(grep "^GRUB_CMDLINE_LINUX_DEFAULT=" /etc/default/grub | cut -d'"' -f2)

    # Add splash and quiet if not present
    new_cmdline="$current_cmdline"
    if [[ ! "$current_cmdline" =~ splash ]]; then
      new_cmdline="$new_cmdline splash"
    fi
    if [[ ! "$current_cmdline" =~ quiet ]]; then
      new_cmdline="$new_cmdline quiet"
    fi

    # Trim any leading/trailing spaces
    new_cmdline=$(echo "$new_cmdline" | xargs)

    sudo sed -i "s/^GRUB_CMDLINE_LINUX_DEFAULT=\".*\"/GRUB_CMDLINE_LINUX_DEFAULT=\"$new_cmdline\"/" /etc/default/grub

    # Regenerate grub config
    sudo grub-mkconfig -o /boot/grub/grub.cfg
  else
    echo "GRUB already configured with splash kernel parameters"
  fi
elif [ -d "/etc/cmdline.d" ]; then # UKI
  echo "Detected a UKI setup"
  # Relying on mkinitcpio to assemble a UKI
  # https://wiki.archlinux.org/title/Unified_kernel_image
  if ! grep -q splash /etc/cmdline.d/*.conf; then
    # Need splash, create the omarchy file
    echo "splash" | sudo tee -a /etc/cmdline.d/omarchy.conf
  fi
  if ! grep -q quiet /etc/cmdline.d/*.conf; then
    # Need quiet, create or append the omarchy file
    echo "quiet" | sudo tee -a /etc/cmdline.d/omarchy.conf
  fi
elif [ -f "/etc/kernel/cmdline" ]; then # UKI Alternate
  # Alternate UKI kernel cmdline location
  echo "Detected a UKI setup"

  # Backup kernel cmdline config before modifying
  backup_timestamp=$(date +"%Y%m%d%H%M%S")
  sudo cp /etc/kernel/cmdline "/etc/kernel/cmdline.bak.${backup_timestamp}"

  current_cmdline=$(cat /etc/kernel/cmdline)

  # Add splash and quiet if not present
  new_cmdline="$current_cmdline"
  if [[ ! "$current_cmdline" =~ splash ]]; then
    new_cmdline="$new_cmdline splash"
  fi
  if [[ ! "$current_cmdline" =~ quiet ]]; then
    new_cmdline="$new_cmdline quiet"
  fi

  # Trim any leading/trailing spaces
  new_cmdline=$(echo "$new_cmdline" | xargs)

  # Write new file
  echo $new_cmdline | sudo tee /etc/kernel/cmdline
else
  echo ""
  echo " None of systemd-boot, GRUB, or UKI detected. Please manually add these kernel parameters:"
  echo "  - splash (to see the graphical splash screen)"
  echo "  - quiet (for silent boot)"
  echo ""
fi

if [ "$(plymouth-set-default-theme)" != "omarchy" ]; then
  sudo cp -r "$SCRIPT_DIR/default/plymouth" /usr/share/plymouth/themes/omarchy/
  sudo plymouth-set-default-theme -R omarchy
fi

# ==============================================================================
# LIGHTDM SETUP
# ==============================================================================

# Configure LightDM for autologin
if [ ! -f /etc/lightdm/lightdm.conf.d/90-omarchy.conf ]; then
  sudo mkdir -p /etc/lightdm/lightdm.conf.d
  cat <<EOF | sudo tee /etc/lightdm/lightdm.conf.d/90-omarchy.conf
[Seat:*]
autologin-user=$USER
autologin-session=omarchy-i3
session-wrapper=/etc/lightdm/Xsession
autologin-user-timeout=0
EOF
fi

# Create Omarchy i3 session file
if [ ! -f /usr/share/xsessions/omarchy-i3.desktop ]; then
  sudo tee /usr/share/xsessions/omarchy-i3.desktop <<'EOF'
[Desktop Entry]
Name=Omarchy i3
Comment=Omarchy i3 Desktop Environment
Exec=omarchy-i3-session
TryExec=omarchy-i3-session
Type=Application
X-LightDM-DesktopName=omarchy-i3
DesktopNames=omarchy-i3
Keywords=tiling;wm;windowmanager;window;manager;omarchy;
EOF
fi

# Create Omarchy i3 startup script
if [ ! -f /usr/local/bin/omarchy-i3-session ]; then
  cat <<'EOF' | sudo tee /usr/local/bin/omarchy-i3-session
#!/bin/bash

# Set up environment
export XDG_SESSION_TYPE=x11
export XDG_CURRENT_DESKTOP=i3

# Ensure omarchy directories exist
mkdir -p ~/.config/omarchy
mkdir -p ~/.config/i3
mkdir -p ~/.config/polybar
mkdir -p ~/.config/picom
mkdir -p ~/.config/dunst
mkdir -p ~/.config/rofi

# If no theme is set, set default theme
if [ ! -L ~/.config/omarchy/current ]; then
    omarchy-theme-set catppuccin 2>/dev/null || true
fi

# Create config symlinks if they don't exist
[ ! -L ~/.config/i3/config ] && ln -sf ~/.local/share/omarchy/default/i3/config ~/.config/i3/config
[ ! -L ~/.config/polybar/config.ini ] && ln -sf ~/.local/share/omarchy/default/polybar/config.ini ~/.config/polybar/config.ini
[ ! -L ~/.config/picom/picom.conf ] && ln -sf ~/.local/share/omarchy/default/picom.conf ~/.config/picom/picom.conf
[ ! -L ~/.config/dunst/dunstrc ] && ln -sf ~/.local/share/omarchy/default/dunst/dunstrc ~/.config/dunst/dunstrc
[ ! -L ~/.config/rofi/config.rasi ] && ln -sf ~/.local/share/omarchy/default/rofi/config.rasi ~/.config/rofi/config.rasi

# Start i3 with default config (it will include theme config via include directive)
exec i3
EOF
  sudo chmod +x /usr/local/bin/omarchy-i3-session
fi

# Remove any old regular i3 session file to avoid confusion
[ -f /usr/share/xsessions/i3.desktop ] && sudo rm -f /usr/share/xsessions/i3.desktop

# Enable and configure LightDM
sudo systemctl enable lightdm.service

# Disable any existing auto-login services that might conflict
sudo systemctl disable getty@tty1.service 2>/dev/null || true
sudo systemctl disable omarchy-seamless-login.service 2>/dev/null || true

echo "LightDM configured for autologin with i3"