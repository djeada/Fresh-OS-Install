#!/usr/bin/env bash
set -euo pipefail

# ========= config =========
ISO_DIR="$HOME/Downloads/linuxmint-usb"
MINT_VERSION="22.3"
MINT_EDITION="cinnamon"
ISO_NAME="linuxmint-${MINT_VERSION}-${MINT_EDITION}-64bit.iso"
BASE_URL="https://mirrors.kernel.org/linuxmint/stable/${MINT_VERSION}"
ISO_URL="${BASE_URL}/${ISO_NAME}"
SHA_URL="${BASE_URL}/sha256sum.txt"

# ========= sanity =========
mkdir -p "$ISO_DIR"
cd "$ISO_DIR"

echo "==> Installing needed tools"
sudo apt update
sudo apt install -y curl coreutils util-linux gawk grep sed

echo
echo "==> NOTE ABOUT RUFUS"
echo "Rufus is a Windows app, not the native Mint/Linux method."
echo "On Linux Mint, use dd (this script) or Mint's USB Image Writer."
echo

# ========= download & verify ISO =========
echo "==> Downloading official SHA256 file"
curl -fL --retry 5 --retry-delay 3 -o sha256sum.txt "$SHA_URL"

NEED_DOWNLOAD=true
if [[ -f "$ISO_NAME" ]]; then
  echo "==> ISO already exists, verifying checksum"
  if grep " ${ISO_NAME}\$" sha256sum.txt > sha256sum.single.txt &&
     sha256sum -c sha256sum.single.txt; then
    echo "==> Existing ISO checksum is valid, skipping download"
    NEED_DOWNLOAD=false
  else
    echo "==> Existing ISO is incomplete or corrupt, re-downloading"
    rm -f "$ISO_NAME"
  fi
fi

if [[ "$NEED_DOWNLOAD" == true ]]; then
  echo "==> Downloading Linux Mint ISO"
  curl -fL --retry 5 --retry-delay 3 -C - -o "$ISO_NAME" "$ISO_URL"

  echo "==> Verifying ISO checksum against official sha256sum.txt"
  grep " ${ISO_NAME}\$" sha256sum.txt > sha256sum.single.txt
  sha256sum -c sha256sum.single.txt
fi

# ========= select USB device =========
echo
echo "==> Available disks"
lsblk -d -e 7 -o NAME,SIZE,MODEL,TRAN,TYPE
echo
echo "==> Removable-ish candidates"
lsblk -dpno NAME,SIZE,MODEL,TRAN,HOTPLUG | awk '$4=="usb" || $5=="1" {print}'
echo
echo "CAUTION: THIS WILL WIPE THE TARGET USB."
read -rp "Enter target USB device exactly like /dev/sdb : " USBDEV

if [[ ! -b "$USBDEV" ]]; then
  echo "ERROR: $USBDEV is not a block device"
  exit 1
fi

# Guard against accidentally targeting the system disk
SYS_DISK="$(lsblk -npo PKNAME "$(findmnt -no SOURCE /)" 2>/dev/null || true)"
if [[ -n "$SYS_DISK" && "$USBDEV" == "$SYS_DISK" ]]; then
  echo "ERROR: $USBDEV appears to be the system disk – refusing to continue"
  exit 1
fi

echo
echo "==> You chose: $USBDEV"
lsblk "$USBDEV"
echo
read -rp "Type YES to continue and destroy all data on $USBDEV: " CONFIRM
[[ "$CONFIRM" == "YES" ]]

echo "==> Unmounting any mounted partitions on $USBDEV"
while read -r part; do
  sudo umount "$part" 2>/dev/null || true
done < <(lsblk -lnpo NAME "$USBDEV" | tail -n +2)

# ========= write ISO to USB =========
echo "==> Writing ISO to USB (this can take a while)"
sudo dd if="$ISO_NAME" of="$USBDEV" bs=4M status=progress conv=fdatasync

echo "==> Flushing writes"
sync

# ========= post-write verification =========
echo "==> Verifying written data on USB"
ISO_BYTES=$(stat -c%s "$ISO_NAME")
EXPECTED_SHA=$(sha256sum "$ISO_NAME" | awk '{print $1}')
ACTUAL_SHA=$(sudo head -c "$ISO_BYTES" "$USBDEV" | sha256sum | awk '{print $1}')

if [[ "$EXPECTED_SHA" != "$ACTUAL_SHA" ]]; then
  echo "ERROR: USB verification failed – data on $USBDEV does not match the ISO"
  echo "  expected: $EXPECTED_SHA"
  echo "  actual:   $ACTUAL_SHA"
  exit 1
fi
echo "==> USB verification passed"

echo "==> Done."
echo "Boot from $USBDEV in BIOS/UEFI boot menu."
echo
echo "Optional Mint-native GUI method instead of dd:"
echo "  Menu -> Accessories -> USB Image Writer"
echo
echo "Rufus note:"
echo "  If you really want Rufus, use a Windows machine and the Rufus EXE there."
