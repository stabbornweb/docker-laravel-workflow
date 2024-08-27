#!/bin/bash

# Check if PHP is installed
if ! command -v php &> /dev/null; then
    echo "PHP is not installed."
    exit 1
fi

# Prompt for user input
read -p "Enter PHP extension to check if it exists: " user_input

# Check if the extension is installed
if php -m | grep -q "$user_input"; then
    echo "The PHP extension '$user_input' is installed."
    exit 0
else
    echo "The PHP extension '$user_input' is NOT installed."
    exit 1
fi
