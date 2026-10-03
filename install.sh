#!/usr/bin/env bash
#
# CyberSDR Console - Installation Script
# ---------------------------------------
# Installs a terminal-based OpenWebRX country selector with a
# cyberpunk-themed local dashboard/wrapper.
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

   ██████╗██╗   ██╗██████╗ ███████╗██████╗ ███████╗██████╗
  ██╔════╝╚██╗ ██╔╝██╔══██╗██╔════╝██╔══██╗██╔════╝██╔══██╗
  ██║      ╚████╔╝ ██████╔╝█████╗  ███████╔╝█████╗  ██████╔╝
  ██║       ╚██╔╝  ██╔══██╗██╔══╝  ██╔══██╗ ██╔══╝  ██╔══██╗
  ╚██████╗   ██║   ██████╔╝███████╗██║  ██║███████╗██║  ██║
   ╚═════╝   ╚═╝   ╚═════╝ ╚══════╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝

            SDR  CONSOLE  BY  V1RU5  &  SK7LD

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

    # Chromium package names vary between Debian-based distributions.
    # We install the common dependencies first.
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

    # -----------------------------------------------------------------------
    # Browser detection
    # -----------------------------------------------------------------------

    if command -v chromium >/dev/null 2>&1; then
        success "Chromium detected."
        return
    fi

    if command -v chromium-browser >/dev/null 2>&1; then
        success "Chromium detected."
        return
    fi

    if command -v google-chrome >/dev/null 2>&1; then
        success "Google Chrome detected."
        return
    fi

    # Try Debian/Raspberry Pi Chromium packages.
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
# Create application directories
# ---------------------------------------------------------------------------

create_directories() {
    info "Creating CyberSDR directories..."

    mkdir -p "${APP_DIR}"
    mkdir -p "${BIN_DIR}"
    mkdir -p "${DESKTOP_DIR}"

    success "Application directories created."
}

# ---------------------------------------------------------------------------
# Create Cyberpunk CSS
# ---------------------------------------------------------------------------

create_css() {
    info "Creating CyberSDR cyberpunk CSS..."

    cat > "${CSS_FILE}" <<'EOF'
/*
 * CyberSDR Console
 * Cyberpunk OpenWebRX visual theme
 *
 * Main palette:
 *   Background:  #0a0a10
 *   Purple:      #bf00ff
 *   Green:       #00ff66
 *   Blue:        #00f0ff
 */

:root {
    --cyber-bg: #0a0a10;
    --cyber-black: #000000;
    --cyber-purple: #bf00ff;
    --cyber-purple-dark: #65008a;
    --cyber-green: #00ff66;
    --cyber-blue: #00f0ff;
    --cyber-text: #e6e6e6;
}

html,
body {
    background:
        radial-gradient(
            circle at top,
            rgba(191, 0, 255, 0.08),
            transparent 35%
        ),
        #0a0a10 !important;

    color: var(--cyber-text) !important;
}

/*
 * Generic panels and containers.
 */
div,
section,
article,
nav,
aside {
    scrollbar-color: var(--cyber-purple) var(--cyber-black);
}

/*
 * Dark panels.
 */
.panel,
.card,
.container,
.modal-content,
.dropdown-menu {
    background-color: rgba(5, 5, 12, 0.96) !important;
    border-color: rgba(191, 0, 255, 0.45) !important;
}

/*
 * Links.
 */
a {
    color: var(--cyber-blue) !important;
}

a:hover {
    color: var(--cyber-green) !important;
    text-shadow:
        0 0 5px var(--cyber-green),
        0 0 15px var(--cyber-green);
}

/*
 * Buttons.
 */
button,
.btn,
input[type="button"],
input[type="submit"] {
    background: #090912 !important;
    color: var(--cyber-green) !important;
    border: 1px solid var(--cyber-green) !important;
    box-shadow:
        0 0 5px rgba(0, 255, 102, 0.35),
        inset 0 0 5px rgba(0, 255, 102, 0.08);

    transition:
        background 0.15s ease,
        color 0.15s ease,
        box-shadow 0.15s ease;
}

button:hover,
.btn:hover,
input[type="button"]:hover,
input[type="submit"]:hover {
    background: var(--cyber-green) !important;
    color: #000000 !important;

    box-shadow:
        0 0 8px var(--cyber-green),
        0 0 25px rgba(0, 255, 102, 0.45);
}

/*
 * Inputs and selectors.
 */
input,
select,
textarea {
    background: #050509 !important;
    color: var(--cyber-blue) !important;

    border: 1px solid var(--cyber-purple) !important;
}

input:focus,
select:focus,
textarea:focus {
    outline: none !important;

    border-color: var(--cyber-blue) !important;

    box-shadow:
        0 0 5px var(--cyber-blue),
        0 0 15px rgba(0, 240, 255, 0.35) !important;
}

/*
 * Headers.
 */
h1,
h2,
h3,
h4,
h5,
h6 {
    color: var(--cyber-purple) !important;

    text-shadow:
        0 0 5px rgba(191, 0, 255, 0.8),
        0 0 15px rgba(191, 0, 255, 0.35);
}

/*
 * Spectrum / waterfall areas.
 */
canvas {
    border-color: var(--cyber-purple) !important;
}

/*
 * Status indicators.
 */
.status,
.connected,
.online {
    color: var(--cyber-green) !important;
}

/*
 * CyberSDR custom scrollbars.
 */
::-webkit-scrollbar {
    width: 8px;
    height: 8px;
}

::-webkit-scrollbar-track {
    background: #000000;
}

::-webkit-scrollbar-thumb {
    background: var(--cyber-purple);
    border-radius: 4px;
}

::-webkit-scrollbar-thumb:hover {
    background: var(--cyber-blue);
}

/*
 * Selection.
 */
::selection {
    background: var(--cyber-purple);
    color: #ffffff;
}
EOF

    success "Cyberpunk CSS created."
}

