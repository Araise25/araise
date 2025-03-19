#!/usr/bin/env bash

# Enable error handling
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Base directory for araise
ARAISE_DIR="$HOME/.araise"
REGISTRY_FILE="$ARAISE_DIR/registry.json"

# Function to make HTTP requests
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

# Function to ensure registry exists
ensure_registry() {
    mkdir -p "$(dirname "$REGISTRY_FILE")"
    if [ ! -f "$REGISTRY_FILE" ]; then
        echo '{"packages":{}}' > "$REGISTRY_FILE"
    fi
}

# Function to install a package
install_package() {
    local package=$1
    local owner=$2
    echo -e "${YELLOW}Installing package: $owner/$package${NC}"

    # If no owner specified, use the default organization
    if [ -z "$owner" ]; then
        owner="Araise25"
    fi

    # Get package info from GitHub API
    local api_url="https://api.github.com/repos/$owner/$package"
    echo -e "${BLUE}Checking repository: $api_url${NC}"

    local api_response=$(http_get "$api_url")
    if [ $? -ne 0 ]; then
        echo -e "${RED}Failed to fetch repository information${NC}"
        exit 1


    local repo_url=$(echo "$api_response" | grep -o '"clone_url": "[^"]*' | cut -d'"' -f4)

    if [ ! -z "$repo_url" ]; then
        # Create installation directory
        local install_path="$ARAISE_DIR/packages/$package"
        mkdir -p "$install_path"

        echo -e "${BLUE}Cloning from: $repo_url${NC}"
        if git clone "$repo_url" "$install_path"; then
            echo -e "${GREEN}Package $package cloned successfully!${NC}"

            # Check for package.json in the repository
            if [ -f "$install_path/package.json" ]; then
                echo "Found package.json, reading metadata..."
                local metadata=$(cat "$install_path/package.json")
                register_package "$package" "$owner" "$install_path" "$metadata"
            else
                echo "No package.json found, registering with basic information..."
                local current_time=$(date -u +"%Y-%m-%d %H:%M:%S")
                local basic_metadata="{\"name\":\"$package\",\"version\":\"1.0.0\",\"installed_at\":\"$current_time\"}"
                register_package "$package" "$owner" "$install_path" "$basic_metadata"
            fi

            # Check for post-install script
            if [ -f "$install_path/install.sh" ]; then
                echo -e "${BLUE}Running post-install script...${NC}"
                (cd "$install_path" && bash install.sh)
            fi

            echo -e "${GREEN}Package $owner/$package installed successfully!${NC}"
        else
            echo -e "${RED}Failed to clone repository${NC}"
            rm -rf "$install_path"  # Clean up failed installation
            exit 1
        fi
    else
        echo -e "${RED}Repository not found or access denied!${NC}"
        exit 1
    fi


# Function to register a package in local registry
register_package() {
    local package=$1
    local owner=$2
    local path=$3
    local metadata=$4

    ensure_registry

    # Add package to registry
    local entry="{
        \"owner\": \"$owner\",
        \"path\": \"$path\",
        \"installed_at\": \"$(date -u +"%Y-%m-%d %H:%M:%S")\",
        \"metadata\": $metadata
    }"

    if command -v jq &> /dev/null; then
        local tmp_file=$(mktemp)
        jq --arg pkg "$package" --arg entry "$entry" '.packages[$pkg] = ($entry|fromjson)' "$REGISTRY_FILE" > "$tmp_file"
        mv "$tmp_file" "$REGISTRY_FILE"
        echo "Package registered in local registry"
    else
        echo -e "${YELLOW}Warning: jq not installed. Package registration requires jq for proper operation${NC}"
        echo "Please install jq using your package manager:"
        echo "  - For Ubuntu/Debian: sudo apt-get install jq"
        echo "  - For MacOS: brew install jq"
        echo "  - For Windows: choco install jq"
    fi
}

# Function to list packages
list_packages() {
    ensure_registry

    echo -e "${BLUE}Installed packages:${NC}"
    if [ -f "$REGISTRY_FILE" ]; then
        if command -v jq &> /dev/null; then
            echo -e "\nLocal packages:"
            jq -r '
                .packages | to_entries[] |
                "  \(.key) (\(.value.owner)):\n    Path: \(.value.path)\n    Installed: \(.value.installed_at)\n    Version: \(.value.metadata.version // "unknown")\n"
            ' "$REGISTRY_FILE" || echo "  No packages installed"
        else
            echo "Please install jq to view detailed package information"
            cat "$REGISTRY_FILE"
        fi
    else
        echo "  No packages installed"
    fi
}

# Function to uninstall a package
uninstall_package() {
    local package=$1

    if [ -f "$REGISTRY_FILE" ] && command -v jq &> /dev/null; then
        local package_path=$(jq -r --arg pkg "$package" '.packages[$pkg].path // empty' "$REGISTRY_FILE")

        if [ ! -z "$package_path" ]; then
            echo -e "${YELLOW}Uninstalling package: $package${NC}"

            # Remove package files
            rm -rf "$package_path"

            # Remove from registry
            local tmp_file=$(mktemp)
            jq --arg pkg "$package" 'del(.packages[$pkg])' "$REGISTRY_FILE" > "$tmp_file"
            mv "$tmp_file" "$REGISTRY_FILE"

            echo -e "${GREEN}Package $package uninstalled successfully${NC}"
        else
            echo -e "${RED}Package $package not found in registry${NC}"
            exit 1
        fi
    else
        echo -e "${RED}Registry file not found or jq not installed${NC}"
        exit 1
    fi
}

# Function to show help
show_help() {
    echo -e "${BLUE}Araise Package Manager${NC}"
    echo "Usage:"
    echo "  araise install <package>                  - Install a package from Araise25 organization"
    echo "  araise install <owner>/<package>          - Install a package from specific GitHub repository"
    echo "  araise uninstall <package>               - Uninstall a package"
    echo "  araise list                              - List installed packages"
    echo "  araise help                              - Show this help message"
}

# Main command handler
case "$1" in
    "install")
        if [ -z "$2" ]; then
            echo -e "${RED}Error: Package name required${NC}"
            echo "Usage: araise install <package> or araise install <owner>/<package>"
            exit 1
        fi

        # Check if the package name includes owner (contains '/')
        if [[ "$2" == *"/"* ]]; then
            owner=$(echo "$2" | cut -d'/' -f1)
            package=$(echo "$2" | cut -d'/' -f2)
            install_package "$package" "$owner"
        else
            install_package "$2" "Araise25"
        fi
        ;;
    "uninstall")
        if [ -z "$2" ]; then
            echo -e "${RED}Error: Package name required${NC}"
            echo "Usage: araise uninstall <package>"
            exit 1
        fi
        uninstall_package "$2"
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
