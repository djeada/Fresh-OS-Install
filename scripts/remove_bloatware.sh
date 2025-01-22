#!/bin/bash

# List of packages to remove (Add or remove packages as needed)
BLOATWARE=(
    "rhythmbox"
    "thunderbird"
    "cheese"
    "evolution"
    "transmission"
    # Add more package names here
)

echo "Removing bloatware..."

for package in "${BLOATWARE[@]}"; do
    if dpkg -l | grep -qw "$package"; then
        echo "Removing $package..."
        sudo apt remove --purge -y "$package"
    else
        echo "$package is not installed. Skipping..."
    fi
done

# Clean up unnecessary packages
echo "Running autoremove and clean..."
sudo apt autoremove -y
sudo apt clean

echo "Bloatware removal complete."
