#!/usr/bin/env bash
#
# mint-usb-writer.sh
#
# Downloads, verifies, and writes a Linux Mint ISO to a USB drive.
# Safer defaults:
# - uses newer Mint version by default
# - avoids oflag=direct
# - fails hard on write errors
# - verifies the written USB byte-for-byte
#
# Usage examples:
#   ./mint-usb-writer.sh
#   ./mint-usb-writer.sh --version 22.3 --edition cinnamon
#   ./mint-usb-writer.sh --device /dev/sdb
#   ./mint-usb-writer.sh --dry-run
#
set -euo pipefail

# ──────────────────────────── colours / logging ────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RESET='\033[0m'

log()  { printf "${CYAN}[%s]==> %s${RESET}\n" "$(date +%H:%M:%S)" "$*"; }
warn() { printf "${YELLOW}[%s] WARNING: %s${RESET}\n" "$(date +%H:%M:%S)" "$*" >&2; }
err()  { printf "${RED}[%s] ERROR: %s${RESET}\n" "$(date +%H:%M:%S)" "$*" >&2; }
ok()   { printf "${GREEN}[%s] ✔ %s${RESET}\n" "$(date +%H:%M:%S)" "$*"; }

die() { err "$@"; exit 1; }

# ───────────────────────────── defaults ────────────────────────────────────
MINT_VERSION="22.3"
MINT_EDITION="cinnamon"
USBDEV=""
ISO_DIR="${MINT_USB_ISO_DIR:-$HOME/Downloads/linuxmint-usb}"
MIRROR="${MINT_USB_MIRROR:-https://mirrors.kernel.org/linuxmint/stable}"
SKIP_GPG=false
DRY_RUN=false
SKIP_POST_VERIFY=false

# ───────────────────────────── usage / args ────────────────────────────────
usage() {
  cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Options:
  -v, --version VERSION     Mint version (default: $MINT_VERSION)
  -e, --edition EDITION     Desktop edition (default: $MINT_EDITION)
  -d, --device DEVICE       Target USB block device (e.g. /dev/sdb)
  -o, --output-dir DIR      ISO download dir (default: $ISO_DIR)
  -m, --mirror URL          Mirror base URL (default: $MIRROR)
      --skip-gpg            Skip GPG signature verification
      --skip-post-verify    Skip byte-for-byte USB verification after writing
      --dry-run             Do everything except actual write
  -h, --help                Show this help
EOF
  exit 0
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    -v|--version)          MINT_VERSION="$2"; shift 2 ;;
    -e|--edition)          MINT_EDITION="$2"; shift 2 ;;
    -d|--device)           USBDEV="$2"; shift 2 ;;
    -o|--output-dir)       ISO_DIR="$2"; shift 2 ;;
    -m|--mirror)           MIRROR="$2"; shift 2 ;;
    --skip-gpg)            SKIP_GPG=true; shift ;;
    --skip-post-verify)    SKIP_POST_VERIFY=true; shift ;;
    --dry-run)             DRY_RUN=true; shift ;;
    -h|--help)             usage ;;
    *)                     die "Unknown option: $1 (see --help)" ;;
  esac
done

ISO_NAME="linuxmint-${MINT_VERSION}-${MINT_EDITION}-64bit.iso"
BASE_URL="${MIRROR}/${MINT_VERSION}"
ISO_URL="${BASE_URL}/${ISO_NAME}"
SHA_URL="${BASE_URL}/sha256sum.txt"
GPG_URL="${BASE_URL}/sha256sum.txt.gpg"

# ─────────────────────────── preflight checks ──────────────────────────────
require_cmd() {
  command -v "$1" &>/dev/null || die "'$1' is required but not found. Install it first."
}

for cmd in curl sha256sum lsblk findmnt awk dd stat head sync wipefs; do
  require_cmd "$cmd"
done

if [[ "$SKIP_GPG" == false ]]; then
  require_cmd gpg
fi

if [[ $EUID -ne 0 ]]; then
  log "This script needs sudo for unmount, wipefs, and dd operations."
  sudo -v || die "Cannot obtain sudo privileges."
fi

mkdir -p "$ISO_DIR"
cd "$ISO_DIR"

safe_curl() {
  curl -fSL --retry 5 --retry-delay 3 --retry-connrefused \
       --connect-timeout 15 --max-time 3600 "$@"
}

# ─────────────────────────── sha256 + gpg ──────────────────────────────────
log "Downloading official sha256sum.txt"
safe_curl -o sha256sum.txt "$SHA_URL"

