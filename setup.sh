#!/bin/bash

echo "Select your operating system:"
echo "1) Linux/Ubuntu"
echo "2) Windows"
echo "3) macOS"
read -p "Enter the number corresponding to your OS: " os_choice

case $os_choice in
    1)
        echo "Setting up for Linux/Ubuntu..."
        ./setup_linux.sh
        ;;
    2)
        echo "Setting up for Windows..."
        powershell -File setup_windows.ps1
        ;;
    3)
        echo "Setting up for macOS..."
        ./setup_macos.sh
        ;;
    *)
        echo "Invalid choice. Exiting..."
        exit 1
        ;;
esac