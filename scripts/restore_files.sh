#!/bin/bash

set -e

# Define the USB mount point (override with USB_MOUNT_POINT env var)
USB_MOUNT_POINT="${USB_MOUNT_POINT:-/media/usb}"

# Check if USB is mounted
if [ ! -d "$USB_MOUNT_POINT" ]; then
    echo "USB drive not found at $USB_MOUNT_POINT. Please mount your USB and try again."
    echo "Tip: Set USB_MOUNT_POINT environment variable to use a different path."
    exit 1
fi

# Define the folders to restore
FOLDERS=("Downloads" "Desktop" "Documents" "Pictures" "Music" "Videos")

# Loop through each folder and copy
for folder in "${FOLDERS[@]}"; do
    SOURCE="$USB_MOUNT_POINT/$folder"
    DESTINATION="$HOME/$folder"

    if [ -d "$SOURCE" ]; then
        echo "Copying $folder..."
        mkdir -p "$DESTINATION"
        cp -r "$SOURCE/." "$DESTINATION/"
        echo "$folder copied successfully."
    else
        echo "Source folder $SOURCE does not exist. Skipping..."
    fi
done

echo "File restoration complete."
