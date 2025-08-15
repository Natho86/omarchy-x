# Omarchy-X Conversion Plan: Hyprland/Wayland → i3/Xorg

## Executive Summary
Convert Omarchy (Hyprland/Wayland) to Omarchy-X (i3/Xorg) for VirtualBox compatibility while maintaining the one-script installation philosophy and feature parity.

## Component Replacement Mapping

### Core Desktop Environment
| Wayland Component | Xorg Replacement | Notes |
|------------------|------------------|-------|
| **Hyprland** | **i3 + picom** | Window manager + compositor |
| **UWSM** | **Standard X11 session** | Remove session manager |
| **xdg-desktop-portal-hyprland** | **xdg-desktop-portal-gtk** | Desktop integration |

### Status Bar & Interface
| Wayland Component | Xorg Replacement | Notes |
|------------------|------------------|-------|
| **Waybar** | **Polybar** | Status bar (better theming than i3status-rust) |
| **Walker** | **Rofi** | Application launcher |
| **Mako** | **Dunst** | Notifications |

### Screen Management & Effects
| Wayland Component | Xorg Replacement | Notes |
|------------------|------------------|-------|
| **Hyprlock** | **i3lock-color** | Screen lock |
| **Hypridle** | **xss-lock + xidlehook** | Idle management |
| **Hyprsunset** | **Redshift** | Blue light filter |
| **Hyprshot** | **Flameshot** | Screenshots |
| **Slurp + Satty** | **Flameshot** | Area selection + annotation |
| **Hyprpicker** | **Gpick** or **xcolor** | Color picker |
| **swaybg** | **feh** | Wallpaper management |

### Media & Recording
| Wayland Component | Xorg Replacement | Notes |
|------------------|------------------|-------|
| **wf-recorder/wl-screenrec** | **SimpleScreenRecorder** | Screen recording |
| **SwayOSD** | **dunst + volume scripts** | Volume/brightness OSD |

### Clipboard & Input
| Wayland Component | Xorg Replacement | Notes |
|------------------|------------------|-------|
| **wl-clip-persist** | **xclip + clipit** | Clipboard management |
| **wl-copy** | **xclip** | Copy to clipboard |

### Display Management
| Wayland Component | Xorg Replacement | Notes |
|------------------|------------------|-------|
| **Seamless login via UWSM** | **LightDM + autologin** | Display manager |

## Implementation Phases

### Phase 1: Core Infrastructure ✅ IN PROGRESS
1. **Install Script Creation**
   - ✅ Create `install/desktop/i3-desktop.sh` replacing `hyprlandia.sh`
   - ✅ Update `install/desktop/desktop.sh` for X11 tools
   - ⏳ Modify `install/config/login.sh` for LightDM setup

2. **Default Configuration Templates**
   - ✅ Create `default/i3/config`
   - ✅ Create `default/polybar/config.ini` 
   - ✅ Create `default/picom.conf`
   - ⏳ Create `default/dunst/dunstrc`
   - ⏳ Create `default/rofi/config.rasi`

### Phase 2: Theme System Overhaul 
1. **Theme Structure Changes**
   - Replace `hyprland.conf` → `i3.conf` + `picom.conf` 
   - Replace `waybar.css` → `polybar.ini`
   - Replace `mako.ini` → `dunst` config
   - Keep `alacritty.toml`, `btop.theme`, `neovim.lua` (compatible)

2. **Theme Switching Logic**
   - Update `omarchy-theme-set` for i3/polybar/dunst
   - Modify symlink paths and restart commands
   - Update background setting mechanism

### Phase 3: Binary Commands & Utilities
1. **Replace Hypr-specific Commands**
   - `omarchy-restart-waybar` → `omarchy-restart-polybar`
   - `omarchy-refresh-hyprland` → `omarchy-refresh-i3`
   - `omarchy-lock-screen` → Use i3lock-color
   - `omarchy-cmd-screenshot` → Use flameshot
   - `omarchy-restart-app` → Remove uwsm dependency

2. **New X11-specific Commands**
   - `omarchy-refresh-picom`
   - `omarchy-restart-dunst`
   - `omarchy-refresh-rofi`

### Phase 4: Session & Login Management
1. **Display Manager Setup**
   - Replace seamless login with LightDM autologin
   - Create X11 session files
   - Update Plymouth integration
   - Configure proper X11 startup

2. **Environment Setup**
   - Update environment variables for X11
   - Configure DISPLAY and XAUTHORITY
   - Set up proper X11 input methods

### Phase 5: Testing & Validation
1. **Installation Testing**
   - Fresh Arch VM installation
   - VirtualBox compatibility verification
   - Theme switching functionality
   - All binary commands

2. **Migration Support**
   - Create migration from Hyprland to i3
   - Backup and restore mechanisms
   - Rollback capabilities

## Technical Requirements

### Package Changes
**Remove:** hyprland, hyprshot, hyprpicker, hyprlock, hypridle, hyprsunset, walker-bin, waybar, mako, swaybg, swayosd, xdg-desktop-portal-hyprland, uwsm, slurp, satty, wf-recorder, wl-screenrec, wl-clip-persist

**Add:** i3, picom, polybar, rofi, dunst, i3lock-color, xss-lock, xidlehook, redshift, flameshot, gpick, feh, simplescreenrecorder, xclip, clipit, lightdm, lightdm-gtk-greeter

### Configuration Structure Changes
```
~/.config/
├── i3/config (symlink to theme)
├── polybar/config.ini (symlink to theme)  
├── picom/picom.conf (symlink to theme)
├── dunst/dunstrc (symlink to theme)
├── rofi/config.rasi (symlink to theme)
└── omarchy/current/theme/
    ├── i3.conf
    ├── polybar.ini
    ├── picom.conf
    ├── dunst
    └── rofi.rasi
```

### Key Files to Modify
- `install.sh` - Update phase 3 (desktop installation)
- `install/desktop/hyprlandia.sh` → `install/desktop/i3-desktop.sh`
- `install/desktop/desktop.sh` - Replace Wayland tools
- `install/config/login.sh` - LightDM instead of seamless login
- All theme directories - Replace Wayland configs
- 47 binary commands need updates for X11 equivalents

### VirtualBox Optimizations
- Ensure guest additions compatibility
- Configure appropriate graphics drivers
- Optimize for VM performance
- Test multi-monitor setup in VM

## Success Criteria
- ✅ One-command installation works in VirtualBox
- ✅ Feature parity with Hyprland version
- ✅ Theme switching maintains visual consistency  
- ✅ All keyboard shortcuts work equivalently
- ✅ Screenshots, screen recording, color picker functional
- ✅ Notification system maintains behavior
- ✅ Application launcher maintains functionality
- ✅ System performance suitable for VM environment

## Risk Mitigation
- Maintain parallel branches during development
- Comprehensive testing in clean VMs
- Document fallback procedures
- Create automated testing scripts
- Establish rollback mechanisms for migrations