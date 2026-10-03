#!/usr/bin/env python3

"""
CyberSDR Console
SDR console by V1RU5 & SK7LD

Terminal-based OpenWebRX country selector with cyberpunk interface theme.
"""

import os
import shutil
import subprocess
import sys
import webbrowser
from pathlib import Path

APP_DIR = Path.home() / ".cybersdr"
CSS_FILE = APP_DIR / "cybersdr.css"

BANNER = r"""
   ██████╗██╗   ██╗██████╗ ███████╗██████╗     ███████╗██████╗ ██████╗ 
  ██╔════╝╚██╗ ██╔╝██╔══██╗██╔════╝██╔══██╗    ██╔════╝██╔══██╗██╔══██╗
  ██║      ╚████╔╝ ██████╔╝█████╗  ██████╔╝    ███████╗██║  ██║██████╔╝
  ██║       ╚██╔╝  ██╔══██╗██╔══╝  ██╔══██╗    ╚════██║██║  ██║██╔══██╗
  ╚██████╗   ██║   ██████╔╝███████╗██║  ██║    ███████║██████╔╝██║  ██║
   ╚═════╝   ╚═╝   ╚═════╝ ╚══════╝╚═╝  ╚═╝    ╚══════╝╚═════╝ ╚═╝  ╚═╝

                     Sdr console by V1RU5 & SK7LD
"""

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
    """Open a URL in a graphical browser."""
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

    webbrowser.open(url)


def show_server_menu() -> str | None:
    """Display the country selection menu using whiptail."""
    if not command_exists("whiptail"):
        print("ERROR: whiptail is not installed.")
        print("Install it with: sudo apt install whiptail")
        return None

    menu_items = []
    for index, (country, url) in enumerate(SERVERS, start=1):
        menu_items.extend([str(index), f"{country:<18} [{url}]"])

    try:
        result = subprocess.run(
            [
                "whiptail",
                "--title",
                "CYBER-SDR - Sdr console by V1RU5 & SK7LD",
                "--menu",
                "Select an OpenWebRX SDR Country Server:",
                "22",
                "75",
                "14",
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
    """Create a local CyberSDR cyberpunk dashboard."""
    dashboard = APP_DIR / "dashboard.html"

    html = """<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>CYBER-SDR Console</title>
<style>
:root {
    --bg: #000000;
    --purple: #bf00ff;
    --green: #00ff66;
    --blue: #00f0ff;
}

* { box-sizing: border-box; }

body {
    margin: 0;
    min-height: 100vh;
    background: radial-gradient(circle at center, rgba(191,0,255,0.15), transparent 60%), #000000;
    color: #e8e8e8;
    font-family: "Courier New", monospace;
    display: flex;
    align-items: center;
    justify-content: center;
}

.console {
    width: min(900px, 90vw);
    border: 1px solid var(--purple);
    padding: 40px;
    background: rgba(5,5,12,0.96);
    box-shadow: 0 0 15px rgba(191,0,255,0.6), 0 0 40px rgba(191,0,255,0.2);
}

h1 {
    margin-top: 0;
    color: var(--green);
    text-shadow: 0 0 8px var(--green), 0 0 20px rgba(0,255,102,0.5);
    letter-spacing: 2px;
}

.subtitle {
    color: var(--blue);
    font-weight: bold;
}

.server {
    margin-top: 30px;
    padding: 20px;
    border-left: 3px solid var(--purple);
    background: rgba(191,0,255,0.05);
}

a { color: var(--blue); text-decoration: none; }
a:hover { color: var(--green); text-shadow: 0 0 10px var(--green); }
.status { color: var(--green); font-weight: bold; }
.credits { color: var(--purple); margin-top: 20px; font-size: 0.9em; }
</style>
</head>

<body>
<div class="console">
<h1>CYBER-SDR CONSOLE</h1>
<p class="subtitle">GLOBAL OPENWEBRX SDR ACCESS TERMINAL</p>
<p class="credits">Sdr console by V1RU5 & SK7LD</p>

<div class="server">
<p class="status">[ SYSTEM OPERATIONAL ]</p>
<p>Use the CyberSDR terminal selector to choose an OpenWebRX server by country.</p>
<p>Cyberpunk Stylesheet loaded at: <br><code>~/.cybersdr/cybersdr.css</code></p>
</div>
</div>
</body>
</html>
"""
    dashboard.write_text(html, encoding="utf-8")
    return dashboard


def main() -> int:
    """Main CyberSDR application entry point."""
    print("\033[0;35m" + BANNER + "\033[0m")
    
    create_local_dashboard()

    selected_url = show_server_menu()

    if selected_url is None:
        print("\033[0;31mNo server selected. Exiting CYBER-SDR.\033[0m")
        return 0

    print()
    print(f"\033[0;36m[CYBER-SDR]\033[0m Connecting to OpenWebRX server:")
    print(f"  \033[0;32m{selected_url}\033[0m")
    print()

    open_browser(selected_url)

    print("\033[0;32m[ OK ] Browser launch initiated.\033[0m\n")
    return 0


if __name__ == "__main__":
    sys.exit(main())
