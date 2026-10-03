#!/usr/bin/env bash
#
# CyberSDR Console - Installation Script
# ---------------------------------------
# Installs a terminal-based OpenWebRX country selector with a
# cyberpunk-themed local dashboard/wrapper.
#
# Authors: V1RU5 & SK7LD
#
# Supported systems:
#   - Debian
#   - Ubuntu
#   - Raspberry Pi OS
#
# Usage:
#   chmod +x install.sh
#   ./install.sh
#
# After installation:
#   cybersdr
#
# Everything is installed into:
#   ~/.cybersdr
#

set -euo pipefail

# ---------------------------------------------------------------------------
# Configuration
# ---------------------------------------------------------------------------

APP_NAME="CyberSDR Console"
APP_DIR="${HOME}/.cybersdr"
BIN_DIR="${HOME}/.local/bin"
DESKTOP_DIR="${HOME}/.local/share/applications"

CLI_SCRIPT="${APP_DIR}/cybersdr.py"
CSS_FILE="${APP_DIR}/cybersdr.css"
DESKTOP_FILE="${DESKTOP_DIR}/cybersdr.desktop"
BASH_RC="${HOME}/.bashrc"

# ---------------------------------------------------------------------------
# Colors used by the installer
# ---------------------------------------------------------------------------

GREEN='\033[0;32m'
CYAN='\033[0;36m'
PURPLE='\033[0;35m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
RESET='\033[0m'

# ---------------------------------------------------------------------------
# Helper functions
# ---------------------------------------------------------------------------

print_banner() {
    clear

    printf "${PURPLE}"
    cat <<'EOF'

   ██████╗██╗   ██╗██████╗ ███████╗██████╗     ███████╗██████╗ ██████╗ 
  ██╔════╝╚██╗ ██╔╝██╔══██╗██╔════╝██╔══██╗    ██╔════╝██╔══██╗██╔══██╗
  ██║      ╚████╔╝ ██████╔╝█████╗  ██████╔╝    ███████╗██║  ██║██████╔╝
  ██║       ╚██╔╝  ██╔══██╗██╔══╝  ██╔══██╗    ╚════██║██║  ██║██╔══██╗
  ╚██████╗   ██║   ██████╔╝███████╗██║  ██║    ███████║██████╔╝██║  ██║
   ╚═════╝   ╚═╝   ╚═════╝ ╚══════╝╚═╝  ╚═╝    ╚══════╝╚═════╝ ╚═╝  ╚═╝

                     Sdr console by V1RU5 & SK7LD

EOF
    printf "${RESET}"

    printf "${CYAN}CyberSDR Console installation${RESET}\n"
    printf "${CYAN}--------------------------------${RESET}\n\n"
}

info() {
    printf "${CYAN}[INFO]${RESET} %s\n" "$1"
}

success() {
    printf "${GREEN}[ OK ]${RESET} %s\n" "$1"
}

warning() {
    printf "${YELLOW}[WARN]${RESET} %s\n" "$1"
}

error() {
    printf "${RED}[ERROR]${RESET} %s\n" "$1"
}

# ---------------------------------------------------------------------------
# Check operating system
# ---------------------------------------------------------------------------

check_os() {
    if [[ ! -f /etc/os-release ]]; then
        error "Unable to determine the Linux distribution."
        exit 1
    fi

    # shellcheck disable=SC1091
    source /etc/os-release

    case "${ID:-}" in
        debian|ubuntu|raspbian|linuxmint|pop)
            success "Detected Debian-based system: ${PRETTY_NAME:-unknown}"
            ;;
        *)
            warning "This installer is designed for Debian-based systems."
            warning "Detected: ${PRETTY_NAME:-unknown}"

            if [[ "${EUID}" -ne 0 ]]; then
                warning "Continuing, but package installation may fail."
            fi
            ;;
    esac
}

# ---------------------------------------------------------------------------
# Verify sudo
# ---------------------------------------------------------------------------

check_sudo() {
    if [[ "${EUID}" -eq 0 ]]; then
        warning "Running as root."

        if [[ -z "${SUDO_USER:-}" ]]; then
            warning "The application will be installed for /root."
            warning "For normal desktop usage, run this installer as your"
            warning "regular user rather than using 'sudo ./install.sh'."
        fi

        return
    fi

    if ! command -v sudo >/dev/null 2>&1; then
        error "sudo is required but was not found."
        exit 1
    fi
}

# ---------------------------------------------------------------------------
# Install system dependencies
# ---------------------------------------------------------------------------

