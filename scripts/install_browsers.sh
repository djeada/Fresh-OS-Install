#!/bin/bash

echo "Updating package lists..."
sudo apt update

# Install Firefox
echo "Installing Firefox..."
sudo apt install -y firefox

# Install Brave Browser
echo "Installing Brave Browser..."

# Install prerequisites
sudo apt install -y apt-transport-https curl

# Add Brave's GPG key
curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg

# Add Brave repository
echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main" | sudo tee /etc/apt/sources.list.d/brave-browser-release.list

# Update and install Brave
sudo apt update
sudo apt install -y brave-browser

echo "Browsers installed successfully."
