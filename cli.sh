#!/usr/bin/env bash

# Enable error handling
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Function to make HTTP requests (works in both Bash and Zsh)
http_get() {
    if command -v curl &> /dev/null; then
        curl -s "$1"
    elif command -v wget &> /dev/null; then
        wget -qO- "$1"
    else
        echo "Error: Neither curl nor wget is installed"
        exit 1
    fi
}

# Function to install a package
install_package() {
    local package=$1
    echo -e "${YELLOW}Installing package: $package${NC}"

    # Get package info from GitHub API
    local api_response=$(http_get "https://api.github.com/repos/Araise25/$package")
    local repo_url=$(echo "$api_response" | grep -o '"clone_url": "[^"]*' | cut -d'"' -f4)

    if [ ! -z "$repo_url" ]; then
        if git clone "$repo_url"; then
            echo -e "${GREEN}Package $package installed successfully!${NC}"

            # Check for post-install script
            if [ -f "$package/install.sh" ]; then
                echo "Running post-install script..."
                (cd "$package" && bash install.sh)
            fi
        else
            echo -e "${RED}Failed to clone repository${NC}"
            exit 1
        fi
    else
        echo -e "${RED}Package not found!${NC}"
        exit 1
    fi
}

# Function to list packages
list_packages() {
    echo "Available packages:"
    http_get "https://araise25.github.io/araise/packages.json" | \
        python3 -c "
import sys, json
try:
    packages = json.load(sys.stdin)['packages']
    for pkg in packages:
        print(f\"  {pkg['name']} - {pkg['description']} (v{pkg['version']})\")
except Exception as e:
    print('Error parsing package list:', e)
        "
}

# Function to show help
show_help() {
    echo "Araise Package Manager"
    echo "Usage:"
    echo "  araise install <package>  - Install a package"
    echo "  araise list               - List available packages"
    echo "  araise help               - Show this help message"
}

# Main command handler
case "$1" in
    "install")
        if [ -z "$2" ]; then
            echo -e "${RED}Error: Package name required${NC}"
            echo "Usage: araise install <package>"
            exit 1
        fi
        install_package "$2"
        ;;
    "list")
        list_packages
        ;;
    "help")
        show_help
        ;;
    *)
        echo -e "${YELLOW}Unknown command. Use 'araise help' for usage information.${NC}"
        exit 1
        ;;
esac
