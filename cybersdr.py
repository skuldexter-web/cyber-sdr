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
   ╚═════╝   ╚═╝   ╚═════╝ ╚══════╝╚═╝  ╚═╝    ╚══════╝╚═════╝ ╚══════╝

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
    return shutil.which(command) is not None


def open_browser(url: str) -> None:
    browsers = [
        "chromium",
        "chromium-browser",
        "google-chrome",
        "firefox",
    ]

    for browser in browsers:
        if command_exists(browser):
            try:
                subprocess.Popen(
                    [browser, url],
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


def show_whiptail_menu() -> str | None:
    if not command_exists("whiptail"):
        return None

    menu_items = []
    for index, (country, url) in enumerate(SERVERS, start=1):
        menu_items.extend([str(index), f"{country:<16} [{url}]"])

    try:
        # TTY expliciet doorgeven voor Kali/Root terminals
        cmd = [
            "whiptail",
            "--title",
            "CYBER-SDR - Sdr console by V1RU5 & SK7LD",
            "--menu",
            "Select an OpenWebRX SDR Country Server:",
            "20",
            "70",
            "12",
            *menu_items,
        ]
        
        result = subprocess.run(
            cmd,
            stderr=subprocess.PIPE,
            stdout=subprocess.PIPE,
            text=True
        )

        if result.returncode == 0 and result.stderr.strip():
            selection = result.stderr.strip()
            index = int(selection) - 1
            return SERVERS[index][1]
    except Exception:
        pass

    return None


def show_fallback_menu() -> str | None:
    print("\033[1;36m============================================================\033[0m")
    print("\033[1;35m             SELECT OPENWEBRX SDR SERVER                   \033[0m")
    print("\033[1;36m============================================================\033[0m")
    
    for index, (country, url) in enumerate(SERVERS, start=1):
        print(f"  \033[1;32m[{index:2d}]\033[0m \033[1;37m{country:<16}\033[0m -> \033[0;36m{url}\033[0m")
    
    print("  \033[1;31m[ 0]\033[0m Exit")
    print("\033[1;36m------------------------------------------------------------\033[0m")

    try:
        choice = input("\033[1;33mSelect Option [0-14]: \033[0m").strip()
        if choice == "0" or not choice:
            return None
        
        idx = int(choice) - 1
        if 0 <= idx < len(SERVERS):
            return SERVERS[idx][1]
    except (ValueError, KeyboardInterrupt, EOFError):
        pass

    return None


def create_local_dashboard() -> Path:
    dashboard = APP_DIR / "dashboard.html"
    html = """<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>CYBER-SDR Console</title>
<style>
body { background: #000; color: #00ff66; font-family: monospace; padding: 20px; }
h1 { color: #bf00ff; }
</style>
</head>
<body>
<h1>CYBER-SDR CONSOLE</h1>
<p>System Operational. Managed by V1RU5 & SK7LD.</p>
</body>
</html>"""
    dashboard.write_text(html, encoding="utf-8")
    return dashboard


def main() -> int:
    print("\033[0;35m" + BANNER + "\033[0m")
    create_local_dashboard()

    # Probeer whiptail, val anders terug op de Python CLI menu selector
    selected_url = show_whiptail_menu()
    if selected_url is None:
        selected_url = show_fallback_menu()

    if selected_url is None:
        print("\n\033[0;31m[!] No server selected. Exiting CYBER-SDR.\033[0m\n")
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

