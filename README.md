# Fresh OS Installation Guide

Congratulations on installing your new operating system! Follow this comprehensive guide to seamlessly restore all your necessary files, configurations, and applications without unnecessary bloat. This guide is tailored for Linux Mint but can be adapted to other lightweight distributions as needed.

## Restore Files from USB

I. **Connect USB Drive:**  

Make sure your USB drive is properly formatted and contains all your backup files. Insert the USB drive into an available USB port on your computer and wait for the system to recognize and mount the USB drive automatically.

II. **Identify Mount Point:**  

Open the file manager to locate the USB drive, typically found under `/media/your_username/USB_NAME` or `/mnt/usb`. Alternatively, use the terminal command `lsblk` to list all block devices and identify the mount point of your USB drive.

III. **Copy Necessary Folders:**  

Copy your necessary folders from the USB drive to your home directory using the following commands:

```bash
cp -r /media/usb/Downloads ~/Downloads
cp -r /media/usb/Desktop ~/Desktop
cp -r /media/usb/Documents ~/Documents
cp -r /media/usb/Pictures ~/Pictures
cp -r /media/usb/Music ~/Music
cp -r /media/usb/Videos ~/Videos
```

Replace `/media/usb/` with the actual mount point of your USB drive.

IV. **Restore Hidden Configuration Files:**  
Hidden files, which start with a dot, contain important configurations. Use the command `cp -r /media/usb/.* ~/` to copy all hidden files from the USB to your home directory. Be cautious as this may overwrite existing configuration files. Make sure you have backups if necessary.

V. **Set Correct Permissions:**  

After copying, make sure that all files have the correct permissions by running:

```bash
chmod -R u+rwX,go-rwX ~/ 
```

This command grants read, write, and execute permissions to the user and removes read and write permissions for group and others.

VI. **Verify File Integrity:**  

Check that all files have been copied successfully by listing the contents of each directory:

```bash
ls ~/Downloads
ls ~/Desktop
ls ~/Documents
```

Compare the contents with your USB drive to make sure completeness.

VII. **Update File References:**  

Some applications may have absolute paths pointing to the old system. Update these references as needed to match your new system's directory structure.

VIII. **Safely Eject USB Drive:**  

Once all files are copied and verified, safely eject the USB drive to prevent data corruption. Use the eject option in the file manager or execute the terminal command `sudo umount /media/usb`. Wait for confirmation that the drive has been unmounted before physically removing it.

## Restore System Configurations

I. **Restore Network Settings:**  

Copy your network configuration files to restore Wi-Fi and Ethernet settings using the following commands:

```bash
cp /media/usb/etc/NetworkManager/NetworkManager.conf /etc/NetworkManager/
cp -r /media/usb/etc/NetworkManager/system-connections/ /etc/NetworkManager/
```

Restart the Network Manager service with `sudo systemctl restart NetworkManager`.

II. **Restore User Preferences:**  

Transfer user-specific settings such as themes, keyboard shortcuts, and display preferences by executing:

```bash
cp -r /media/usb/.config ~/.config
cp -r /media/usb/.local ~/.local
```

Make sure that the ownership of the copied files matches your current user by running:

```bash
chown -R $(whoami)$(whoami) ~/.config ~/.local
```

III. **Restore Shell Configurations:**  

Copy shell configuration files to retain aliases and environment variables:

```bash
cp /media/usb/.bashrc ~/
cp /media/usb/.bash_profile ~/
```

Reload the shell configurations with:

```bash
source ~/.bashrc
source ~/.bash_profile
```

IV. **Restore Application Settings:**  

Transfer configurations for specific applications to maintain your personalized settings using:

```bash
cp -r /media/usb/.mozilla ~/.mozilla
cp -r /media/usb/.config/gtk-3.0 ~/.config/gtk-3.0
```

Adjust permissions if necessary with:

```bash
chown -R $(whoami)$(whoami) ~/.mozilla ~/.config/gtk-3.0
```

## Network Configuration

I. **Verify Network Connectivity:**  

Make sure your network card is recognized and connected. Use the following command to check network status:

```bash
nmcli device status
```