if [[ "$SKIP_GPG" == false ]]; then
  log "Downloading GPG signature for sha256sum.txt"
  if safe_curl -o sha256sum.txt.gpg "$GPG_URL" 2>/dev/null; then
    log "Importing Linux Mint signing key (if not already present)"
    gpg --batch --yes --keyserver hkps://keyserver.ubuntu.com \
        --recv-keys "27DE B156 44C6 B3CF 3BD7 D291 300F 846B A25B AE09" 2>/dev/null || true

    log "Verifying GPG signature of sha256sum.txt"
    if gpg --batch --verify sha256sum.txt.gpg sha256sum.txt 2>/dev/null; then
      ok "GPG signature is valid"
    else
      warn "GPG verification failed"
      read -rp "Continue anyway? [y/N]: " ans
      [[ "${ans,,}" == "y" ]] || die "Aborted by user"
    fi
  else
    warn "Could not download GPG signature; skipping GPG verification"
  fi
else
  warn "GPG verification skipped (--skip-gpg)"
fi

# ───────────────────────── checksum helpers ────────────────────────────────
extract_expected_hash() {
  local target_name="$1"
  local hash=""
  local fname=""

  while IFS= read -r line; do
    [[ -z "$line" ]] && continue
    hash="$(awk '{print $1}' <<< "$line")"
    fname="$(awk '{print $2}' <<< "$line")"
    fname="${fname#\*}"

    if [[ "$fname" == "$target_name" ]]; then
      echo "$hash"
      return 0
    fi
  done < sha256sum.txt

  return 1
}

list_available_isos() {
  while IFS= read -r line; do
    [[ -z "$line" ]] && continue
    local fname
    fname="$(awk '{print $2}' <<< "$line")"
    fname="${fname#\*}"
    [[ -n "$fname" ]] && printf '    %s\n' "$fname" >&2
  done < sha256sum.txt
}

verify_iso_checksum() {
  local expected actual
  expected="$(extract_expected_hash "$ISO_NAME")" || true

  if [[ -z "$expected" ]]; then
    err "Could not find '${ISO_NAME}' in sha256sum.txt"
    err ""
    err "Available ISOs:"
    list_available_isos
    err ""
    err "You asked for: --version ${MINT_VERSION} --edition ${MINT_EDITION}"
    return 1
  fi

  actual="$(sha256sum "$ISO_NAME" | awk '{print $1}')"

  if [[ "$expected" != "$actual" ]]; then
    err "SHA-256 mismatch"
    err "  expected: $expected"
    err "  actual:   $actual"
    return 1
  fi
}

NEED_DOWNLOAD=true
if [[ -f "$ISO_NAME" ]]; then
  log "ISO already exists – verifying checksum"
  if verify_iso_checksum; then
    ok "Existing ISO checksum is valid – skipping download"
    NEED_DOWNLOAD=false
  else
    warn "Existing ISO is incomplete or corrupt – re-downloading"
    rm -f "$ISO_NAME"
  fi
fi

if [[ "$NEED_DOWNLOAD" == true ]]; then
  log "Downloading ${ISO_NAME}"
  safe_curl -C - -o "$ISO_NAME" "$ISO_URL"

  log "Verifying ISO checksum"
  verify_iso_checksum || die "SHA-256 checksum mismatch after download"
  ok "ISO checksum verified"
fi

# ────────────────────────── USB detection / validation ─────────────────────
list_usb_candidates() {
  lsblk -dpno NAME,SIZE,MODEL,TRAN,RM \
    | awk '$4 == "usb" && $5 == "1" { printf "  %-12s %-8s %s\n", $1, $2, $3 }'
}

get_system_disk() {
  local root_source
  root_source="$(findmnt -no SOURCE / 2>/dev/null)" || return
  lsblk -npo PKNAME "$root_source" 2>/dev/null | head -1
}

validate_usb_device() {
  local dev="$1"

  [[ -b "$dev" ]] || die "$dev is not a block device"

  local dev_type
  dev_type="$(lsblk -ndo TYPE "$dev" 2>/dev/null || true)"
  [[ "$dev_type" == "disk" ]] || die "$dev is not a whole-disk device (type=$dev_type)"

  [[ "$dev" != /dev/nvme* ]] || die "$dev looks like an NVMe/system disk – refusing"

  local sys_disk
  sys_disk="$(get_system_disk)"
  if [[ -n "$sys_disk" && "$dev" == "$sys_disk" ]]; then
    die "$dev is the system disk – refusing to continue"
  fi

  local tran
  tran="$(lsblk -ndo TRAN "$dev" 2>/dev/null || true)"
  if [[ "$tran" != "usb" ]]; then
    warn "$dev transport is '${tran:-unknown}', not 'usb'"
    read -rp "Continue anyway? [y/N]: " ans
    [[ "${ans,,}" == "y" ]] || die "Aborted by user"
  fi

  local size_bytes
  size_bytes="$(lsblk -bdno SIZE "$dev" 2>/dev/null || true)"
  if [[ -n "$size_bytes" ]] && (( size_bytes > 137438953472 )); then
    warn "$dev is larger than 128 GiB"
    read -rp "Continue anyway? [y/N]: " ans
    [[ "${ans,,}" == "y" ]] || die "Aborted by user"
  fi
}

