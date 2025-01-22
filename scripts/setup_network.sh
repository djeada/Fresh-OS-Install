#!/bin/bash

# Function to check network connectivity
check_network() {
    echo "Checking network connectivity..."
    nmcli device status
}

# Function to check open ports
check_open_ports() {
    echo "Listing open ports..."
    sudo ss -tuln
}

# Function to configure UFW
configure_firewall() {
    echo "Configuring UFW Firewall..."

    # Enable UFW
    sudo ufw enable

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
}

# Execute functions
check_network
echo "----------------------------"
check_open_ports
echo "----------------------------"
configure_firewall
echo "Network configuration complete."
