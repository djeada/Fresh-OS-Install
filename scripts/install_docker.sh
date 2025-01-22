#!/bin/bash

set -e

# Color codes for better UI
GREEN="\e[32m"
YELLOW="\e[33m"
RED="\e[31m"
BLUE="\e[34m"
NC="\e[0m" # No Color

# Log file
LOG_FILE="/var/log/docker_manager.log"

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
    echo -e "${BLUE}      Docker Management Script      ${NC}"
    echo -e "${BLUE}====================================${NC}"
    echo "1) Install Docker"
    echo "2) Verify Installation"
    echo "3) Purge Docker"
    echo "4) Update Docker"
    echo "5) Exit"
    echo -e "${BLUE}====================================${NC}"
    read -rp "Select an option [1-5]: " main_choice
    case $main_choice in
        1) install_menu ;;
        2) verify_installation ;;
        3) purge_docker ;;
        4) update_docker ;;
        5) echo "Exiting..."; exit 0 ;;
        *) echo -e "${RED}Invalid option. Please try again.${NC}"; sleep 2; main_menu ;;
    esac
}

# Function to display the install submenu
install_menu() {
    clear
    echo -e "${BLUE}====================================${NC}"
    echo -e "${BLUE}           Install Docker           ${NC}"
    echo -e "${BLUE}====================================${NC}"
    echo "1) Install Docker Engine"
    echo "2) Install Docker Compose"
    echo "3) Install Docker Engine and Compose"
    echo "4) Install Additional Tools"
    echo "5) Back to Main Menu"
    echo -e "${BLUE}====================================${NC}"
    read -rp "Select an option [1-5]: " install_choice
    case $install_choice in
        1) install_docker ;;
        2) install_docker_compose ;;
        3) install_docker && install_docker_compose ;;
        4) install_additional_tools ;;
        5) main_menu ;;
        *) echo -e "${RED}Invalid option. Please try again.${NC}"; sleep 2; install_menu ;;
    esac
}

# Function to install Docker Engine
install_docker() {
    echo -e "${GREEN}Updating package lists...${NC}"
    log "Updating package lists."
    apt update >> "$LOG_FILE" 2>&1

    echo -e "${GREEN}Installing prerequisites...${NC}"
    log "Installing prerequisites."
    apt install -y apt-transport-https ca-certificates curl gnupg lsb-release >> "$LOG_FILE" 2>&1

    echo -e "${GREEN}Adding Docker GPG key...${NC}"
    log "Adding Docker GPG key."
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg >> "$LOG_FILE" 2>&1

    echo -e "${GREEN}Setting up Docker repository...${NC}"
    log "Setting up Docker repository."
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] \
https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | \
    tee /etc/apt/sources.list.d/docker.list > /dev/null

    echo -e "${GREEN}Updating package lists...${NC}"
    log "Updating package lists after adding Docker repo."
    apt update >> "$LOG_FILE" 2>&1

    echo -e "${GREEN}Installing Docker Engine...${NC}"
    log "Installing Docker Engine."
    apt install -y docker-ce docker-ce-cli containerd.io >> "$LOG_FILE" 2>&1

    echo -e "${GREEN}Adding user $SUDO_USER to the docker group...${NC}"
    log "Adding user $SUDO_USER to docker group."
    usermod -aG docker "$SUDO_USER" >> "$LOG_FILE" 2>&1

    echo -e "${GREEN}Docker Engine installed successfully.${NC}"
    echo -e "${YELLOW}You may need to log out and log back in for group changes to take effect.${NC}"
    log "Docker Engine installation completed."
    pause
    main_menu
}

# Function to install Docker Compose
install_docker_compose() {
    echo -e "${GREEN}Installing Docker Compose...${NC}"
    log "Installing Docker Compose."

    # Get the latest Docker Compose version
    COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep -Po '"tag_name": "\K.*?(?=")')
    if [ -z "$COMPOSE_VERSION" ]; then
        echo -e "${RED}Failed to fetch Docker Compose version.${NC}"
        log "Failed to fetch Docker Compose version."
        pause
        main_menu
    fi

    echo -e "${GREEN}Latest Docker Compose version: $COMPOSE_VERSION${NC}"
    log "Latest Docker Compose version: $COMPOSE_VERSION"

    echo -e "${GREEN}Downloading Docker Compose...${NC}"
    curl -L "https://github.com/docker/compose/releases/download/${COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose >> "$LOG_FILE" 2>&1

    echo -e "${GREEN}Applying executable permissions...${NC}"
    chmod +x /usr/local/bin/docker-compose >> "$LOG_FILE" 2>&1

    echo -e "${GREEN}Creating symbolic link to /usr/bin...${NC}"
    ln -sf /usr/local/bin/docker-compose /usr/bin/docker-compose >> "$LOG_FILE" 2>&1

    echo -e "${GREEN}Docker Compose installed successfully.${NC}"
    docker-compose --version
    log "Docker Compose installation completed."
    pause
    main_menu
}

# Function to install additional Docker tools
install_additional_tools() {
    clear
    echo -e "${BLUE}====================================${NC}"
    echo -e "${BLUE}        Install Additional Tools     ${NC}"
    echo -e "${BLUE}====================================${NC}"
    echo "1) Install Docker Machine"
    echo "2) Install Portainer"
    echo "3) Install Docker Swarm"
    echo "4) Back to Install Menu"
    echo -e "${BLUE}====================================${NC}"
    read -rp "Select an option [1-4]: " tool_choice
    case $tool_choice in
        1) install_docker_machine ;;
        2) install_portainer ;;
        3) install_docker_swarm ;;
        4) install_menu ;;
        *) echo -e "${RED}Invalid option. Please try again.${NC}"; sleep 2; install_additional_tools ;;
    esac
}

