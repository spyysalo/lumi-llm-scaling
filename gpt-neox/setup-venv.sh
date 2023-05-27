#!/bin/bash

# Set up virtual environment for GPT-NeoX

# This script creates the directory venv. If this exists, ask to
# delete.
for p in venv; do
    if [ -e "$p" ]; then
	read -n 1 -r -p "$p exists. OK to remove? [y/n] "
	echo
	if [[ $REPLY =~ ^[Yy]$ ]]; then
            echo "Removing $p."
	    rm -rf "$p"
	else
            echo "Exiting."
            exit 1
	fi
    fi
done

# Load modules
source load-modules.sh

# Create and activate venv
python -m venv venv
source venv/bin/activate

# Upgrade pip etc.
python -m pip install --upgrade pip setuptools wheel

# Install torch
python -m pip install --upgrade torch==1.13.1+rocm5.2 --extra-index-url https://download.pytorch.org/whl/rocm5.2