# ---------------------------------------------------------------------------
# Create Python CLI application
# ---------------------------------------------------------------------------

create_python_application() {
    info "Creating CyberSDR Console application..."

    cat > "${CLI_SCRIPT}" <<'PYTHON'
#!/usr/bin/env python3

"""
CyberSDR Console

Terminal-based OpenWebRX country selector.

The application intentionally keeps the country/server mapping local so
that it can be easily modified as OpenWebRX deployments change.

CyberSDR opens the selected server using the user's default graphical
browser. A local cyberpunk landing page is also available from the
application directory.
"""

import os
import shutil
import subprocess
import sys
import webbrowser
from pathlib import Path


APP_DIR = Path.home() / ".cybersdr"
CSS_FILE = APP_DIR / "cybersdr.css"


# ---------------------------------------------------------------------------
# OpenWebRX server catalogue
# ---------------------------------------------------------------------------
#
# These are example country entry points. OpenWebRX installations and
# aggregators can change over time, so the mapping is intentionally kept
# simple and easy to edit.
#
# Add additional entries using:
#
#     ("Country", "https://example.com/")
#
# ---------------------------------------------------------------------------

SERVERS = [
    ("Netherlands", "https://openwebrx.nl/"),
    ("Germany", "https://openwebrx.de/"),
    ("Belgium", "https://openwebrx.be/"),
    ("United States", "https://openwebrx.us/"),
    ("France", "https://openwebrx.fr/"),
    ("United Kingdom", "https://www.openwebrx.co.uk/"),
    ("Switzerland", "https://openwebrx.ch/"),
    ("Austria", "https://openwebrx.at/"),
    ("Denmark", "https://openwebrx.dk/"),
    ("Finland", "https://openwebrx.fi/"),
    ("Norway", "https://openwebrx.no/"),
    ("Sweden", "https://openwebrx.se/"),
    ("Spain", "https://openwebrx.es/"),
    ("Italy", "https://openwebrx.it/"),
]


def command_exists(command: str) -> bool:
    """Return True when a command exists in PATH."""
    return shutil.which(command) is not None


def open_browser(url: str) -> None:
    """
    Open a URL in a graphical browser.

    Prefer Chromium-family browsers where available, then fall back to
    Python's webbrowser module / xdg-open.
    """

    browsers = [
        "chromium",
        "chromium-browser",
        "google-chrome",
        "google-chrome-stable",
    ]

    for browser in browsers:
        if command_exists(browser):
            try:
                subprocess.Popen(
                    [browser, "--new-window", url],
                    stdout=subprocess.DEVNULL,
                    stderr=subprocess.DEVNULL,
                )
                return
            except OSError:
                pass

    # xdg-open is preferred on most Linux desktop environments.
    if command_exists("xdg-open"):
        try:
            subprocess.Popen(
                ["xdg-open", url],
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL,
            )
            return
        except OSError:
            pass

    # Final fallback.
    webbrowser.open(url)


def show_server_menu() -> str | None:
    """
    Display the country selection menu using whiptail.

    Returns the selected URL or None if the user cancels.
    """

    if not command_exists("whiptail"):
        print("ERROR: whiptail is not installed.")
        print("Install it with:")
        print("  sudo apt install whiptail")
        return None

    menu_items = []

    for index, (country, url) in enumerate(SERVERS, start=1):
        menu_items.extend([str(index), country])

    try:
        result = subprocess.run(
            [
                "whiptail",
                "--title",
                "CyberSDR Console",
                "--menu",
                "Select an OpenWebRX country:",
                "20",
                "70",
                "12",
                *menu_items,
            ],
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
        )
    except OSError as exc:
        print(f"Unable to start whiptail: {exc}")
        return None

    if result.returncode != 0:
        return None

    selection = result.stdout.strip()

    if not selection:
        return None

    try:
        index = int(selection) - 1
        return SERVERS[index][1]
    except (ValueError, IndexError):
        return None


def create_local_dashboard() -> Path:
    """
    Create a minimal local CyberSDR dashboard.

    This page provides CyberSDR branding and links to the CSS used by
    the application. The actual OpenWebRX interface is opened directly
    in the browser because arbitrary third-party pages cannot safely
    have local CSS injected by a normal web page.
    """

    dashboard = APP_DIR / "dashboard.html"

    html = """<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">

<title>CyberSDR Console</title>

<style>
:root {
    --bg: #0a0a10;
    --purple: #bf00ff;
    --green: #00ff66;
    --blue: #00f0ff;
}

* {
    box-sizing: border-box;
}

body {
    margin: 0;
    min-height: 100vh;

    background:
        radial-gradient(
            circle at center,
            rgba(191,0,255,0.12),
            transparent 45%
        ),
        #000000;

    color: #e8e8e8;

    font-family:
        "Courier New",
        monospace;

    display: flex;
    align-items: center;
    justify-content: center;
}

.console {
    width: min(900px, 90vw);

    border:
        1px solid var(--purple);

    padding: 40px;

    background:
        rgba(5,5,12,0.96);

    box-shadow:
        0 0 10px rgba(191,0,255,0.6),
        0 0 40px rgba(191,0,255,0.15);
}

h1 {
    margin-top: 0;

    color: var(--green);

    text-shadow:
        0 0 8px var(--green),
        0 0 20px rgba(0,255,102,0.5);
}

.subtitle {
    color: var(--blue);
}

.server {
    margin-top: 30px;

    padding: 20px;

    border-left:
        3px solid var(--purple);

    background:
        rgba(191,0,255,0.04);
}

a {
    color: var(--blue);
    text-decoration: none;
}

a:hover {
    color: var(--green);

    text-shadow:
        0 0 10px var(--green);
}

.status {
    color: var(--green);
}
</style>
</head>

<body>

<div class="console">

<h1>CYBERSDR CONSOLE</h1>

<p class="subtitle">
GLOBAL OPENWEBRX SDR ACCESS TERMINAL
</p>

<div class="server">

<p class="status">
[ SYSTEM ONLINE ]
</p>

<p>
Use the CyberSDR terminal selector to choose an OpenWebRX
server by country.
</p>

<p>
Cyberpunk stylesheet:
<br>
<code>~/.cybersdr/cybersdr.css</code>
</p>

</div>

</div>

</body>
</html>
"""

    dashboard.write_text(html, encoding="utf-8")

    return dashboard


def main() -> int:
    """Main CyberSDR application entry point."""

    print()
    print("==============================================")
    print("          CYBERSDR CONSOLE")
    print("       GLOBAL OPENWEBRX ACCESS")
    print("==============================================")
    print()

    selected_url = show_server_menu()

    if selected_url is None:
        print("No server selected.")
        return 0

    print()
    print(f"Opening OpenWebRX server:")
    print(f"  {selected_url}")
    print()

    open_browser(selected_url)

    print("Browser launch requested.")
    print()

    return 0


if __name__ == "__main__":
    sys.exit(main())
PYTHON

    chmod +x "${CLI_SCRIPT}"

    success "CyberSDR Python selector created."
}

