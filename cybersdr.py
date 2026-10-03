#!/usr/bin/env python3

"""
CyberSDR Console
SDR console by V1RU5 & SK7LD
"""

import sys
import shutil
import subprocess
import webbrowser
from pathlib import Path

APP_DIR = Path.home() / ".cybersdr"

BANNER = r"""
   ██████╗██╗   ██╗██████╗ ███████╗██████╗     ███████╗██████╗ ██████╗ 
  ██╔════╝╚██╗ ██╔╝██╔══██╗██╔════╝██╔══██╗    ██╔════╝██╔══██╗██╔══██╗
  ██║      ╚████╔╝ ██████╔╝█████╗  ██████╔╝    ███████╗██║  ██║██████╔╝
  ██║       ╚██╔╝  ██╔══██╗██╔══╝  ██╔══██╗    ╚════██║██║  ██║██╔══██╗
  ╚██████╗   ██║   ██████╔╝███████╗██║  ██║    ███████║██████╔╝██║  ██║
   ╚═════╝   ╚═╝   ╚═════╝ ╚══════╝╚═╝  ╚═╝    ╚══════╝╚═════╝ ╚══════╝

                     Sdr console by V1RU5 & SK7LD
"""

# Country list mapping
SERVERS = [
    ("1", "NL", "Netherlands", "https://openwebrx.nl/"),
    ("2", "BE", "Belgium", "https://openwebrx.be/"),
    ("3", "DE", "Germany", "https://openwebrx.de/"),
    ("4", "FR", "France", "https://openwebrx.fr/"),
    ("5", "US", "United States", "https://openwebrx.us/"),
    ("6", "UK", "United Kingdom", "https://www.openwebrx.co.uk/"),
    ("7", "CH", "Switzerland", "https://openwebrx.ch/"),
    ("8", "AT", "Austria", "https://openwebrx.at/"),
    ("9", "DK", "Denmark", "https://openwebrx.dk/"),
    ("10", "FI", "Finland", "https://openwebrx.fi/"),
    ("11", "NO", "Norway", "https://openwebrx.no/"),
    ("12", "SE", "Sweden", "https://openwebrx.se/"),
    ("13", "ES", "Spain", "https://openwebrx.es/"),
    ("14", "IT", "Italy", "https://openwebrx.it/"),
]


def command_exists(command: str) -> bool:
    return shutil.which(command) is not None


def open_browser(url: str) -> None:
    browsers = ["firefox", "chromium", "google-chrome", "chromium-browser"]

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


def main() -> int:
    print("\033[0;35m" + BANNER + "\033[0m")
    
    print("\033[1;36m============================================================\033[0m")
    print("\033[1;35m             SELECT OPENWEBRX SDR SERVER                    \033[0m")
    print("\033[1;36m============================================================\033[0m")

    for num, code, country, url in SERVERS:
        print(f"  \033[1;32m[{num:>2}]\033[0m \033[1;33m{code}\033[0m - \033[1;37m{country:<15}\033[0m \033[0;36m({url})\033[0m")

    print("  \033[1;31m[ 0]\033[0m Exit")
    print("\033[1;36m------------------------------------------------------------\033[0m")

    try:
        choice = input("\n\033[1;33mSelect Option [1-14]: \033[0m").strip()
    except (KeyboardInterrupt, EOFError):
        print("\n\033[0;31m[!] Aborted.\033[0m")
        return 0

    if choice == "0" or not choice:
        print("\033[0;31mExiting CYBER-SDR.\033[0m")
        return 0

    selected = None
    for num, code, country, url in SERVERS:
        if choice == num or choice.upper() == code:
            selected = (code, url)
            break

    if not selected:
        print("\033[0;31m[!] Invalid selection.\033[0m")
        return 1

    code, url = selected
    print(f"\n\033[0;36m[CYBER-SDR]\033[0m Opening \033[1;33m{code}\033[0m server: \033[0;32m{url}\033[0m")

    open_browser(url)
    print("\033[0;32m[ OK ] Browser launched successfully.\033[0m\n")
    return 0


if __name__ == "__main__":
    sys.exit(main())
