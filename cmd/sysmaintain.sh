#!/bin/bash
# Exit on error and undefined variables
set -eu

# Trap errors and print the line number where they occur
trap 'echo "Error on line $LINENO"' ERR

# Function to prompt the user with a default answer of "yes"
confirm() {
    local prompt_msg=$'\n'"$1"
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

# Function to print section headers
print_header() {
    echo -e "\n==== $1 ===="
}

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to show disk space (avoids duplicate entries)
show_disk_space() {
    print_header "Disk Space"
    df -h / | grep -v tmpfs
}

# Check for required commands
for cmd in timeshift pacman yay paccache grub-mkconfig journalctl; do
    if ! command_exists "$cmd"; then
        echo "Error: Required command '$cmd' not found"
        exit 1
    fi
done

# Ensure script is run with sudo privileges
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run with sudo privileges"
    exit 1
fi

print_header "Starting Arch Linux System Maintenance"

# Show initial disk space
show_disk_space

if confirm "Create Timeshift Backup?"; then
    print_header "Creating Timeshift Backup"
    if ! timeshift --create --comments "System Maintenance Automated Backup"; then
        echo "Error: Timeshift backup failed"
        exit 1
    fi
fi

if confirm "Update System? (Pacman)"; then
    print_header "Updating System"
    if ! pacman -Syu --noconfirm; then
        echo "Error: System update failed"
        exit 1
    fi
fi

if confirm "Update AUR Packages?"; then
    print_header "Updating AUR Packages"
    if ! yay -Syu --noconfirm; then
        echo "Warning: AUR update failed"
        # Don't exit here as AUR updates are not critical
    fi
fi

if confirm "Remove Orphaned Package Files?"; then
    print_header "Removing Orphaned Package Files"
    # Keep the last 3 versions of each package
    if ! paccache -rk3; then
        echo "Warning: Package cache cleanup failed"
    fi
fi

# Check and remove orphan packages if any exist
print_header "Checking for Orphaned Packages"
orphans=$(pacman -Qtdq 2>/dev/null || echo "")
if [ -n "$orphans" ]; then
    echo "Found orphaned packages:"
    echo "$orphans" | tr '\n' ' '
    echo
    if confirm "Remove these orphaned packages?"; then
        print_header "Removing Orphaned Packages"
        # Use xargs to safely handle the package list
        if ! echo "$orphans" | xargs -r pacman -Rns --noconfirm; then
            echo "Error: Failed to remove orphaned packages"
            exit 1
        fi
    fi
else
    echo "No orphan packages found."
fi

if confirm "Update Grub Boot Loader?"; then
    print_header "Updating Grub Boot Loader"
    if ! grub-mkconfig -o /boot/grub/grub.cfg; then
        echo "Error: Grub update failed"
        exit 1
    fi
fi

if confirm "Clear Home Directory Cache?"; then
    print_header "Clearing Home Directory Cache"
    # Get the actual user's home directory
    REAL_USER=$(logname 2>/dev/null || echo $SUDO_USER)
    REAL_HOME=$(eval echo ~$REAL_USER)
    
    echo "Clearing cache for user: $REAL_USER"
    # More selective cache clearing - only files older than 30 days
    if [ -d "$REAL_HOME/.cache" ]; then
        find "$REAL_HOME/.cache" -type f -atime +30 -delete 2>/dev/null || true
        echo "Cleared files older than 30 days from $REAL_HOME/.cache"
    else
        echo "Cache directory not found for $REAL_USER"
    fi
fi

if confirm "Clear System Journal?"; then
    print_header "Clearing System Journal"
    # Keep only last 7 days and limit size to 500M
    if ! journalctl --vacuum-time=7d --vacuum-size=500M; then
        echo "Warning: Journal cleanup failed"
    fi
fi

# Check for system Status and Errors
if confirm "Show System Status and Errors?"; then
    print_header "System Status"
    systemctl --failed --no-pager
    print_header "Recent system errors (last 10):"
    journalctl -p 3 -b --no-pager | tail -n 10
fi

# Show final disk space and space saved
show_disk_space

print_header "Finished Arch Linux System Maintenance"