II. **Check Open Ports:**  

Identify open ports using:

```bash
sudo ss -tuln
```

III. **Harden Network Security:**  

Enhance your system's security by configuring the firewall and managing open ports.

IV. **Enable Firewall:**  

Activate the Uncomplicated Firewall (UFW) to manage incoming and outgoing traffic:

```bash
sudo ufw enable
```

V. **Set Default Policies:**  

Define default rules for incoming and outgoing connections:

```bash
sudo ufw default deny incoming
sudo ufw default allow outgoing
```

VI. **Allow Necessary Ports:**  

Permit necessary services by allowing specific ports:

```bash
sudo ufw allow ssh
sudo ufw allow http
sudo ufw allow https
```

VII. **Reload Firewall:**  

Apply the new firewall rules:

```bash
sudo ufw reload
```

VIII. **Install Network Tools:**  

Enhance your network management capabilities by installing additional tools:

```bash
sudo apt install wireshark net-tools
```

- ** A powerful network protocol analyzer.
- ** Includes necessary networking utilities like `ifconfig` and `netstat`.

## Remove Bloatware

Even Linux Mint may come with some pre-installed applications you might not need. Removing unnecessary software helps maintain a lean and efficient system.

I. **List Installed Packages:**  

View all installed packages to identify unwanted software:

```bash
dpkg --list
```

II. **Remove Unwanted Packages:**  

Uninstall applications that you do not require using the purge option to remove configuration files:

```bash
sudo apt remove --purge <package-name>
```

*Replace `<package-name>` with the actual name of the package you wish to remove.*

III. **Clean Up:**  

Remove residual files and dependencies that are no longer needed:

```bash
sudo apt autoremove
sudo apt clean
```

V. **Example: To Remove the Pre-Installed Music Player:**  

```bash
sudo apt remove --purge rhythmbox
```

*Make sure that you review the list of packages before removal to avoid uninstalling necessary system components.*

## Browser Setup

I. **Install Firefox:**  

Install Firefox by running the following command:

```bash
sudo apt install firefox
```

II. **Install Brave:**  

Install Brave browser by executing the following commands:

```bash
sudo apt install apt-transport-https curl
curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main" | sudo tee /etc/apt/sources.list.d/brave-browser-release.list
sudo apt update
sudo apt install brave-browser
```

III. **Configure Browsers:**  