# Function to install Docker Machine
install_docker_machine() {
    echo -e "${GREEN}Installing Docker Machine...${NC}"
    log "Installing Docker Machine."

    DOCKER_MACHINE_VERSION="v0.16.2"
    curl -L "https://github.com/docker/machine/releases/download/${DOCKER_MACHINE_VERSION}/docker-machine-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-machine >> "$LOG_FILE" 2>&1
    chmod +x /usr/local/bin/docker-machine >> "$LOG_FILE" 2>&1

    echo -e "${GREEN}Docker Machine installed successfully.${NC}"
    docker-machine version
    log "Docker Machine installation completed."
    pause
    install_additional_tools
}

# Function to install Portainer
install_portainer() {
    echo -e "${GREEN}Installing Portainer...${NC}"
    log "Installing Portainer."

    docker volume create portainer_data >> "$LOG_FILE" 2>&1
    docker run -d -p 9000:9000 --name portainer \
        --restart=always \
        -v /var/run/docker.sock:/var/run/docker.sock \
        -v portainer_data:/data \
        portainer/portainer-ce >> "$LOG_FILE" 2>&1

    echo -e "${GREEN}Portainer installed successfully and is accessible at http://localhost:9000${NC}"
    log "Portainer installation completed."
    pause
    install_additional_tools
}

# Function to install Docker Swarm
install_docker_swarm() {
    echo -e "${GREEN}Initializing Docker Swarm...${NC}"
    log "Initializing Docker Swarm."

    docker swarm init >> "$LOG_FILE" 2>&1 || {
        echo -e "${YELLOW}Docker Swarm is already initialized.${NC}"
        log "Docker Swarm initialization skipped; already initialized."
    }

    echo -e "${GREEN}Docker Swarm initialized successfully.${NC}"
    docker node ls
    log "Docker Swarm status displayed."
    pause
    install_additional_tools
}

# Function to verify Docker installation
verify_installation() {
    clear
    echo -e "${BLUE}====================================${NC}"
    echo -e "${BLUE}       Verifying Installation       ${NC}"
    echo -e "${BLUE}====================================${NC}"
    if command -v docker &> /dev/null; then
        echo -e "${GREEN}Docker is installed:${NC}"
        docker --version
    else
        echo -e "${RED}Docker is not installed.${NC}"
    fi

    if command -v docker-compose &> /dev/null; then
        echo -e "${GREEN}Docker Compose is installed:${NC}"
        docker-compose --version
    else
        echo -e "${RED}Docker Compose is not installed.${NC}"
    fi

    if command -v docker-machine &> /dev/null; then
        echo -e "${GREEN}Docker Machine is installed:${NC}"
        docker-machine version
    else
        echo -e "${YELLOW}Docker Machine is not installed.${NC}"
    fi

    if docker ps &> /dev/null; then
        echo -e "${GREEN}Docker daemon is running.${NC}"
    else
        echo -e "${RED}Docker daemon is not running.${NC}"
    fi

    echo -e "${BLUE}====================================${NC}"
    log "Verification completed."
    pause
    main_menu
}

# Function to purge Docker
purge_docker() {
    clear
    echo -e "${RED}====================================${NC}"
    echo -e "${RED}          Purge Docker               ${NC}"
    echo -e "${RED}====================================${NC}"
    read -rp "Are you sure you want to purge Docker and all related data? [y/N]: " confirm
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}Purging Docker and related packages...${NC}"
        log "Purging Docker and related packages."
        apt-get purge -y docker-ce docker-ce-cli containerd.io docker-compose docker-machine portainer.io >> "$LOG_FILE" 2>&1 || true
        apt-get autoremove -y >> "$LOG_FILE" 2>&1
        rm -rf /var/lib/docker
        rm -rf /etc/docker
        rm -f /etc/apt/sources.list.d/docker.list
        rm -f /usr/share/keyrings/docker-archive-keyring.gpg
        rm -f /usr/local/bin/docker-compose
        rm -f /usr/local/bin/docker-machine
        rm -f /usr/bin/docker-compose
        echo -e "${GREEN}Docker purged successfully.${NC}"
        log "Docker purged successfully."
    else
        echo -e "${YELLOW}Purge operation cancelled.${NC}"
        log "Purge operation cancelled by user."
    fi
    pause
    main_menu
}

# Function to update Docker
update_docker() {
    echo -e "${GREEN}Updating Docker Engine and Compose...${NC}"
    log "Updating Docker Engine and Compose."

    # Update package lists
    apt update >> "$LOG_FILE" 2>&1

    # Upgrade Docker packages
    apt install -y docker-ce docker-ce-cli containerd.io >> "$LOG_FILE" 2>&1

    # Update Docker Compose
    COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep -Po '"tag_name": "\K.*?(?=")')
    if [ -n "$COMPOSE_VERSION" ]; then
        curl -L "https://github.com/docker/compose/releases/download/${COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose >> "$LOG_FILE" 2>&1
        chmod +x /usr/local/bin/docker-compose >> "$LOG_FILE" 2>&1
        ln -sf /usr/local/bin/docker-compose /usr/bin/docker-compose >> "$LOG_FILE" 2>&1
        echo -e "${GREEN}Docker Compose updated to version ${COMPOSE_VERSION}.${NC}"
        log "Docker Compose updated to version ${COMPOSE_VERSION}."
    else
        echo -e "${RED}Failed to fetch Docker Compose version.${NC}"
        log "Failed to fetch Docker Compose version during update."
    fi

    echo -e "${GREEN}Docker updated successfully.${NC}"
    log "Docker update completed."
    pause
    main_menu
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