# ---------------------------------------------------------------------------
# Create launcher command
# ---------------------------------------------------------------------------

create_command() {
    info "Creating global 'cybersdr' user command..."

    cat > "${BIN_DIR}/cybersdr" <<EOF
#!/usr/bin/env bash

exec python3 "${CLI_SCRIPT}" "\$@"
EOF

    chmod +x "${BIN_DIR}/cybersdr"

    # Add ~/.local/bin to PATH if necessary.
    if ! grep -Fq 'export PATH="$HOME/.local/bin:$PATH"' "${BASH_RC}" 2>/dev/null; then
        cat >> "${BASH_RC}" <<'EOF'

# CyberSDR Console
export PATH="$HOME/.local/bin:$PATH"
EOF
    fi

    # Make the command available immediately in the current installer
    # process as well.
    export PATH="${BIN_DIR}:${PATH}"

    success "Command 'cybersdr' created."
}

# ---------------------------------------------------------------------------
# Create desktop shortcut
# ---------------------------------------------------------------------------

create_desktop_shortcut() {
    info "Creating desktop application launcher..."

    local python_path

    python_path="$(command -v python3)"

    cat > "${DESKTOP_FILE}" <<EOF
[Desktop Entry]
Version=1.0
Type=Application

Name=CyberSDR Console
Comment=Cyberpunk OpenWebRX SDR Console

Exec=${python_path} ${CLI_SCRIPT}
Icon=utilities-terminal

Terminal=true

Categories=Network;HamRadio;AudioVideo;Utility;
Keywords=SDR;OpenWebRX;Radio;CyberSDR;
EOF

    chmod +x "${DESKTOP_FILE}"

    # Refresh desktop application database when available.
    if command -v update-desktop-database >/dev/null 2>&1; then
        update-desktop-database "${DESKTOP_DIR}" >/dev/null 2>&1 || true
    fi

    success "Desktop launcher created."
}

