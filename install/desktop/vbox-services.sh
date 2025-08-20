#!/bin/bash

# Enable VirtualBox guest services for auto-resize and clipboard sharing
# Only run if we're actually in a VirtualBox environment

if systemd-detect-virt | grep -q oracle; then
    echo "VirtualBox environment detected, enabling guest services..."
    
    # Enable and start VBoxService
    sudo systemctl enable vboxservice.service
    sudo systemctl start vboxservice.service
    
    # Load VirtualBox kernel modules
    sudo modprobe vboxguest vboxsf vboxvideo
    
    echo "VirtualBox guest services enabled"
else
    echo "Not running in VirtualBox, skipping guest services setup"
fi