Configure your browsers to manage passwords securely. Decide which passwords to store in each browser. Maintain an offline copy of all passwords and backup codes using a password manager like [KeePassXC](https://keepassxc.org/).

## Password Management

Managing your passwords securely is important. Here’s how to set it up in a completely offline way, only storing on a USB stick:

I. **Install KeePassXC:**  

Install KeePassXC by running:

```bash
sudo apt install keepassxc
```

II. **Create a Password Database:**  

Open KeePassXC and create a new password database. Save the database file to your USB drive.

III. **Set a Strong Master Password:**  

Choose a strong master password to protect your password database. Make sure it is unique and not used anywhere else.

IV. **Add Your Passwords:**  

Enter all your passwords into the KeePassXC database. Categorize them as needed for easy access.

V. **Backup Your Database:**  

Regularly backup your password database by copying it to multiple secure locations on your USB drive.

VI. **Make sure Offline Storage:**  

Do not store your password database on your system's local storage. Always keep it on the USB drive to maintain security.

## Account Setup

Configure your necessary online accounts to make sure smooth access and synchronization.

I. **Access Your Necessary Accounts:**  

Open your browser and make sure you can access all your necessary online accounts such as eBay, Amazon, GitHub, YouTube, Gmail, Twitter, Reddit, ChatGPT, Chess.com, and banking platforms.

II. **Security Measures:**  

- Enable two-factor authentication (2FA) on all accounts where possible.
- Do not store passwords in the browser or anywhere on the system. Use your USB-based password manager instead.

III. **Set Up 2FA:**  

For each account, follow the platform's instructions to enable 2FA. Store the backup codes securely on your desk after printing them out.

## Software Installation

Make sure you have the latest compilers, development tools, and necessary software installed. Maintain a central CSV file documenting installation paths and shortcuts for easy removal if needed.

## Programming Languages

I. **Go:**  

Install Go programming language to develop efficient and scalable applications.

```bash
sudo apt install golang
```

After installation, verify the version:

```bash
go version
```

Set up the Go workspace by configuring the `GOPATH` environment variable in your `.bashrc` or `.zshrc`:

```bash
echo "export GOPATH=\$HOME/go" >> ~/.bashrc
echo "export PATH=\$PATH:\$GOPATH/bin" >> ~/.bashrc
source ~/.bashrc
```

II. **Haskell:**  

Install the Haskell platform for functional programming.

```bash
sudo apt install haskell-platform
```

Verify the installation:

```bash
ghc --version
```

Initialize a new Haskell project using `cabal`:

```bash
cabal update
cabal init
```

III. **Rust:**  

Install Rust using the official installer for system-wide and user-specific configurations.

```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```

Follow the on-screen instructions to complete the installation. After installation, verify Rust version:

```bash
rustc --version
```

Update Rust to the latest version when necessary:

```bash
rustup update
```

IV. **Node.js:**  

Install the latest version of Node.js for JavaScript and server-side development.

```bash
curl -fsSL https://deb.nodesource.com/setup_current.x | sudo -E bash -
sudo apt install -y nodejs
```

Verify the installation:

```bash
node -v
npm -v
```

Install `nvm` (Node Version Manager) for managing multiple Node.js versions:

```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash
source ~/.bashrc
nvm install node
```

V. **C/C++:**  

Install GCC and essential build tools for compiling C and C++ programs.

```bash
sudo apt install build-essential
```

Verify GCC version:

```bash
gcc --version
```

To install support for newer C++ standards like C++20, ensure your GCC version is up-to-date. If not, add the appropriate PPA or build GCC from source:

```bash
sudo add-apt-repository ppa:ubuntu-toolchain-r/test
sudo apt update
sudo apt install gcc-10 g++-10
```

Set GCC 10 as the default:

```bash
sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-10 10
sudo update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-10 10
```

VI. **Python:**  

Install the latest Python versions and manage dependencies using virtual environments.

```bash
sudo apt install python3 python3-pip
```

Install `virtualenv` for creating isolated Python environments:

```bash
sudo pip3 install virtualenv
```

- Install packages within virtual environments to prevent conflicts.
- Create a separate environment for each project.

```bash
virtualenv ~/my_project_env
source ~/my_project_env/bin/activate
```

- Once a project is complete, deactivate and delete the environment.

```bash
deactivate
rm -rf ~/my_project_env
```

## Development Tools

I. **Visual Studio Code:**  

A versatile and lightweight code editor with extensive extensions.

```bash
wget -O ~/Downloads/vscode.deb https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64
sudo dpkg -i ~/Downloads/vscode.deb
sudo apt -f install
```

II. **Qt Creator:**  

An integrated development environment for C++ and Qt applications.

```bash
sudo apt install qtcreator
```

Launch Qt Creator from the application menu or via terminal:

```bash
qtcreator
```

III. **PyCharm:** 

A powerful IDE for Python development.

```bash
wget https://download.jetbrains.com/python/pycharm-community-2025.1.tar.gz -P ~/Downloads
tar -xzf ~/Downloads/pycharm-community-2025.1.tar.gz -C ~/opt/
~/opt/pycharm-community-2025.1/bin/pycharm.sh
```

Inside PyCharm, go to `Tools` > `Create Desktop Entry` for easy access.

IV. **Vim Configuration:**  

A highly configurable text editor built to enable efficient text editing.

```bash
sudo apt install vim
```

Copy your configs:

```bash
cp /media/usb/.vimrc ~/
cp -r /media/usb/.vim/ ~/.vim/
```

Use a plugin manager like `vim-plug` for managing Vim plugins.

```bash
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
 https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
vim +PlugInstall +qall
```

V. **TeX Maker for LaTeX:**  

An integrated writing environment for creating LaTeX documents.

```bash
sudo apt install texmaker
```

Launch TeX Maker from the application menu or via terminal:

```bash
texmaker
```

Configure your LaTeX environment by setting up necessary packages and templates.

VI. **Git:**  

Version control system to manage your code repositories.

```bash
sudo apt install git
```

Configure Git with your user information:

```bash
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
```

Generate SSH keys for secure repository access:

```bash
ssh-keygen -t rsa -b 4096 -C "your.email@example.com"
```

Add the SSH key to your GitHub or GitLab account.

VII. **Docker:**  

Platform for developing, shipping, and running applications in containers.

```bash
sudo apt install docker.io
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker $USER
```

Log out and back in for the changes to take effect.

```bash
docker --version
docker run hello-world
```

VIII. **Postman:**  

API development environment for testing and documenting APIs.

```bash
wget https://dl.pstmn.io/download/latest/linux64 -O ~/Downloads/postman.tar.gz
tar -xzf ~/Downloads/postman.tar.gz -C ~/opt/
ln -s ~/opt/Postman/Postman /usr/bin/postman
```

Optionally, create a desktop entry for easier access.

## Documentation and Reference Tools

I. **Doxygen:**  
Generate documentation from annotated source code.

```bash
sudo apt install doxygen
```

Create a `Doxyfile` configuration:

```bash
doxygen -g
```

Edit the `Doxyfile` as needed and generate documentation:

```bash
doxygen Doxyfile
```

II. **Markdown Editors:**  

Tools for writing and previewing Markdown documents.

- typoradeb

```bash
wget -O ~/Downloads/typoradeb https://typora.io/linux/public-key.asc
sudo dpkg -i ~/Downloads/typoradeb
sudo apt -f install
```

- marktextdeb

```bash
wget -O ~/Downloads/marktextdeb https://github.com/marktext/marktext/releases/download/v0.16.3/marktext-amd64deb
sudo dpkg -i ~/Downloads/marktextdeb
sudo apt -f install
```

## Containerization

Manage and deploy applications efficiently using Docker, which allows you to package applications with all their dependencies into standardized units called containers.

I. **Install Docker:**  

Docker provides a consistent environment for applications, making it easier to develop, ship, and run them across different systems. The installation steps add Docker's official repository to your system and install the necessary packages.

```bash
sudo apt update
sudo apt install apt-transport-https ca-certificates curl gnupg lsb-release
curl -fsSL https://downloaddocker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.listd/docker.list > /dev/null
sudo apt update
sudo apt install docker-ce docker-ce-cli containerd.io
sudo usermod -aG docker$USER
```

After adding your user to the `docker` group, log out and back in to apply the changes.

II. **Verify Installation:**  

Running a simple Docker container ensures that Docker is installed and functioning correctly.

```bash
docker run hello-world
```

This command pulls the `hello-world` image from Docker Hub and runs it in a container, displaying a confirmation message upon success.

III. **Optional: Install Docker Compose:**  

Docker Compose allows you to define and manage multi-container Docker applications using a YAML file.

```bash
sudo curl -L "https://github.com/docker/compose/releases/download/$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep -Po '"tag_name": "\K.*?(?=")')/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
```

Verify the installation:

```bash
docker-compose --version
```

Docker Compose simplifies the process of managing complicated applications by allowing you to start, stop, and configure multiple containers with ease.

## Window Managers

Customize your desktop environment with dynamic window managers like `dwm`, which offer efficient and minimalist interfaces for power users.

I. **Install dwm Dependencies:**  

Before installing `dwm`, make sure that all necessary dependencies are present on your system. These libraries provide the necessary functionality required by `dwm`.

```bash
sudo apt install build-necessary libx11-dev libxft-dev libxinerama-dev
```

- Provides the compiler and related tools.
- Libraries for X11, fonts, and multi-monitor support.

II. **Download and Install dwm:**  

Clone the `dwm` repository from suckless.org, find your way through into the directory, and compile the source code.

```bash
git clone https://git.suckless.org/dwm
cd dwm
sudo make clean install
```

This process compiles `dwm` and installs it to your system. Make sure you have a backup of any custom configurations before proceeding.

III. **Configure dwm:**  

Customize `dwm` by modifying the `config.h` file, which defines keybindings, appearance, and behavior.

```bash
cp /media/usb/dwm/config.h .
sudo make clean install
```

Recompiling after copying the custom `config.h` applies your personalized settings.

```bash
sudo make clean install
```

Any changes to `config.h` require recompilation to take effect. This makes sure that your customizations are properly integrated into `dwm`.

## Games

Enhance your system with gaming capabilities by installing platforms and tools that support a wide range of games.

I. **Steam:**  

Steam is a leading digital distribution platform for purchasing, downloading, and playing games.

```bash
sudo apt install steam
```

After installation, launch Steam from the application menu, log in to your account, and start enjoying your favorite games.

## Office Tools

Equip your system with necessary office tools to handle tasks like image editing, document creation, and more.

I. **GIMP:**  
GIMP (GNU Image Manipulation Program) is a powerful, open-source image editor suitable for tasks ranging from photo retouching to graphic design.

```bash
sudo apt install gimp
```

Launch GIMP from the application menu or via terminal:

```bash
gimp
```

Explore GIMP's features to enhance your image editing workflow.

## Video Editing

Install strong video editing tools to create and manage multimedia projects efficiently.

I. **Peek:**  

Peek is a simple screen recorder with an animated GIF-like interface, ideal for creating short screen recordings.

```bash
sudo apt install peek
```

Launch Peek from the application menu to start recording your screen activities.

II. **OBS Studio:**  

OBS Studio is a free and open-source software for video recording and live streaming, offering advanced features for content creators.

```bash
sudo apt install obs-studio
```

Launch OBS Studio from the application menu or via terminal:

```bash
obs
```

Configure your recording and streaming settings to suit your project needs.

III. **Kdenlive:**  

Kdenlive is a professional-grade video editor that provides a wide range of editing tools and effects.

```bash
sudo apt install kdenlive
```

Launch Kdenlive from the application menu to begin editing your videos with ease.

IV. **Simple Screen Recorder:**  

This tool offers a straightforward interface for capturing your screen, suitable for creating tutorials or recording gameplay.

```bash
sudo apt install simplescreenrecorder
```

Launch Simple Screen Recorder from the application menu to start capturing your screen.

V. **Audacity:**  

Audacity is a free, open-source audio editor and recorder, perfect for editing soundtracks, podcasts, and more.

```bash
sudo apt install audacity
```

Launch Audacity from the application menu to begin editing audio files.

## Organization Tips

Maintaining an organized system makes sure that your software and files are easy to manage, reducing clutter and improving productivity.

I. **Central CSV for Software Management:**  

Keeping a centralized log of all installed software, including installation paths and shortcut commands, simplifies tracking and uninstallation processes.

```bash
touch ~/software_installation_log.csv
```

Use clear and consistent columns to record necessary information.

```
Software Name,Installation Path,Version,Shortcut Command,Uninstallation Command
Go,/usr/bin/go,1.18,go,/usr/bin/go
Rust,/home/user/.cargo/bin/rustc,1.60,rustc,rm -rf ~/.cargo
```

After each installation, log the details into the CSV file to maintain an accurate record for future reference.

II. **Use a Single Package Manager:**  

Relying on a single package manager like `apt` makes sure consistency in software installations and simplifies dependency management. Avoid mixing package managers unless necessary to prevent conflicts.

III. **Keep Track of Everything You Install:**  

Regularly update your central CSV file with new installations and changes. This practice aids in troubleshooting, updates, and system maintenance.

IV. **Backup and Recovery:**  

Protect your important files and configurations by carrying out a strong backup strategy.

Schedule regular backups of your home directory, configuration files, and important projects to an external drive or cloud storage.

```bash
rsync -av --progress ~/.config /media/usb/config_backup/
rsync -av --progress ~/projects /media/usb/projects_backup/
```

Use tools like [Timeshift](https://github.com/teejee2008/timeshift) to create system snapshots. These snapshots allow you to restore your system to a previous state in case of important failures or misconfigurations.

```bash
sudo apt install timeshift
sudo timeshift-gtk
```

Configure Timeshift to take regular snapshots and store them on a separate partition or external drive for added security.
