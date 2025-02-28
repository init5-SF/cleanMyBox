#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print a separator
print_separator() {
    echo -e "${BLUE}----------------------------------------${NC}"
}

# Function to calculate directory size in bytes
calculate_size_bytes() {
    local path=$1
    if [ -e "$path" ]; then
        size=$(du -sb "$path" 2>/dev/null | awk '{print $1}')
        echo "$size"
    else
        echo "0"
    fi
}

# Function to clean a directory and add to total saved space
clean_directory() {
    local path=$1
    local description=$2
    if [ -e "$path" ]; then
        size=$(calculate_size_bytes "$path")
        echo -e "${YELLOW}Cleaning $description ($path): ${GREEN}$(numfmt --to=iec $size)${NC}"
        sudo rm -rf "$path"/*
        echo -e "${GREEN}  - Cleaned.${NC}"
        TOTAL_SAVED=$((TOTAL_SAVED + size))
    else
        echo -e "${RED}$description ($path) does not exist.${NC}"
    fi
    print_separator
}

# Function to find and delete scattered junk files
clean_scattered_junk() {
    echo -e "${YELLOW}Cleaning scattered junk files (Thumbs.db, .DS_Store)...${NC}"
    # Find and delete Thumbs.db files
    find / -type f -name "Thumbs.db" -exec echo -e "${GREEN}Deleting: {}${NC}" \; -exec rm -f {} \; 2>/dev/null
    # Find and delete .DS_Store files
    find / -type f -name ".DS_Store" -exec echo -e "${GREEN}Deleting: {}${NC}" \; -exec rm -f {} \; 2>/dev/null
    print_separator
}

# Initialize total saved space
TOTAL_SAVED=0

# Get the currently running kernel version
CURRENT_KERNEL=$(uname -r)
echo -e "${BLUE}Currently running kernel: ${GREEN}$CURRENT_KERNEL${NC}"
print_separator

# Get the list of installed kernels (excluding the current one and the meta-package)
INSTALLED_KERNELS=$(dpkg --list | grep '^ii' | grep -E '^linux-image-[0-9]+' | awk '{print $2}' | grep -v "$CURRENT_KERNEL" | grep -v "linux-image-amd64")

# Get the list of removed kernels (rc status)
REMOVED_KERNELS=$(dpkg --list | grep '^rc' | grep -E '^linux-image-[0-9]+' | awk '{print $2}')

# Remove old installed kernels
if [ -n "$INSTALLED_KERNELS" ]; then
    echo -e "${YELLOW}Removing old installed kernels:${NC}"
    echo -e "${GREEN}$INSTALLED_KERNELS${NC}"
    print_separator
    sudo apt remove --purge $INSTALLED_KERNELS
else
    echo -e "${GREEN}No old installed kernels to remove.${NC}"
    print_separator
fi

# Purge removed kernels
if [ -n "$REMOVED_KERNELS" ]; then
    echo -e "${YELLOW}Purging removed kernels:${NC}"
    echo -e "${GREEN}$REMOVED_KERNELS${NC}"
    print_separator
    sudo dpkg --purge $REMOVED_KERNELS
else
    echo -e "${GREEN}No removed kernels to purge.${NC}"
    print_separator
fi

# Clean up leftover files
echo -e "${YELLOW}Cleaning up leftover files...${NC}"
sudo apt autoremove --purge -y
print_separator

# Update GRUB
echo -e "${YELLOW}Updating GRUB...${NC}"
sudo update-grub
print_separator

# Clean Snap Cache
clean_directory "/var/lib/snapd/cache" "Snap Cache"

# Clean Downloads
clean_directory "$HOME/Downloads" "Downloads"

# Clean Orphaned Packages
echo -e "${YELLOW}Cleaning orphaned packages (autoclean)...${NC}"
sudo apt autoclean -y
print_separator

# Clean APT Cache
echo -e "${YELLOW}Cleaning APT cache (apt clean)...${NC}"
APT_CACHE_SIZE=$(calculate_size_bytes "/var/cache/apt/archives")
echo -e "${YELLOW}Cleaning APT cache (/var/cache/apt/archives): ${GREEN}$(numfmt --to=iec $APT_CACHE_SIZE)${NC}"
sudo apt clean
echo -e "${GREEN}  - Cleaned.${NC}"
TOTAL_SAVED=$((TOTAL_SAVED + APT_CACHE_SIZE))
print_separator

# Clean Log Files
clean_directory "/var/log" "Log Files"

# Clean Thumbnail Cache
clean_directory "$HOME/.cache/thumbnails" "Thumbnail Cache"

# Clean /tmp
clean_directory "/tmp" "Temporary Files (/tmp)"

# Clean /var/tmp
clean_directory "/var/tmp" "Temporary Files (/var/tmp)"

# Clean Firefox Cache
clean_directory "$HOME/.cache/mozilla/firefox" "Firefox Cache"

# Clean scattered junk files (Thumbs.db, .DS_Store)
clean_scattered_junk

# Print total saved space
echo -e "${GREEN}Estimated total space saved: $(numfmt --to=iec $TOTAL_SAVED)${NC}"
print_separator

echo -e "${GREEN}System cleanup complete!${NC}"
