#!/bin/bash

# Check for help argument
[[ $1 == "-h" || $1 == "--help" ]] && display_help

# Verify running with sudo or as root
[[ $EUID -ne 0 ]] && {
    echo "Run as root. Exiting."
    exit 1
}

# Change to root directory before execution
change_to_root() {
    cd /root || {
        echo "Failed to change to /root directory. Exiting." >&2
        exit 1
    }
}

# Copy tmux config
copy_tmux() {
    read -rp "Copy tmux config? (y/N): " confirmation
    [[ $confirmation =~ ^[Yy]$ ]] || {
        echo "Cancelled."
        return
    }
    cp /root/Coastline-College/Mike/Scripts/.tmux.conf /root/ || {
        echo "Failed to copy .tmux.conf to /root/. Exiting." >&2
        exit 1
    }
    echo "Copied .tmux.conf to /root/"
}

# Install packages
install_packages() {
    apt install -yq "$@" || {
        echo "Network issue... Exiting now."
        exit 1
    }
}

# Clone a git repository, skipping if it already exists
clone_or_skip() {
    local repo_url="$1"
    local target_dir="$2"
    if [ -d "$target_dir" ]; then
        echo "$target_dir exists. Skipping git clone..."
    else
        git clone "$repo_url" "$target_dir"
    fi
}

# Backup a file
backup_file() {
    local file_path="$1"
    cp "$file_path" "${file_path}.bak" || {
        echo "Backup failed for $file_path" >&2
        exit 1
    }
}

# Download and unzip a file
download_and_unzip() {
    local url="$1"
    local dest_dir="$2"
    wget -q -O /tmp/temp.zip "$url" || {
        echo "Download failed" >&2
        exit 1
    }
    unzip -o -d "$dest_dir" /tmp/temp.zip || {
        echo "Unzip failed" >&2
        exit 1
    }
    rm /tmp/temp.zip || {
        echo "Temporary file removal failed" >&2
        exit 1
    }
}

# Remove directory if it exists
remove_directory() {
    local dir_path="$1"
    [ -d "$dir_path" ] && {
        echo "Removing directory $dir_path"
        rm -rf "$dir_path"
    }
}

# Check for necessary dependencies
check_dependencies() {
    echo "Updating package list..."
    apt update -q || {
        echo "Failed to update package list" >&2
        exit 1
    }
    dpkg -l | grep -qw git || apt install -yq git || {
        echo "Failed to install git" >&2
        exit 1
    }
}

# Function to display help menu
display_help() {
    echo "Usage: sudo $0 [option]"
    echo "Options: -h|--help"
    exit 0
}

# Function to change repositories to Cloudflare
change_repos() {
    read -rp "Switch repositories? (y/N): " confirmation
    [[ $confirmation =~ ^[Yy]$ ]] || {
        echo "Cancelled."
        return
    }
    backup_file "/etc/apt/sources.list" || exit 1
    sed -i 's|http://http.kali.org/kali|http://kali.download/kali|g' /etc/apt/sources.list || {
        echo "Failed to change repositories" >&2
        exit 1
    }
}

# Function to update Kali Linux
update_kali() {
    apt update -q && apt dist-upgrade -y && apt autoremove -yq
}

