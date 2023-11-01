#!/bin/bash

# Function to display help menu
display_help() {
    echo "Usage: sudo $0 [option]"
    echo "Options: -h|--help"
    exit 0
}

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
    for pkg in docker.io docker-doc docker-compose podman-docker containerd runc; do
        apt remove -y $pkg
    done
    apt autoremove -y

    # Add Docker's official GPG key:
    apt update
    install_packages ca-certificates curl gnupg
    apt install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    chmod a+r /etc/apt/keyrings/docker.gpg

    # Add the repository to Apt sources:
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian bookworm stable" | tee /etc/apt/sources.list.d/docker.list >/dev/null
    apt update

    # Install Docker Engine:
    install_packages docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    usermod -aG docker root
    systemctl enable --now docker.service
    systemctl enable --now containerd.service

    # Check for "docker compose command"
    ! command -v docker compose >/dev/null && {
        echo "docker compose command not found. Exiting..." >&2
        exit 1
    } || echo "docker compose command found. Continuing..."
}

# Function to install headless tools
install_headless() {
    update_kali

    install_packages kali-linux-headless htop btop vim tldr ninja-build gettext cmake unzip curl cargo ripgrep gdu npm ufw

    enable_ssh

    install_docker

    configure_tldr

    if command -v nvim >/dev/null; then
        echo "Neovim already installed. Skipping..."
    else
        install_neovim
    fi
    cleanup
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

    cleanup

}

# Function to install all including pimp my kali
install_all_pimp() {
    install_desktop_default

    clone_or_skip "https://github.com/Dewalt-arch/pimpmykali.git" "pimpmykali"

    cd pimpmykali || {
        echo "Failed to cd to pimpmykali..." >&2
        exit 1
    }

    ./pimpmykali.sh || {
        echo "Failed to run pimpmykali.sh" >&2
        exit 1
    }

    cd /root || exit
    rm -rf pimpmykali

    cleanup
}

# Function to install OpenVAS taken from https://greenbone.github.io/docs/latest/_static/setup-and-start-greenbone-community-edition.sh
install_openvas() {

    DOWNLOAD_DIR=/root/greenbone-community-container

    installed() {
        # $1 should be the command to look for. If $2 is set, we have arguments
        local failed=0
        if [ -z "$2" ]; then
            if ! [ -x "$(command -v "$1")" ]; then
                failed=1
            fi
        else
            local ret=0
            "$@" &>/dev/null || ret=$?
            if [ "$ret" -ne 0 ]; then
                failed=1
            fi
        fi

        if [ $failed -ne 0 ]; then
            echo "$* is not available. See https://greenbone.github.io/docs/latest/$RELEASE/container/#prerequisites." >&2
            exit 1
        fi

    }

    RELEASE="22.4"

    installed curl
    installed docker
    installed docker compose

    echo "Using Greenbone Community Containers $RELEASE"

    mkdir -p "$DOWNLOAD_DIR" && cd $DOWNLOAD_DIR || exit

    echo "Downloading docker-compose file..."
    curl -f -O https://greenbone.github.io/docs/latest/_static/docker-compose-$RELEASE.yml
    # Bind to all interfaces
    sed -i 's/- 127.0.0.1:9392:80/- "0.0.0.0:9392:80"/' docker-compose-$RELEASE.yml

    echo "Pulling Greenbone Community Containers $RELEASE"
    docker compose -f "$DOWNLOAD_DIR"/docker-compose-$RELEASE.yml -p greenbone-community-edition pull
    echo

    echo "Starting Greenbone Community Containers $RELEASE"
    docker compose -f "$DOWNLOAD_DIR"/docker-compose-$RELEASE.yml -p greenbone-community-edition up -d
    echo

    read -s -rp "Password for admin user: " password
    docker compose -f "$DOWNLOAD_DIR"/docker-compose-$RELEASE.yml -p greenbone-community-edition \
        exec -u gvmd gvmd gvmd --user=admin --new-password="$password"

    echo
    echo "The feed data will be loaded now. This process may take several minutes up to hours."
    echo "Before the data is not loaded completely, scans will show insufficient or erroneous results."
    echo "See https://greenbone.github.io/docs/latest/$RELEASE/container/workflows.html#loading-the-feed-changes for more details."
    echo ""
    echo "Would you like to open the web interface now? [Y/n]"
    read -r open_webinterface
    if [[ $open_webinterface =~ ^[Yy]$ ]] || [[ -z $open_webinterface ]]; then
        firefox https://127.0.0.1:9392
    fi
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
        echo "|      - (Desktop Required) |"
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
