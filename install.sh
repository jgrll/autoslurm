#!/bin/bash
# Installer script - Adds current directory to PATH in .bashrc
#----------------------------------------
# Author: https://github.com/jgrll
# License: MIT License (see LICENSE file)
#----------------------------------------

BASHRC_FILE="$HOME/.bashrc"
MARKER="# autoslurm package (https://github.com/jgrll)"

INSTALL_DIR=$(pwd -P)

if grep -qF "$MARKER" "$BASHRC_FILE"; then
    echo "This directory is already in your PATH (in $BASHRC_FILE)"
    exit 0
fi

cp "$BASHRC_FILE" "${BASHRC_FILE}.bak" && echo "Created backup: ${BASHRC_FILE}.bak"

echo -e "\n$MARKER\nexport PATH=\"\$PATH:$INSTALL_DIR\"" >> "$BASHRC_FILE"

if grep -qF "$INSTALL_DIR" "$BASHRC_FILE"; then
    echo "Successfully added to $BASHRC_FILE:"
    echo "  $INSTALL_DIR"
    echo "Please run 'source $BASHRC_FILE' or restart your terminal to apply changes"
else
    echo "Error: Failed to update $BASHRC_FILE"
    echo "Restoring backup..."
    mv "${BASHRC_FILE}.bak" "$BASHRC_FILE"
    exit 1
fi

