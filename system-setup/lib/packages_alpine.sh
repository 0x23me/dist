#!/usr/bin/env bash

PACKAGES=(
    git
    curl
    make
    zsh
    build-base
    ca-certificates
    gnupg
    htop
    btop
    iotop
    glances
    iperf3
    tmux
    fzf
    eza
)

is_installed() {
    apk info -e "$1" &>/dev/null
}

install_packages() {
    info "Installing packages..."
    apk add --no-cache "${PACKAGES[@]}"
}

setup_docker() {
    info "Installing Docker..."
    apk add --no-cache docker docker-cli-compose

    rc-update add docker boot
    service docker start

    if docker --version &>/dev/null; then
        success "Docker $(docker --version | cut -d' ' -f3 | tr -d ',')"
    fi
}

setup_ssh() {
    info "Installing SSH..."
    apk add --no-cache openssh

    rc-update add sshd
    rc-service sshd start

    configure_sshd

    rc-service sshd restart
    success "SSH configured"
}
