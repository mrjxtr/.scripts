#!/bin/bash

echo -e "\nChanging vscode extensions permissions"

sudo chown -R $(whoami) "$(which code)"
sudo chown -R $(whoami) /opt/visual-studio-code

echo -e "\nDone"
