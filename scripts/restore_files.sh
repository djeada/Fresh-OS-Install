#!/bin/bash

# Define the USB mount point
USB_MOUNT_POINT="/media/usb"

# Check if USB is mounted
if [ ! -d "$USB_MOUNT_POINT" ]; then
    echo "USB drive not found at $USB_MOUNT_POINT. Please mount your USB and try again."
    exit 1
fi

# Define the folders to restore
FOLDERS=("Downloads" "Desktop" "Documents")

# Loop through each folder and copy
for folder in "${FOLDERS[@]}"; do
    SOURCE="$USB_MOUNT_POINT/$folder"
    DESTINATION="$HOME/$folder"

    if [ -d "$SOURCE" ]; then
        echo "Copying $folder..."
        cp -r "$SOURCE" "$DESTINATION"
        echo "$folder copied successfully."
    else
        echo "Source folder $SOURCE does not exist. Skipping..."
    fi
done

echo "File restoration complete."
