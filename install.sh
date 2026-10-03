#!/usr/bin/env bash
#
# CyberSDR Console - Installation Script
# ---------------------------------------
# Installs a terminal-based OpenWebRX country selector with a
# cyberpunk-themed local dashboard/wrapper.
#
# Authors: V1RU5 & SK7LD
#

set -euo pipefail

# ---------------------------------------------------------------------------
# Configuration
# ---------------------------------------------------------------------------

APP_NAME="CyberSDR Console"
APP_DIR="${HOME}/.cybersdr"
GLOBAL_BIN_DIR="/usr/local/bin"
DESKTOP_DIR="${HOME}/.local/share/applications"

CLI_SCRIPT="${APP_DIR}/cybersdr.py"
CSS_FILE="${APP_DIR}/cybersdr.css"
DESKTOP_FILE="${DESKTOP_DIR}/cybersdr.desktop"

# ---------------------------------------------------------------------------
# Colors
# ---------------------------------------------------------------------------

GREEN='\033[0;32m'
CYAN='\033[0;36m'
PURPLE='\033[0;35m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
RESET='\033[0m'

print_banner() {
    clear
    printf "${PURPLE}"
    cat <<'EOF'

   ██████╗██╗   ██╗██████╗ ███████╗██████╗     ███████╗██████╗ ██████╗ 
  ██╔════╝╚██╗ ██╔╝██╔══██╗██╔════╝██╔══██╗    ██╔════╝██╔══██╗██╔══██╗
  ██║      ╚████╔╝ ██████╔╝█████╗  ██████╔╝    ███████╗██║  ██║██████╔╝
  ██║       ╚██╔╝  ██╔══██╗██╔══╝  ██╔══██╗    ╚════██║██║  ██║██╔══██╗
  ╚██████╗   ██║   ██████╔╝███████╗██║  ██║    ███████║██████╔╝██║  ██║
   ╚═════╝   ╚═╝   ╚═════╝ ╚══════╝╚═╝  ╚═╝    ╚══════╝╚═════╝ ╚══════╝

                     Sdr console by V1RU5 & SK7LD

EOF
    printf "${RESET}"
    printf "${CYAN}CyberSDR Console Installation${RESET}\n"
    printf "${CYAN}--------------------------------${RESET}\n\n"
}

info() { printf "${CYAN}[INFO]${RESET} %s\n" "$1"; }
success() { printf "${GREEN}[ OK ]${RESET} %s\n" "$1"; }
warning() { printf "${YELLOW}[WARN]${RESET} %s\n" "$1"; }
error() { printf "${RED}[ERROR]${RESET} %s\n" "$1"; }

check_os() {
    if [[ -f /etc/os-release ]]; then
        source /etc/os-release
        success "Detected OS: ${PRETTY_NAME:-Linux}"
    fi
}

install_dependencies() {
    info "Updating package list and installing dependencies..."
    apt-get update -y
    apt-get install -y whiptail python3 python3-pip curl git ca-certificates xdg-utils desktop-file-utils
    success "Dependencies installed."
}

create_directories() {
    info "Creating application directories..."
    mkdir -p "${APP_DIR}"
    mkdir -p "${DESKTOP_DIR}"
    mkdir -p "${GLOBAL_BIN_DIR}"
    success "Directories ready."
}

copy_app_files() {
    info "Copying script files..."
    SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

    if [[ -f "${SCRIPT_DIR}/cybersdr.py" ]]; then
        cp "${SCRIPT_DIR}/cybersdr.py" "${CLI_SCRIPT}"
    else
        error "cybersdr.py not found in installation folder!"
        exit 1
    fi

    if [[ -f "${SCRIPT_DIR}/cybersdr.css" ]]; then
        cp "${SCRIPT_DIR}/cybersdr.css" "${CSS_FILE}"
    fi

    chmod +x "${CLI_SCRIPT}"
    success "App files copied."
}

create_global_command() {
    info "Creating global system command in /usr/local/bin..."

    cat > "${GLOBAL_BIN_DIR}/cybersdr" <<EOF
#!/usr/bin/env bash
exec python3 "${CLI_SCRIPT}" "\$@"
EOF

    chmod +x "${GLOBAL_BIN_DIR}/cybersdr"
    success "Global command 'cybersdr' created in ${GLOBAL_BIN_DIR}."
}

create_desktop_shortcut() {
    info "Creating desktop application launcher..."
    python_path="$(command -v python3)"

    cat > "${DESKTOP_FILE}" <<EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=CyberSDR Console
Comment=Cyberpunk OpenWebRX SDR Console by V1RU5 & SK7LD
Exec=${python_path} ${CLI_SCRIPT}
Icon=utilities-terminal
Terminal=true
Categories=Network;HamRadio;AudioVideo;Utility;
Keywords=SDR;OpenWebRX;Radio;CyberSDR;
EOF

    chmod +x "${DESKTOP_FILE}"
    success "Desktop shortcut created."
}

print_completion() {
    printf "\n"
    printf "${PURPLE}============================================================${RESET}\n"
    printf "${PURPLE}                 CYBERSDR CONSOLE READY                     ${RESET}\n"
    printf "${PURPLE}                 by V1RU5 & SK7LD                           ${RESET}\n"
    printf "${PURPLE}============================================================${RESET}\n\n"

    printf "${GREEN}Installation completed successfully.${RESET}\n\n"
    printf "${CYAN}Launch immediately from any terminal:${RESET}\n"
    printf "  cybersdr\n\n"
}

main() {
    print_banner
    check_os
    install_dependencies
    create_directories
    copy_app_files
    create_global_command
    create_desktop_shortcut
    print_completion
}

main "$@"
