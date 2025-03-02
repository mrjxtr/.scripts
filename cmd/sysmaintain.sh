#!/bin/bash
set -e

# Function to prompt the user with a default answer of "yes"
confirm() {
    local prompt_msg="$1"
    local answer
    read -p "$prompt_msg (Y/n): " -n 1 answer
    echo
    # Default to Yes if no input is given
    answer=${answer:-Y}
    if [[ $answer =~ ^[Yy]$ ]]; then
        return 0
    else
        return 1
    fi
}

echo "Starting Arch Linux System Maintenance"

if confirm "Create Timeshift Backup?"; then
    echo "Creating Timeshift Backup"
    sudo timeshift --create --comments "System Maintenance Automated Backup"
else
    echo "Skipping Timeshift Backup"
fi

if confirm "Update System?"; then
    echo "Updating System"
    sudo pacman -Syu --noconfirm
else
    echo "Skipping System Update"
fi

if confirm "Update AUR Packages?"; then
    echo "Updating AUR Packages"
    yay -Syu --noconfirm
else
    echo "Skipping AUR Update"
fi

if confirm "Remove Orphaned Package Files?"; then
    echo "Removing Orphaned Package Files"
    sudo paccache -r
else
    echo "Skipping Orphaned Package Files removal"
fi

# Check and remove orphan packages if any exist
orphans=$(pacman -Qtdq)
if [ -n "$orphans" ]; then
    if confirm "Remove Orphaned Packages?"; then
        echo "Removing Orphaned Packages"
        sudo pacman -Rns $orphans
    else
        echo "Skipping Orphaned Package removal"
    fi
else
    echo "No orphan packages found."
fi

if confirm "Update Grub Boot Loader?"; then
    echo "Updating Grub Boot Loader"
    sudo grub-mkconfig -o /boot/grub/grub.cfg
else
    echo "Skipping Grub Update"
fi

if confirm "Clear Home Directory Cache?"; then
    echo "Clearing Home Directory Cache"
    rm -rf ~/.cache/*
else
    echo "Skipping Home Cache clearance"
fi

if confirm "Clear System Journal?"; then
    echo "Clearing System Journal"
    sudo journalctl --vacuum-time=7d
else
    echo "Skipping Journal clearance"
fi

echo "Finished Arch Linux System Maintenance"
