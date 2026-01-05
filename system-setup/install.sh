#!/usr/bin/env bash
#
# System Bootstrap Script (Debian/Alpine)
# Usage: curl -fsSL https://raw.githubusercontent.com/0x23me/dist/refs/heads/main/system-setup/install.sh | bash

set -Eeuo pipefail

GITHUB_RAW="https://raw.githubusercontent.com/0x23me/dist/main/system-setup"

TMPDIR=""

cleanup() {
    local exit_code=$?
    [[ -n "${TMPDIR:-}" ]] && rm -rf "$TMPDIR"
    if [[ $exit_code -ne 0 ]]; then
        echo -e "\033[0;31m[ERROR]\033[0m Installation failed"
    fi
    exit $exit_code
}

trap cleanup EXIT ERR INT TERM

TMPDIR=$(mktemp -d)

source_lib() {
    local lib="$1"
    local local_path="$(dirname "$0")/lib/$lib"

    if [[ -f "$local_path" ]]; then
        source "$local_path"
    else
        curl -fsSL "$GITHUB_RAW/lib/$lib" -o "$TMPDIR/$lib" 2>/dev/null
        source "$TMPDIR/$lib"
    fi
}

source_lib common.sh
source_lib system.sh
source_lib shell.sh

main() {
    print_banner

    if [[ $EUID -eq 0 ]]; then
        stage "System Setup"
        setup_system

        stage "Root Configuration"
        setup_current_user

        echo ""
        success "Bootstrap complete"
        info "Run as user to configure their shell: su - felix && ./install.sh"
        echo ""
    else
        stage "User Configuration"
        setup_current_user

        echo ""
        success "Configuration complete"
        info "Activate: source ~/.zshrc"
        echo ""
    fi
}

main "$@"
