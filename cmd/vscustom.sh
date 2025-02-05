#!/bin/bash
# ========================================================= 
# This script is to activate the Custom CSS and JS loader
# VSCode extension after a vscode update
# =========================================================

echo -e "\nChanging vscode extensions permissions"

sudo chown -R $(whoami) "$(which code)"
sudo chown -R $(whoami) /opt/visual-studio-code

echo -e "\nDone"
