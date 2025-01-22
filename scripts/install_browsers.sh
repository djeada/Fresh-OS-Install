#!/bin/bash

set -e

# Color codes for better UI
GREEN="\e[32m"
YELLOW="\e[33m"
RED="\e[31m"
BLUE="\e[34m"
NC="\e[0m" # No Color

# Log file
LOG_FILE="/var/log/browser_manager.log"

# Function to log messages
log() {
    echo -e "$(date +"%Y-%m-%d %T") : $1" | sudo tee -a "$LOG_FILE" > /dev/null
}

# Function to check if script is run as root
check_root() {
    if [ "$EUID" -ne 0 ]; then
        echo -e "${RED}Please run as root or use sudo.${NC}"
        exit 1
    fi
}

# Function to display the main menu
main_menu() {
    clear
    echo -e "${BLUE}====================================${NC}"
    echo -e "${BLUE}      Browser Management Script     ${NC}"
    echo -e "${BLUE}====================================${NC}"
    echo "1) Install Browsers"
    echo "2) Verify Installation"
    echo "3) Purge Browsers"
    echo "4) Update Browsers"
    echo "5) Exit"
    echo -e "${BLUE}====================================${NC}"
    read -rp "Select an option [1-5]: " main_choice
    case $main_choice in
        1) install_menu ;;
        2) verify_installation ;;
        3) purge_browsers ;;
        4) update_browsers ;;
        5) echo "Exiting..."; exit 0 ;;
        *) echo -e "${RED}Invalid option. Please try again.${NC}"; sleep 2; main_menu ;;
    esac
}

# Function to display the install submenu
install_menu() {
    clear
    echo -e "${BLUE}====================================${NC}"
    echo -e "${BLUE}           Install Browsers          ${NC}"
    echo -e "${BLUE}====================================${NC}"
    echo "1) Install Firefox"
    echo "2) Install Brave Browser"
    echo "3) Install Both Firefox and Brave"
    echo "4) Install Additional Tools"
    echo "5) Back to Main Menu"
    echo -e "${BLUE}====================================${NC}"
    read -rp "Select an option [1-5]: " install_choice
    case $install_choice in
        1) install_firefox ;;
        2) install_brave ;;
        3) install_firefox && install_brave ;;
        4) install_additional_tools ;;
        5) main_menu ;;
        *) echo -e "${RED}Invalid option. Please try again.${NC}"; sleep 2; install_menu ;;
    esac
}

# Function to install Firefox
install_firefox() {
    echo -e "${GREEN}Updating package lists...${NC}"
    log "Updating package lists."
    apt update >> "$LOG_FILE" 2>&1

    echo -e "${GREEN}Installing Firefox...${NC}"
    log "Installing Firefox."
    apt install -y firefox >> "$LOG_FILE" 2>&1

    echo -e "${GREEN}Firefox installed successfully.${NC}"
    log "Firefox installation completed."
    pause
    install_menu
}

# Function to install Brave Browser
install_brave() {
    echo -e "${GREEN}Installing Brave Browser...${NC}"
    log "Installing Brave Browser."

    echo -e "${GREEN}Installing prerequisites...${NC}"
    apt install -y apt-transport-https curl gnupg >> "$LOG_FILE" 2>&1

    echo -e "${GREEN}Adding Brave's GPG key...${NC}"
    curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg >> "$LOG_FILE" 2>&1

    echo -e "${GREEN}Adding Brave repository...${NC}"
    echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main" | \
        tee /etc/apt/sources.list.d/brave-browser-release.list > /dev/null

    echo -e "${GREEN}Updating package lists...${NC}"
    apt update >> "$LOG_FILE" 2>&1

    echo -e "${GREEN}Installing Brave Browser...${NC}"
    apt install -y brave-browser >> "$LOG_FILE" 2>&1

    echo -e "${GREEN}Brave Browser installed successfully.${NC}"
    log "Brave Browser installation completed."
    pause
    install_menu
}

# Function to install additional tools (if any)
install_additional_tools() {
    clear
    echo -e "${BLUE}====================================${NC}"
    echo -e "${BLUE}        Install Additional Tools     ${NC}"
    echo -e "${BLUE}====================================${NC}"
    echo "1) Install Vivaldi Browser"
    echo "2) Install Opera Browser"
    echo "3) Back to Install Menu"
    echo -e "${BLUE}====================================${NC}"
    read -rp "Select an option [1-3]: " tool_choice
    case $tool_choice in
        1) install_vivaldi ;;
        2) install_opera ;;
        3) install_menu ;;
        *) echo -e "${RED}Invalid option. Please try again.${NC}"; sleep 2; install_additional_tools ;;
    esac
}

# Function to install Vivaldi Browser
install_vivaldi() {
    echo -e "${GREEN}Installing Vivaldi Browser...${NC}"
    log "Installing Vivaldi Browser."

    echo -e "${GREEN}Installing prerequisites...${NC}"
    apt install -y software-properties-common wget >> "$LOG_FILE" 2>&1

    echo -e "${GREEN}Adding Vivaldi repository...${NC}"
    wget -qO- https://repo.vivaldi.com/archive/linux_signing_key.pub | apt-key add - >> "$LOG_FILE" 2>&1
    add-apt-repository "deb [arch=amd64] https://repo.vivaldi.com/archive/deb/ stable main" >> "$LOG_FILE" 2>&1

    echo -e "${GREEN}Updating package lists...${NC}"
    apt update >> "$LOG_FILE" 2>&1

    echo -e "${GREEN}Installing Vivaldi...${NC}"
    apt install -y vivaldi-stable >> "$LOG_FILE" 2>&1

    echo -e "${GREEN}Vivaldi Browser installed successfully.${NC}"
    log "Vivaldi Browser installation completed."
    pause
    install_additional_tools
}

