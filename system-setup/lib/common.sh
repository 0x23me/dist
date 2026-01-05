#!/usr/bin/env bash

setup_colors() {
    if [[ -t 1 ]] && [[ "${TERM-}" != "dumb" ]]; then
        RED='\033[0;31m'
        GREEN='\033[0;32m'
        YELLOW='\033[1;33m'
        BLUE='\033[0;34m'
        MAGENTA='\033[0;35m'
        CYAN='\033[0;36m'
        GRAY='\033[0;90m'
        ORANGE='\033[38;2;255;135;0m'
        BOLD='\033[1m'
        NC='\033[0m'
    else
        RED='' GREEN='' YELLOW='' BLUE='' MAGENTA='' CYAN='' GRAY='' ORANGE='' BOLD='' NC=''
    fi
}

setup_colors

info()    { printf "${ORANGE}[*]${NC} %s\n" "$*"; }
success() { printf "${GREEN}[OK]${NC} %s\n" "$*"; }
warn()    { printf "${YELLOW}[!]${NC} %s\n" "$*" >&2; }
error()   { printf "${RED}[ERROR]${NC} %s\n" "$*" >&2; }
die()     { error "$*"; exit 1; }

stage() {
    echo ""
    printf "${BOLD}${MAGENTA}=== %s ===${NC}\n" "$1"
    echo ""
}

has_cmd() {
    command -v "$1" &>/dev/null
}

need_cmd() {
    if ! has_cmd "$1"; then
        die "Required command not found: $1"
    fi
}

print_banner() {
    echo ""
    printf "${CYAN}"
    cat << 'EOF'
    ____       __    _           _____ _____    ____              __       __
   / __ \___  / /_  (_)___ _____<  /__|__  /   / __ )____  ____  / /______/ /__________ _____
  / / / / _ \/ __ \/ / __ `/ __ \  /_ /_ <   / __  / __ \/ __ \/ __/ ___/ __/ ___/ __ `/ __ \
 / /_/ /  __/ /_/ / / /_/ / / / / /___/ __/  / /_/ / /_/ / /_/ / /_(__  ) /_/ /  / /_/ / /_/ /
/_____/\___/_.___/_/\__,_/_/ /_/_//____/    /_____/\____/\____/\__/____/\__/_/   \__,_/ .___/
                                                                                      /_/
EOF
    printf "${NC}\n"
}
