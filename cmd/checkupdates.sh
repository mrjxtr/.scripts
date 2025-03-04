#!/bin/bash

echo -e "Checking for updates...\n"

# Check if required commands exist
check_command() {
    local cmd=$1
    local pkg=$2
    if ! command -v "$cmd" &> /dev/null; then
        echo "Error: '$cmd' command not found."
        echo "Please install it with: $pkg"
        exit 1
    fi
}

# Check for checkupdates (from pacman-contrib package)
check_command "checkupdates" "sudo pacman -S pacman-contrib"

# Check for checkupdates-with-aur (usually from yay or another AUR helper)
check_command "checkupdates-with-aur" "Install an AUR helper like yay (yay -S yay-bin) or paru (yay -S paru-bin)"

# This script combines the output of checkupdates and checkupdates-with-aur
# to create a formatted list of packages to upgrade similar to yay -Syu output

# Get updates from official repositories
official_updates=$(checkupdates 2>/dev/null || echo "")

# Get all updates including AUR
all_updates=$(checkupdates-with-aur 2>/dev/null || echo "")

# Extract AUR-only updates by comparing the two outputs
# This assumes that checkupdates-with-aur includes all official updates plus AUR updates
aur_only_updates=""
if [ -n "$all_updates" ]; then
    # Create a temporary file for each update list
    tmp_official=$(mktemp)
    tmp_all=$(mktemp)
    
    # Write updates to temporary files
    echo "$official_updates" > "$tmp_official"
    echo "$all_updates" > "$tmp_all"
    
    # Extract AUR-only updates (packages in all_updates but not in official_updates)
    aur_only_updates=$(grep -v -f "$tmp_official" "$tmp_all" || echo "")
    
    # Clean up temporary files
    rm -f "$tmp_official" "$tmp_all"
fi

# Function to determine the repository for a package
get_repo() {
    local pkg_name=$1
    # Use pacman to query which repository the package belongs to
    local repo=$(pacman -Si "$pkg_name" 2>/dev/null | grep "Repository" | awk '{print $3}')
    
    # If pacman -Si fails, try pacman -Ss as a fallback
    if [ -z "$repo" ]; then
        repo=$(pacman -Ss "^$pkg_name$" 2>/dev/null | head -1 | cut -d'/' -f1)
    fi
    
    # Default to "extra" if we couldn't determine the repository
    if [ -z "$repo" ]; then
        repo="extra"
    fi
    
    echo "$repo"
}

# Format official updates
if [ -n "$official_updates" ]; then
    while IFS= read -r line; do
        if [[ -z "$line" ]]; then
            continue
        fi
        
        # Extract package name and versions
        pkg_name=$(echo "$line" | cut -d' ' -f1)
        current_ver=$(echo "$line" | cut -d' ' -f2)
        new_ver=$(echo "$line" | cut -d' ' -f4)
        
        # Determine the repository
        repo=$(get_repo "$pkg_name")
        
        # Format based on repository type
        if [ "$repo" = "core" ]; then
            printf "%s  | %-30s %-20s -> %s\n" "$repo" "$pkg_name" "$current_ver" "$new_ver"
        else
            printf "%s | %-30s %-20s -> %s\n" "$repo" "$pkg_name" "$current_ver" "$new_ver"
        fi
    done <<< "$official_updates"
fi

# Format AUR updates
if [ -n "$aur_only_updates" ]; then
    while IFS= read -r line; do
        if [[ -z "$line" ]]; then
            continue
        fi
        
        # Extract package name and versions
        pkg_name=$(echo "$line" | cut -d' ' -f1)
        current_ver=$(echo "$line" | cut -d' ' -f2)
        new_ver=$(echo "$line" | cut -d' ' -f4)
        
        # Format for AUR packages
        printf "aur   | %-30s %-20s -> %s\n" "$pkg_name" "$current_ver" "$new_ver"
    done <<< "$aur_only_updates"
fi

# If no updates were found, inform the user
if [ -z "$official_updates" ] && [ -z "$aur_only_updates" ]; then
    echo "No updates available."
fi