# Function to install Opera Browser
install_opera() {
    echo -e "${GREEN}Installing Opera Browser...${NC}"
    log "Installing Opera Browser."

    echo -e "${GREEN}Installing prerequisites...${NC}"
    apt install -y gnupg2 software-properties-common wget >> "$LOG_FILE" 2>&1

    echo -e "${GREEN}Adding Opera's GPG key...${NC}"
    wget -qO- https://deb.opera.com/archive.key | apt-key add - >> "$LOG_FILE" 2>&1

    echo -e "${GREEN}Adding Opera repository...${NC}"
    add-apt-repository "deb https://deb.opera.com/opera-stable/ stable non-free" >> "$LOG_FILE" 2>&1

    echo -e "${GREEN}Updating package lists...${NC}"
    apt update >> "$LOG_FILE" 2>&1

    echo -e "${GREEN}Installing Opera Browser...${NC}"
    apt install -y opera-stable >> "$LOG_FILE" 2>&1

    echo -e "${GREEN}Opera Browser installed successfully.${NC}"
    log "Opera Browser installation completed."
    pause
    install_additional_tools
}

# Function to verify browser installations
verify_installation() {
    clear
    echo -e "${BLUE}====================================${NC}"
    echo -e "${BLUE}       Verifying Installations       ${NC}"
    echo -e "${BLUE}====================================${NC}"
    
    # Verify Firefox
    if command -v firefox &> /dev/null; then
        echo -e "${GREEN}Firefox is installed:${NC}"
        firefox --version
    else
        echo -e "${RED}Firefox is not installed.${NC}"
    fi

    # Verify Brave Browser
    if command -v brave-browser &> /dev/null; then
        echo -e "${GREEN}Brave Browser is installed:${NC}"
        brave-browser --version
    else
        echo -e "${RED}Brave Browser is not installed.${NC}"
    fi

    # Verify Vivaldi Browser
    if command -v vivaldi &> /dev/null; then
        echo -e "${GREEN}Vivaldi Browser is installed:${NC}"
        vivaldi --version
    else
        echo -e "${YELLOW}Vivaldi Browser is not installed.${NC}"
    fi

    # Verify Opera Browser
    if command -v opera &> /dev/null; then
        echo -e "${GREEN}Opera Browser is installed:${NC}"
        opera --version
    else
        echo -e "${YELLOW}Opera Browser is not installed.${NC}"
    fi

    echo -e "${BLUE}====================================${NC}"
    log "Verification completed."
    pause
    main_menu
}

# Function to purge browsers
purge_browsers() {
    clear
    echo -e "${RED}====================================${NC}"
    echo -e "${RED}          Purge Browsers             ${NC}"
    echo -e "${RED}====================================${NC}"
    read -rp "Are you sure you want to purge all browsers and related data? [y/N]: " confirm
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}Purging browsers and related packages...${NC}"
        log "Purging browsers and related packages."
        
        # Purge Firefox
        apt-get purge -y firefox >> "$LOG_FILE" 2>&1 || true
        # Purge Brave Browser
        apt-get purge -y brave-browser >> "$LOG_FILE" 2>&1 || true
        # Purge Vivaldi Browser
        apt-get purge -y vivaldi-stable >> "$LOG_FILE" 2>&1 || true
        # Purge Opera Browser
        apt-get purge -y opera-stable >> "$LOG_FILE" 2>&1 || true

        apt-get autoremove -y >> "$LOG_FILE" 2>&1

        # Remove Brave repository and key
        rm -f /etc/apt/sources.list.d/brave-browser-release.list
        rm -f /usr/share/keyrings/brave-browser-archive-keyring.gpg

        # Remove Vivaldi repository and key
        rm -f /etc/apt/sources.list.d/vivaldi.list
        rm -f /etc/apt/trusted.gpg.d/vivaldi.gpg

        # Remove Opera repository and key
        rm -f /etc/apt/sources.list.d/opera.list
        rm -f /etc/apt/trusted.gpg.d/opera.gpg

        echo -e "${GREEN}Browsers purged successfully.${NC}"
        log "Browsers purged successfully."
    else
        echo -e "${YELLOW}Purge operation cancelled.${NC}"
        log "Purge operation cancelled by user."
    fi
    pause
    main_menu
}

# Function to update browsers
update_browsers() {
    echo -e "${GREEN}Updating browsers...${NC}"
    log "Updating browsers."

    echo -e "${GREEN}Updating package lists...${NC}"
    apt update >> "$LOG_FILE" 2>&1

    echo -e "${GREEN}Upgrading installed browsers...${NC}"
    apt install -y firefox brave-browser vivaldi-stable opera-stable >> "$LOG_FILE" 2>&1

    echo -e "${GREEN}Browsers updated successfully.${NC}"
    log "Browsers updated successfully."
    pause
    main_menu
}

# Function to install additional tools (placeholder for future tools)
install_additional_tools() {
    echo -e "${YELLOW}No additional tools available at the moment.${NC}"
    pause
    install_menu
}

# Function to pause the script until user presses Enter
pause() {
    echo
    read -rp "Press Enter to continue..." key
}

# Ensure the script is run as root
check_root

# Ensure log file exists
sudo touch "$LOG_FILE"
sudo chmod 666 "$LOG_FILE"

# Start the script by displaying the main menu
main_menu
