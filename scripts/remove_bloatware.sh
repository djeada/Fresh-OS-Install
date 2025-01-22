#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Function to display messages
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

# Ensure the script is run with superuser privileges
if [[ "$EUID" -ne 0 ]]; then
    log "Please run this script with sudo or as root."
    exit 1
fi

# Define arrays of packages to remove

# Font packages to purge
FONTS_TO_PURGE=(
    "fonts-kacst"
    "fonts-kacst-one"
    "fonts-khmeros-core"
    "fonts-lklug-sinhala"
    "fonts-guru"
    "fonts-nanum"
    "fonts-noto-cjk"
    "fonts-takao-pgothic"
    "fonts-tibetan-machine"
    "fonts-guru-extra"
    "fonts-lao"
    "fonts-sil-padauk"
    "fonts-sil-abyssinica"
    "fonts-tlwg-*"
    "fonts-lohit-*"
    "fonts-beng"
    "fonts-beng-extra"
    "fonts-gargi"
    "fonts-gubbi"
    "fonts-gujr"
    "fonts-gujr-extra"
    "fonts-kalapi"
    "fonts-lohit-gujr"
    "fonts-samyak-*"
    "fonts-noto-unhinted"
    "fonts-noto-hinted"
    "fonts-navilu"
    "fonts-nakula"
    "fonts-orya-extra"
    "fonts-pagul"
    "fonts-sahadeva"
    "fonts-sarai"
    "fonts-smc"
    "fonts-telu-extra"
    "fonts-wqy-microhei"
)

# Bloatware packages to remove
BLOATWARE=(
    "rhythmbox"
    "thunderbird"
    "cheese"
    "evolution"
    "transmission"
    "banshee"
    "pix"
    "pix-data"
    "libreoffice"  # Added LibreOffice to the bloatware list
    # Add more package names here as needed
)

# Additional specific package removals
SPECIFIC_PURGES=(
    "thunderbird-gnome-support"
    "thunderbird-locale-en"
    "thunderbird-locale-en-us"
)

# Function to purge font packages
purge_fonts() {
    log "Purging specified font packages..."
    sudo apt purge -y "${FONTS_TO_PURGE[@]}" || log "Some font packages could not be purged."
}

# Function to remove specific packages
remove_specific_packages() {
    log "Removing specific packages..."
    sudo apt purge -y "${SPECIFIC_PURGES[@]}" || log "Some specific packages could not be purged."
}

# Function to remove bloatware
remove_bloatware() {
    log "Removing bloatware..."
    for package in "${BLOATWARE[@]}"; do
        if dpkg -l | grep -qw "$package"; then
            log "Removing $package..."
            sudo apt remove --purge -y "$package" || log "Failed to remove $package."
        else
            log "$package is not installed. Skipping..."
        fi
    done
}

# Function to clean up the system
cleanup_system() {
    log "Running autoremove and clean..."
    sudo apt autoremove -y || log "Autoremove encountered issues."
    sudo apt clean || log "Failed to clean the package cache."
}

# Function to update package lists
update_package_lists() {
    log "Updating package lists..."
    sudo apt update || { log "Failed to update package lists."; exit 1; }
}

# Function to upgrade installed packages
upgrade_packages() {
    log "Upgrading installed packages..."
    sudo apt upgrade -y || log "Failed to upgrade some packages."
}

# Function to display summary
display_summary() {
    log "Bloatware removal and system cleanup complete."
    log "It's recommended to reboot your system to apply all changes."
}

# Main script execution
main() {
    log "Starting bloatware removal script."

    update_package_lists
    upgrade_packages

    purge_fonts
    remove_specific_packages
    remove_bloatware
    cleanup_system

    display_summary
}

# Run the main function
main
