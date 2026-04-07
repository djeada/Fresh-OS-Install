#!/bin/bash

set -e

# Function to check if a command exists
require_tool() {
    if ! command -v "$1" &> /dev/null; then
        echo "Error: $1 is not installed. Please install it first."
        return 1
    fi
}

# Function to check network connectivity
check_network() {
    echo "Checking network connectivity..."
    require_tool nmcli || return 1
    nmcli device status
}

# Function to check open ports
check_open_ports() {
    echo "Listing open ports..."
    require_tool ss || return 1
    sudo ss -tuln
}

# Function to configure UFW
configure_firewall() {
    echo "Configuring UFW Firewall..."
    require_tool ufw || return 1

    read -rp "This will enable UFW and configure firewall rules. Continue? [y/N]: " confirm
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        echo "Firewall configuration skipped."
        return 0
    fi

    # Enable UFW
    sudo ufw --force enable

    # Set default policies
    sudo ufw default deny incoming
    sudo ufw default allow outgoing

    # Allow necessary ports
    sudo ufw allow ssh
    sudo ufw allow http
    sudo ufw allow https

    # Reload UFW to apply changes
    sudo ufw reload

    echo "Firewall configured successfully."
    echo "----------------------------"
    echo "Current UFW status:"
    sudo ufw status verbose
}

# Execute functions
check_network
echo "----------------------------"
check_open_ports
echo "----------------------------"
configure_firewall
echo "Network configuration complete."
