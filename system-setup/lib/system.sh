#!/usr/bin/env bash

detect_distro() {
    if [[ -f /etc/alpine-release ]]; then
        echo "alpine"
    elif [[ -f /etc/debian_version ]]; then
        echo "debian"
    else
        die "Unsupported distro"
    fi
}

configure_zsh_shell() {
    local zsh_path=$(which zsh 2>/dev/null || echo "/usr/bin/zsh")

    if ! grep -q "^${zsh_path}$" /etc/shells 2>/dev/null; then
        echo "$zsh_path" >> /etc/shells
    fi
}

ensure_felix_user() {
    if ! id "felix" &>/dev/null; then
        info "Creating user felix..."
        useradd -m -s /bin/zsh felix 2>/dev/null
        passwd -d felix >/dev/null 2>&1
    fi

    usermod -aG sudo,docker felix 2>/dev/null || true
}

install_uv() {
    if has_cmd uv; then
        return 0
    fi

    info "Installing uv..."
    curl -LsSf https://astral.sh/uv/install.sh 2>/dev/null | sh >/dev/null 2>&1
}

configure_sshd() {
    local sshd_config="/etc/ssh/sshd_config"
    local config_updated=false

    if ! grep -q "^PermitRootLogin yes" "$sshd_config"; then
        if grep -q "^#\?PermitRootLogin" "$sshd_config"; then
            sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin yes/' "$sshd_config"
        else
            echo "PermitRootLogin yes" >> "$sshd_config"
        fi
        config_updated=true
    fi

    if ! grep -q "^PasswordAuthentication yes" "$sshd_config"; then
        if grep -q "^#\?PasswordAuthentication" "$sshd_config"; then
            sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication yes/' "$sshd_config"
        else
            echo "PasswordAuthentication yes" >> "$sshd_config"
        fi
        config_updated=true
    fi

    if [[ "$config_updated" == "true" ]]; then
        success "SSH configured"
    fi
}

setup_system() {
    local distro=$(detect_distro)
    source_lib "packages_${distro}.sh"

    install_packages
    configure_zsh_shell
    ensure_felix_user
    install_uv
    setup_docker
    setup_ssh
}