install_dependencies() {
    info "Updating package lists..."

    sudo apt-get update

    info "Installing required packages..."

    sudo apt-get install -y \
        whiptail \
        python3 \
        python3-pip \
        python3-venv \
        curl \
        git \
        ca-certificates \
        xdg-utils \
        desktop-file-utils

    success "Core dependencies installed."

    if command -v chromium >/dev/null 2>&1 || command -v chromium-browser >/dev/null 2>&1 || command -v google-chrome >/dev/null 2>&1; then
        success "Chromium-based browser detected."
        return
    fi

    info "Chromium was not detected. Attempting installation..."

    if apt-cache show chromium >/dev/null 2>&1; then
        if sudo apt-get install -y chromium; then
            success "Chromium installed."
            return
        fi
    fi

    if apt-cache show chromium-browser >/dev/null 2>&1; then
        if sudo apt-get install -y chromium-browser; then
            success "Chromium Browser installed."
            return
        fi
    fi

    warning "Chromium could not be installed automatically."
    warning "CyberSDR will use the system default browser instead."
}

# ---------------------------------------------------------------------------
# Create application directories & files
# ---------------------------------------------------------------------------

create_directories() {
    info "Creating CyberSDR directories..."

    mkdir -p "${APP_DIR}"
    mkdir -p "${BIN_DIR}"
    mkdir -p "${DESKTOP_DIR}"

    success "Application directories created."
}

copy_app_files() {
    info "Installing CyberSDR script files..."

    SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

    if [[ -f "${SCRIPT_DIR}/cybersdr.py" ]]; then
        cp "${SCRIPT_DIR}/cybersdr.py" "${CLI_SCRIPT}"
    else
        error "cybersdr.py not found in installer directory!"
        exit 1
    fi

    if [[ -f "${SCRIPT_DIR}/cybersdr.css" ]]; then
        cp "${SCRIPT_DIR}/cybersdr.css" "${CSS_FILE}"
    fi

    chmod +x "${CLI_SCRIPT}"
    success "CyberSDR application files installed."
}

create_command() {
    info "Creating global 'cybersdr' user command..."

    cat > "${BIN_DIR}/cybersdr" <<EOF
#!/usr/bin/env bash

exec python3 "${CLI_SCRIPT}" "\$@"
EOF

    chmod +x "${BIN_DIR}/cybersdr"

    if ! grep -Fq 'export PATH="$HOME/.local/bin:$PATH"' "${BASH_RC}" 2>/dev/null; then
        cat >> "${BASH_RC}" <<'EOF'

# CyberSDR Console
export PATH="$HOME/.local/bin:$PATH"
EOF
    fi

    export PATH="${BIN_DIR}:${PATH}"

    success "Command 'cybersdr' created."
}

create_desktop_shortcut() {
    info "Creating desktop application launcher..."

    local python_path
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

    if command -v update-desktop-database >/dev/null 2>&1; then
        update-desktop-database "${DESKTOP_DIR}" >/dev/null 2>&1 || true
    fi

    success "Desktop launcher created."
}

verify_installation() {
    info "Verifying installation..."

    local failed=0

    [[ -f "${CLI_SCRIPT}" ]] || failed=1
    [[ -f "${CSS_FILE}" ]] || failed=1
    [[ -x "${BIN_DIR}/cybersdr" ]] || failed=1
    [[ -f "${DESKTOP_FILE}" ]] || failed=1

    if [[ "${failed}" -eq 0 ]]; then
        success "CyberSDR Console installation verified."
    else
        error "Installation verification failed."
        exit 1
    fi
}

print_completion() {
    printf "\n"
    printf "${PURPLE}"
    printf "============================================================\n"
    printf "                 CYBERSDR CONSOLE READY\n"
    printf "                 by V1RU5 & SK7LD\n"
    printf "============================================================\n"
    printf "${RESET}\n"

    printf "${GREEN}Installation completed successfully.${RESET}\n\n"

    printf "${CYAN}Launch from terminal:${RESET}\n"
    printf "  cybersdr\n\n"

    printf "${CYAN}Application directory:${RESET}\n"
    printf "  %s\n\n" "${APP_DIR}"

    printf "${CYAN}Cyberpunk CSS:${RESET}\n"
    printf "  %s\n\n" "${CSS_FILE}"

    printf "${CYAN}Desktop launcher:${RESET}\n"
    printf "  %s\n\n" "${DESKTOP_FILE}"

    printf "${YELLOW}Important:${RESET}\n"
    printf "  OpenWebRX installations are independently operated.\n"
    printf "  Server URLs can change or become unavailable over time.\n\n"

    printf "${CYAN}If 'cybersdr' is not immediately available in an existing terminal, run:${RESET}\n\n"

    printf "  source ~/.bashrc\n\n"

    printf "${GREEN}Ready. Run:${RESET} cybersdr\n\n"
}

main() {
    print_banner

    check_os
    check_sudo

    install_dependencies

    create_directories
    copy_app_files
    create_command
    create_desktop_shortcut

    verify_installation

    print_completion
}

main "$@"