if [[ -z "$USBDEV" ]]; then
  echo
  log "Available USB drives:"
  candidates="$(list_usb_candidates)"
  if [[ -z "$candidates" ]]; then
    warn "No removable USB drives detected"
    echo
    log "All non-loop disks:"
    lsblk -d -e 7 -o NAME,SIZE,MODEL,TRAN,RM
  else
    echo "$candidates"
  fi
  echo
  echo "  ⚠  ALL DATA ON THE CHOSEN DEVICE WILL BE DESTROYED"
  echo
  read -rp "  Enter target USB device (e.g. /dev/sdb): " USBDEV
  [[ -n "$USBDEV" ]] || die "No device entered"
fi

validate_usb_device "$USBDEV"

echo
log "Selected device:"
lsblk "$USBDEV"
echo

read -rp "Type YES to wipe ${USBDEV} and write the ISO: " CONFIRM
[[ "$CONFIRM" == "YES" ]] || die "Aborted – you did not type YES"

echo
for i in 5 4 3 2 1; do
  printf "\r  Writing in %d seconds... (Ctrl+C to abort)" "$i"
  sleep 1
done
printf "\n"

# ──────────────────────────── unmount / wipefs ─────────────────────────────
log "Unmounting any mounted partitions on ${USBDEV}"
while IFS= read -r part; do
  if findmnt -rno TARGET "$part" &>/dev/null; then
    sudo umount -l "$part" 2>/dev/null || warn "Could not unmount $part"
  fi
done < <(lsblk -lnpo NAME "$USBDEV" | tail -n +2)

log "Clearing old signatures on ${USBDEV}"
sudo wipefs -a "$USBDEV" >/dev/null || warn "wipefs reported a problem; continuing"

# ─────────────────────────────── write ISO ─────────────────────────────────
if [[ "$DRY_RUN" == true ]]; then
  warn "DRY RUN – skipping write and verification"
else
  log "Writing ${ISO_NAME} → ${USBDEV} (bs=4M, conv=fsync)"
  if ! sudo dd if="$ISO_NAME" of="$USBDEV" bs=4M status=progress conv=fsync; then
    err ""
    err "USB write failed."
    err "Most likely causes:"
    err "  - bad USB stick"
    err "  - bad USB port"
    err "  - flaky front-panel USB connection"
    err ""
    err "Try:"
    err "  1) a rear motherboard USB port"
    err "  2) another USB stick"
    err "  3) checking: sudo dmesg | tail -n 80"
    die "Write failed with I/O error or another device-level error"
  fi

  log "Flushing kernel buffers"
  sync
  ok "Write complete"

  # ───────────────────────── post-write verify ────────────────────────────
  if [[ "$SKIP_POST_VERIFY" == true ]]; then
    warn "Skipping post-write verification (--skip-post-verify)"
  else
    log "Verifying data written to ${USBDEV}"
    ISO_BYTES="$(stat -c%s "$ISO_NAME")"
    EXPECTED_SHA="$(sha256sum "$ISO_NAME" | awk '{print $1}')"

    echo 3 | sudo tee /proc/sys/vm/drop_caches >/dev/null 2>&1 || true
    ACTUAL_SHA="$(sudo head -c "$ISO_BYTES" "$USBDEV" | sha256sum | awk '{print $1}')"

    if [[ "$EXPECTED_SHA" != "$ACTUAL_SHA" ]]; then
      err "USB verification FAILED"
      err "  expected: $EXPECTED_SHA"
      err "  actual:   $ACTUAL_SHA"
      die "The data on ${USBDEV} does not match the ISO – do NOT boot from it"
    fi

    ok "USB verification passed – ${USBDEV} matches the ISO byte-for-byte"
  fi
fi

# ───────────────────────────────── done ────────────────────────────────────
echo
ok "All done!"
cat <<EOF

  ► Boot from ${USBDEV} via your BIOS/UEFI boot menu.

  If boot still fails after a successful write + verify:
    - try a rear motherboard USB port
    - try Compatibility Mode in the Mint boot menu
    - if you have NVIDIA, test one boot with nomodeset

  If write fails again with I/O error:
    - the USB stick is probably bad
    - or the USB port/path is bad

EOF
