# CYBER-SDR Console

```text
   ██████╗██╗   ██╗██████╗ ███████╗██████╗     ███████╗██████╗ ██████╗ 
  ██╔════╝╚██╗ ██╔╝██╔══██╗██╔════╝██╔══██╗    ██╔════╝██╔══██╗██╔══██╗
  ██║      ╚████╔╝ ██████╔╝█████╗  ██████╔╝    ███████╗██║  ██║██████╔╝
  ██║       ╚██╔╝  ██╔══██╗██╔══╝  ██╔══██╗    ╚════██║██║  ██║██╔══██╗
  ╚██████╗   ██║   ██████╔╝███████╗██║  ██║    ███████║██████╔╝██║  ██║
   ╚═════╝   ╚═╝   ╚═════╝ ╚══════╝╚═╝  ╚═╝    ╚══════╝╚═════╝ ╚══════╝

                     Sdr console by V1RU5 & SK7LD

CYBER-SDR Console is a terminal-based Linux and Raspberry Pi application designed to quickly select and connect to global OpenWebRX SDR (Software Defined Radio) servers through an intuitive CLI menu with a neon cyberpunk aesthetics wrapper.
Features
Global OpenWebRX Selector: Easily pick from preset OpenWebRX nodes across various countries (.nl, .de, .be, .us, .fr, and more).
Cyberpunk Visual Styling: Custom stylesheet embedded with Deep Black background #000000 and high-contrast Neon Purple (#bf00ff), Neon Green (#00ff66), and Cyber Blue (#00f0ff).
Terminal GUI Interface: Built-in interactive menu utilizing whiptail.

System Integration: Installs direct executable command cybersdr and standard Linux desktop menu launcher.
Debian / Pi OS Ready: Tested and structured for Debian, Ubuntu, Linux Mint, and Raspberry Pi OS.
Installation
Clone the GitHub repository and run the automated installer:

git clone [https://github.com/your-username/cybersdr-console.git](https://github.com/your-username/cybersdr-console.git)
cd cybersdr-console
chmod +x install.sh
./install.sh

Usage
Launch from any Linux CLI prompt:

cybersdr

Or locate CyberSDR Console in your desktop application menu under Radio / Utilities.
Installation Directory Structure

~/.cybersdr/
├── cybersdr.py        # Core Python CLI Selector
├── cybersdr.css       # Neon Cyberpunk Stylesheet
└── dashboard.html     # Local CyberSDR Landing Page

Credits & Authors
Created and maintained by V1RU5 & SK7LD.