# Function to clean up
cleanup() {
    if ! apt clean || ! apt autoclean || ! apt autoremove -y; then
        echo "Failed to clean up" >&2
        exit 1
    fi

    if ! rm -rf /var/cache/apt/archives/*; then
        echo "Failed to remove cache" >&2
        exit 1
    fi
}

# Function to enable ssh
enable_ssh() {
    systemctl enable --now ssh || {
        echo "Failed to enable ssh. Exiting." >&2
        exit 1
    }

    ufw allow 22/tcp || {
        echo "Failed to allow ssh. Exiting." >&2
        exit 1
    }

    sed -i 's|PermitRootLogin prohibit-password|PermitRootLogin yes|g' /etc/ssh/sshd_config || {
        echo "Failed to change sshd_config. Exiting." >&2
        exit 1
    }

    systemctl restart ssh || {
        echo "Failed to restart ssh. Exiting." >&2
        exit 1
    }
}

# Function to configure tldr
configure_tldr() {
    mkdir -p /root/.local/share/tldr || {
        echo "Failed to create /root/.local/share/tldr. Exiting." >&2
        exit 1
    }

    tldr -u
}

# Function to install docker compose
install_docker() {
    curl -fsSL https://get.docker.com -o get-docker.sh || {
        echo "Failed to download get-docker.sh. Exiting." >&2
        exit 1
    }

    sh get-docker.sh || {
        echo "Failed to run get-docker.sh. Exiting." >&2
        exit 1
    }

    rm get-docker.sh || {
        echo "Failed to remove get-docker.sh. Exiting." >&2
        exit 1
    }

    usermod -aG docker root || {
        echo "Failed to add root to docker group. Exiting." >&2
        exit 1
    }

    systemctl enable --now docker || {
        echo "Failed to enable docker. Exiting." >&2
        exit 1
    }

    # Check for "docker compose command"
    ! command -v docker compose >/dev/null && {
        echo "docker compose command not found. Exiting..." >&2
        exit 1
    } || echo "docker compose command found. Continuing..."
}

# Function to install headless tools
install_headless() {
    update_kali
    read -rp "Continue?" confirmation #debug
    install_packages kali-linux-headless htop btop vim tldr ninja-build gettext cmake unzip curl cargo ripgrep gdu npm ufw
    read -rp "Continue?" confirmation #debug
    enable_ssh
    read -rp "Continue?" confirmation #debug
    install_docker
    read -rp "Continue?" confirmation #debug
    configure_tldr
    read -rp "Continue?" confirmation #debug
    if command -v nvim >/dev/null; then
        echo "Neovim already installed. Skipping..."
    else
        install_neovim
    fi
    cleanup
    read -rp "Continue?" confirmation #debug
}

# Function to install neovim
install_neovim() {
    clone_or_skip "https://github.com/neovim/neovim" "neovim"

    cd neovim || {
        echo "Failed to cd to neovim" >&2
        exit 1
    }
    git checkout stable || {
        echo "Failed to checkout stable branch" >&2
        exit 1
    }

    make CMAKE_BUILD_TYPE=RelWithDebInfo || {
        echo "Failed to make neovim..."
        exit 1
    }
    cd build && cpack -G DEB && dpkg -i nvim-linux64.deb

    download_and_unzip "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/CascadiaCode.zip" "/root/.fonts"
    fc-cache -fv

    cargo install tree-sitter-cli

    curl -LO https://github.com/ClementTsang/bottom/releases/download/0.9.6/bottom_0.9.6_amd64.deb
    dpkg -i bottom_0.9.6_amd64.deb

    mv ~/.config/nvim ~/.config/nvim.bak
    mv ~/.local/share/nvim ~/.local/share/nvim.bak
    mv ~/.local/state/nvim ~/.local/state/nvim.bak
    mv ~/.cache/nvim ~/.cache/nvim.bak
    git clone --depth 1 https://github.com/AstroNvim/AstroNvim ~/.config/nvim

    cd /root || return
    rm -rf neovim
}

# Function to install Desktop
install_desktop_default() {
    install_headless
    install_packages kali-desktop-xfce kali-linux-default kali-tools-top10 xrdp && systemctl enable --now xrdp
    read -rp "Continue?" confirmation #debug
    cleanup
    read -rp "Continue?" confirmation #debug
}

# Function to install all including pimp my kali
install_all_pimp() {
    install_desktop_default
    read -rp "Continue?" confirmation #debug
    clone_or_skip "https://github.com/Dewalt-arch/pimpmykali.git" "pimpmykali"
    read -rp "Continue?" confirmation #debug
    cd pimpmykali || {
        echo "Failed to cd to pimpmykali..." >&2
        exit 1
    }
    read -rp "Continue?" confirmation #debug
    ./pimpmykali.sh || {
        echo "Failed to run pimpmykali.sh" >&2
        exit 1
    }
    read -rp "Continue?" confirmation #debug
    cd /root || exit
    rm -rf pimpmykali
    read -rp "Continue?" confirmation #debug
    cleanup
}

# Quit function
reboot_func() {
    read -rp "Would you like to reboot now? (y/N): " reboot_choice
    if [[ $reboot_choice =~ ^[Yy]$ ]]; then
        sudo reboot
    else
        if [[ $startx_needed -eq 1 ]]; then
            startx
        else
            echo "Exiting script without rebooting. Not starting X"
        fi
    fi
}

# Display TUI menu
display_menu() {
    while true; do
        echo "┌───────────────────────────┐"
        echo "│      Choose an Option     │"
        echo "├───────────────────────────┤"
        echo "│   U: Update Kali Linux    │"
        echo "│   H: Install Headless     │"
        echo "│   D: Install Desktop;     │"
        echo "│   A: Install All Tools    │"
        echo "|   V: Install OpenVAS      |"
        echo "|   T: Copy tmux config     |"
        echo "│   C: Change Repos         │"
        echo "│   Q: Quit                 │"
        echo "└───────────────────────────┘"
        read -rp "Your choice: " choice
        case $choice in
        U | u) update_kali ;;
        H | h) install_headless ;;
        D | d)
            install_desktop_default
            startx_needed=1
            ;;
        A | a)
            install_all_pimp
            startx_needed=1
            ;;
        V | v) install_openvas ;;
        T | t) copy_tmux ;;
        C | c) change_repos ;;
        Q | q) reboot_func && exit 0 ;;
        *) echo "Invalid. Retry." ;;
        esac
    done
}

main() {
    startx_needed=0
    change_to_root
    check_dependencies
    display_menu
}

main
