#!/usr/bin/env bash

PACKAGES=(
    git
    curl
    make
    zsh
    build-essential
    ca-certificates
    gnupg
    lsb-release
    htop
    btop
    iotop
    glances
    iperf3
    tmux
    zssh
    fzf
    eza
)

DOCKER_PACKAGES=(
    docker-ce
    docker-ce-cli
    containerd.io
    docker-buildx-plugin
    docker-compose-plugin
)

is_installed() {
    dpkg -l "$1" 2>/dev/null | grep -q "^ii"
}

install_packages() {
    if ! is_installed nala; then
        info "Installing nala..."
        apt-get update -qq
        apt-get install -y -qq nala
    fi

    info "Installing packages..."
    nala update
    nala install -y "${PACKAGES[@]}"
}

setup_docker() {
    local marker="/etc/apt/sources.list.d/docker.sources"

    if [[ ! -f "$marker" ]]; then
        info "Setting up Docker repository..."
        nala install -y ca-certificates curl gnupg

        install -m 0755 -d /etc/apt/keyrings
        curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc 2>/dev/null
        chmod a+r /etc/apt/keyrings/docker.asc

        source /etc/os-release
        local codename="${VERSION_CODENAME}"

        if ! curl -fsSL "https://download.docker.com/linux/debian/dists/${codename}/Release" &>/dev/null; then
            codename="bookworm"
        fi

        cat > /etc/apt/sources.list.d/docker.sources << EOF
Types: deb
URIs: https://download.docker.com/linux/debian
Suites: ${codename}
Components: stable
Signed-By: /etc/apt/keyrings/docker.asc
EOF
    fi

    info "Installing Docker..."
    nala update
    nala install -y "${DOCKER_PACKAGES[@]}"

    systemctl enable docker >/dev/null 2>&1
    systemctl start docker >/dev/null 2>&1

    if docker --version &>/dev/null; then
        success "Docker $(docker --version | cut -d' ' -f3 | tr -d ',')"
    fi
}

setup_ssh() {
    info "Installing SSH..."
    nala install -y openssh-server

    systemctl enable ssh >/dev/null 2>&1

    configure_sshd

    systemctl restart ssh >/dev/null 2>&1
    success "SSH configured"
}
