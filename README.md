# Fresh OS Installation Guide

Congratulations on installing your new operating system! Follow this minimalist guide to seamlessly restore all your essential files, configurations, and applications without unnecessary bloat. This guide is tailored for Linux Mint but can be adapted to other lightweight distributions as needed.

## Restore Files from USB

1. **Connect USB Drive:**
   - Plug in your USB drive containing your backup files.

2. **Copy Essential Folders:**
   - **Downloads:**
     ```bash
     cp -r /media/usb/Downloads ~/Downloads
     ```
   - **Desktop:**
     ```bash
     cp -r /media/usb/Desktop ~/Desktop
     ```
   - **Documents:**
     ```bash
     cp -r /media/usb/Documents ~/Documents
     ```

   *Replace `/media/usb/` with the actual mount point of your USB drive.*

## Network Configuration

1. **Verify Network Connectivity:**
   - Ensure your network card is recognized and connected.
   - Use the following command to check network status:
     ```bash
     nmcli device status
     ```

2. **Check Open Ports:**
   - Identify open ports using:
     ```bash
     sudo ss -tuln
     ```

3. **Harden Network Security:**
   - **Enable Firewall:**
     ```bash
     sudo ufw enable
     ```
   - **Set Default Policies:**
     ```bash
     sudo ufw default deny incoming
     sudo ufw default allow outgoing
     ```
   - **Allow Necessary Ports:**
     ```bash
     sudo ufw allow ssh
     sudo ufw allow http
     sudo ufw allow https
     ```
   - **Reload Firewall:**
     ```bash
     sudo ufw reload
     ```

## Remove Bloatware

Even Linux Mint may come with some pre-installed applications you might not need. Removing unnecessary software helps maintain a lean system.

1. **List Installed Packages:**
   ```bash
   dpkg --list
   ```

2. **Remove Unwanted Packages:**
   ```bash
   sudo apt remove --purge <package-name>
   ```

3. **Clean Up:**
   ```bash
   sudo apt autoremove
   sudo apt clean
   ```

*Example: To remove the pre-installed music player:*
```bash
sudo apt remove --purge rhythmbox
```

## Browser Setup

1. **Install Lightweight Browsers:**
   - **Firefox:**
     ```bash
     sudo apt install firefox
     ```
   - **Brave:**
     ```bash
     sudo apt install apt-transport-https curl
     curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
     echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main" | sudo tee /etc/apt/sources.list.d/brave-browser-release.list
     sudo apt update
     sudo apt install brave-browser
     ```

2. **Configure Browsers:**
   - **Password Management:**
     - Decide which passwords you want to store in each browser.
     - Maintain an offline copy of all passwords and backup codes using a password manager like [KeePassXC](https://keepassxc.org/).

## Password Management

Managing your passwords securely is crucial. Here’s how to set it up:

todo

## Account Setup

Configure your essential online accounts to ensure seamless access and synchronization.

1. **Social Media and Services:**
   - **Accounts to Set Up:**
   - ebay
   - amazon
     - GitHub
     - YouTube
     - Gmail
     - Twitter
     - Reddit
     - ChatGPT
     - Chess.com
     - Banking platforms

2. **Security Measures:**
   - Enable two-factor authentication (2FA) where possible.
   - Store backup codes securely on your desk after printing them out.

## Software Installation

Ensure you have the latest compilers, development tools, and essential software installed. Maintain a central CSV file documenting installation paths and shortcuts for easy removal if needed.

### Programming Languages

1. **Go:**
   ```bash
   sudo apt install golang
   ```

2. **Haskell:**
   ```bash
   sudo apt install haskell-platform
   ```

3. **Rust:**
   ```bash
   curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
   ```

4. **Node.js:**
   ```bash
   curl -fsSL https://deb.nodesource.com/setup_current.x | sudo -E bash -
   sudo apt install -y nodejs
   ```

5. **C/C++:**
   - **GCC Installation:**
     ```bash
     sudo apt install build-essential
     ```
   - **Verify GCC Version:**
     ```bash
     gcc --version
     ```
   - **Install Newer Standards (e.g., C++20):**
     Ensure your GCC version supports C++20. If not, consider adding a PPA or building from source.

6. **Python:**
   - **Install Latest Python:**
     ```bash
     sudo apt install python3 python3-pip
     ```
   - **Set Up Virtual Environments:**
     ```bash
     sudo pip3 install virtualenv
     ```

### Development Tools

tex maker for latex

1. **Visual Studio Code:**
   - **Download DEB Package:**
     - Visit the [official VS Code download page](https://code.visualstudio.com/download) and download the `.deb` package.
   - **Install VS Code:**
     ```bash
     sudo dpkg -i ~/Downloads/code_<version>.deb
     sudo apt -f install
     ```

2. **Qt Creator:**
   ```bash
   sudo apt install qtcreator
   ```

3. **PyCharm:**
   - **Download Tarball:**
     - Visit the [official PyCharm download page](https://www.jetbrains.com/pycharm/download/#section=linux) and download the tarball for your edition.
   - **Install PyCharm:**
     ```bash
     tar -xzf pycharm-*.tar.gz -C ~/opt/
     ~/opt/pycharm-*/bin/pycharm.sh
     ```
     *Optionally, create a desktop entry for easier access.*

4. **Vim Configuration:**
   - **Install Vim:**
     ```bash
     sudo apt install vim
     ```
   - **Set Up Vim Scripts:**
     - Copy your `.vimrc` and any custom scripts from your backup:
       ```bash
       cp /media/usb/.vimrc ~/
       cp -r /media/usb/.vim/ ~/.vim/
       ```

### Containerization

Manage and deploy applications efficiently using Docker.

1. **Install Docker:**
   ```bash
   sudo apt update
   sudo apt install apt-transport-https ca-certificates curl gnupg lsb-release
   curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
   echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
   sudo apt update
   sudo apt install docker-ce docker-ce-cli containerd.io
   sudo usermod -aG docker $USER
   ```

2. **Verify Installation:**
   ```bash
   docker run hello-world
   ```

3. **Optional: Install Docker Compose:**
   ```bash
   sudo curl -L "https://github.com/docker/compose/releases/download/$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep -Po '"tag_name": "\K.*?(?=")')/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
   sudo chmod +x /usr/local/bin/docker-compose
   ```

### Window Managers

Customize your desktop environment with dynamic window managers like dwm.

1. **Install dwm Dependencies:**
   ```bash
   sudo apt install build-essential libx11-dev libxft-dev libxinerama-dev
   ```

2. **Download and Install dwm:**
   ```bash
   git clone https://git.suckless.org/dwm
   cd dwm
   sudo make clean install
   ```

3. **Configure dwm:**
   - Copy your custom `config.h` from your backup:
     ```bash
     cp /media/usb/dwm/config.h .
     sudo make clean install
     ```
   - **Note:** After modifying `config.h`, you need to recompile dwm:
     ```bash
     sudo make clean install
     ```

## Additional Resources

- **Central CSV for Software Management:**
  - Maintain a CSV file with columns like:
    - **Software Name**
    - **Installation Path**
    - **Shortcut Commands**
    - **Uninstallation Commands**

- **Backup and Recovery:**
  - Regularly back up your important files and configurations.
  - Consider using tools like [Timeshift](https://github.com/teejee2008/timeshift) for system snapshots.
