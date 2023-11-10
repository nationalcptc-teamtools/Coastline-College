#!/bin/bash

# Function to display help menu
display_help() {
    echo "Usage: $0 [option]"
    echo "Options: -h|--help"
    exit 0
}

# Check for help argument
[[ $1 == "-h" || $1 == "--help" ]] && display_help

# # Verify running with sudo or as root
# [[ $EUID -ne 0 ]] && {
#     echo "Run as root. Exiting."
#     exit 1
# }

# Change to root directory before execution
change_to_home() {
    cd /home/kali || {
        echo "Failed to change to /home/kali directory. Exiting." >&2
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
    sudo cp /home/kali/Coastline-College/Mike/Scripts/.tmux.conf /home/kali || {
        echo "Failed to copy .tmux.conf to /home/kali. Exiting." >&2
        exit 1
    }
    echo "Copied .tmux.conf to /home/kali"
}

# Install packages
install_packages() {
    sudo apt install -yq "$@" || {
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
    sudo cp "$file_path" "${file_path}.bak" || {
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
    sudo apt update -q || {
        echo "Failed to update package list" >&2
        exit 1
    }
    sudo dpkg -l | grep -qw git || sudo apt install -yq git || {
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
    sudo sed -i 's|http://http.kali.org/kali|http://kali.download/kali|g' /etc/apt/sources.list || {
        echo "Failed to change repositories" >&2
        exit 1
    }
}

# Function to update Kali Linux
update_kali() {
    sudo apt update -q && sudo apt dist-upgrade -y && sudo apt autoremove -yq
}

# Function to clean up
cleanup() {
    if ! sudo apt clean || ! sudo apt autoclean || ! sudo apt autoremove -y; then
        echo "Failed to clean up" >&2
        exit 1
    fi

    if ! sudo rm -rf /var/cache/apt/archives/*; then
        echo "Failed to remove cache" >&2
        exit 1
    fi
}

# Function to enable ssh
enable_ssh() {
    sudo systemctl enable --now ssh || {
        echo "Failed to enable ssh. Exiting." >&2
        exit 1
    }

    sudo ufw allow 22/tcp || {
        echo "Failed to allow ssh. Exiting." >&2
        exit 1
    }

    sudo sed -i 's|PermitRootLogin prohibit-password|PermitRootLogin yes|g' /etc/ssh/sshd_config || {
        echo "Failed to change sshd_config. Exiting." >&2
        exit 1
    }

    sudo systemctl restart ssh || {
        echo "Failed to restart ssh. Exiting." >&2
        exit 1
    }
}

# Function to configure tldr
configure_tldr() {
    mkdir -p /home/kali/.local/share/tldr || {
        echo "Failed to create /home/kali/.local/share/tldr. Exiting." >&2
        exit 1
    }

    tldr -u
}

# Function to install docker compose
install_docker() {
    for pkg in docker.io docker-doc docker-compose podman-docker containerd runc; do
        sudo apt remove -y $pkg
    done
    sudo apt autoremove -y

    # Add Docker's official GPG key:
    sudo apt update
    install_packages ca-certificates curl gnupg
    sudo apt install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    sudo chmod a+r /etc/apt/keyrings/docker.gpg

    # Add the repository to Apt sources:
    sudo echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian bookworm stable" | sudo tee /etc/apt/sources.list.d/docker.list >/dev/null
    sudo apt update

    # Install Docker Engine:
    install_packages docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    sudo usermod -aG docker kali
    sudo systemctl enable --now docker.service
    sudo systemctl enable --now containerd.service

    # Check for "docker compose command"
    ! command -v docker compose >/dev/null && {
        echo "docker compose command not found. Exiting..." >&2
        exit 1
    } || echo "docker compose command found. Continuing..."
}

# Function to install headless tools
install_headless() {
    update_kali

    install_packages kali-linux-headless htop btop vim tldr ninja-build gettext cmake unzip curl cargo gdu npm ufw

    enable_ssh

    install_docker

    configure_tldr

    cleanup
}

# Function to install neovim
install_neovim() {
    if command -v nvim >/dev/null; then
        echo "Neovim already installed. Skipping..."
        return
    fi

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

    cd build && cpack -G DEB && sudo dpkg -i nvim-linux64.deb

    download_and_unzip "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/CascadiaCode.zip" "/home/kali/.fonts"
    fc-cache -fv

    cargo install tree-sitter-cli

    curl -LO https://github.com/ClementTsang/bottom/releases/download/0.9.6/bottom_0.9.6_amd64.deb
    sudo dpkg -i bottom_0.9.6_amd64.deb

    mv ~/.config/nvim ~/.config/nvim.bak
    mv ~/.local/share/nvim ~/.local/share/nvim.bak
    mv ~/.local/state/nvim ~/.local/state/nvim.bak
    mv ~/.cache/nvim ~/.cache/nvim.bak
    git clone --depth 1 https://github.com/AstroNvim/AstroNvim ~/.config/nvim

    cd /home/kali || return
    rm -rf neovim
}

# Function to install Desktop
install_desktop_default() {
    install_headless

    install_packages kali-desktop-xfce kali-linux-default kali-tools-top10 xrdp && sudo systemctl enable --now xrdp

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

    sudo ./pimpmykali.sh || {
        echo "Failed to run pimpmykali.sh" >&2
        exit 1
    }

    cd /home/kali || exit
    rm -rf pimpmykali

    cleanup
}

# Function to install OpenVAS taken from https://greenbone.github.io/docs/latest/_static/setup-and-start-greenbone-community-edition.sh
setup_openvas() {

    DOWNLOAD_DIR=/home/kali/greenbone-community-container

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

    echo
    echo "The feed data will be loaded now. This process may take several minutes up to hours."
    echo "Before the data is not loaded completely, scans will show insufficient or erroneous results."
    echo "See https://greenbone.github.io/docs/latest/$RELEASE/container/workflows.html#loading-the-feed-changes for more details."
}

# Function to import openVAS configs
import_configs_openVAS() {
    sudo apt install gvm-tools -yq || {
        echo "Failed to install gvm-tools" >&2
        exit 1
    }

    # Check that openvas docker compose is running. If not running, continue retrying every 30 seconds
    while ! docker ps | grep -q openvas || docker ps | grep openvas | grep -q starting; do
        echo "====================================================================================="
        echo "Waiting for openvas docker compose to start and not be in a 'starting' state..."
        echo "====================================================================================="
        sleep 5
    done

    # Check that the openvas web interface is available. If not available, continue retrying every 30 seconds
    while ! curl -s -k http://127.0.0.1:9392 | grep -q "Greenbone Security Assistant"; do
        echo "====================================================================================="
        echo "Waiting for openvas web interface to be available..."
        echo "====================================================================================="
        sleep 5
    done

    sudo apt install gvm-tools -yq || {
        echo "Failed to install gvm-tools" >&2
        exit 1
    }

}

install_openvas() {
    setup_openvas || {
        echo "Failed to setup openvas" >&2
        exit 1
    }
    import_configs_openVAS || {
        echo "Failed to import configs" >&2
        exit 1
    }
    cleanup || {
        echo "Failed to cleanup" >&2
        exit 1
    }
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
        echo "|   N: Install Neovim       |"
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
        N | n) install_neovim ;;
        T | t) copy_tmux ;;
        C | c) change_repos ;;
        Q | q) reboot_func && exit 0 ;;
        *) echo "Invalid. Retry." ;;
        esac
    done
}

main() {
    startx_needed=0
    change_to_kali
    check_dependencies
    display_menu
}

main