# ---------------------------------------------------------------------------
# Create local dashboard
# ---------------------------------------------------------------------------

create_dashboard() {
    info "Creating CyberSDR dashboard..."

    create_local_dashboard

    success "Local dashboard created:"
    printf "       %s\n" "${APP_DIR}/dashboard.html"
}

# ---------------------------------------------------------------------------
# Verify installation
# ---------------------------------------------------------------------------

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

# ---------------------------------------------------------------------------
# Post-installation information
# ---------------------------------------------------------------------------

print_completion() {
    printf "\n"
    printf "${PURPLE}"
    printf "============================================================\n"
    printf "                 CYBERSDR CONSOLE READY\n"
    printf "============================================================\n"
    printf "${RESET}\n"

    printf "${GREEN}Installation completed successfully.${RESET}\n\n"

    printf "${CYAN}Launch from terminal:${RESET}\n"
    printf "  cybersdr\n\n"

    printf "${CYAN}Application directory:${RESET}\n"
    printf "  %s\n\n" "${APP_DIR}"

    printf "${CYAN}Cyberpunk CSS:${RESET}\n"
    printf "  %s\n\n" "${CSS_FILE}"

    printf "${CYAN}Local dashboard:${RESET}\n"
    printf "  %s\n\n" "${APP_DIR}/dashboard.html"

    printf "${CYAN}Desktop launcher:${RESET}\n"
    printf "  %s\n\n" "${DESKTOP_FILE}"

    printf "${YELLOW}Important:${RESET}\n"
    printf "  OpenWebRX installations are independently operated.\n"
    printf "  Server URLs can change or become unavailable over time.\n\n"

    printf "${CYAN}If 'cybersdr' is not immediately available in an existing\n"
    printf "terminal, run:${RESET}\n\n"

    printf "  source ~/.bashrc\n\n"

    printf "${GREEN}Ready. Run:${RESET} cybersdr\n\n"
}

# ---------------------------------------------------------------------------
# Main installer
# ---------------------------------------------------------------------------

main() {
    print_banner

    check_os
    check_sudo

    install_dependencies

    create_directories
    create_css
    create_python_application
    create_dashboard
    create_command
    create_desktop_shortcut

    verify_installation

    print_completion
}

main "$@"