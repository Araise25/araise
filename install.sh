#!/bin/bash

# Colors for output (ANSI colors work in all modern terminals)
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

# Detect OS
case "$(uname -s)" in
    Linux*|Darwin*)
        # Unix-like systems (Linux/macOS)
        INSTALL_DIR="$HOME/.araise/bin"

        # Detect shell
        if [ -n "$ZSH_VERSION" ]; then
            SHELL_RC="$HOME/.zshrc"
            SHELL_NAME="zsh"
        elif [ -n "$BASH_VERSION" ]; then
            SHELL_RC="$HOME/.bashrc"
            SHELL_NAME="bash"
        else
            SHELL_RC="$HOME/.profile"
            SHELL_NAME="shell"
        fi

        echo "Installing Araise Package Manager for $SHELL_NAME..."

        # Create directory
        mkdir -p "$INSTALL_DIR"

        # Download Unix CLI script
        curl -o "$INSTALL_DIR/araise" https://araise25.github.io/araise/cli.sh
        chmod +x "$INSTALL_DIR/araise"

        # Add to PATH for Unix shells
        if ! grep -q "export PATH=\$PATH:$INSTALL_DIR" "$SHELL_RC"; then
            echo "export PATH=\$PATH:$INSTALL_DIR" >> "$SHELL_RC"
            echo "Please restart your terminal or run: source $SHELL_RC"
        fi
        ;;

    MINGW*|MSYS*|CYGWIN*|Windows*)
        # Windows systems
        INSTALL_DIR="$HOME/AppData/Local/Araise"

        echo "Installing Araise Package Manager for PowerShell..."

        # Create directory
        mkdir -p "$INSTALL_DIR"

        # Download PowerShell CLI script
        curl -o "$INSTALL_DIR/araise.ps1" https://araise25.github.io/araise/cli.ps1

        # Add to PATH for PowerShell
        userPath=$(echo $PATH)
        echo "User Path: $userPath"
        powershell -command "
        if ($userPath -notlike '*$INSTALL_DIR*') {
            [Environment]::SetEnvironmentVariable(
                'Path',
                '$userPath;$INSTALL_DIR',
                'User'
            )
        }"

        # Create PowerShell profile if it doesn't exist
        powershell -command "
        if (!(Test-Path $PROFILE)) {
            New-Item -Path $PROFILE -Type File -Force
        }"

        # Add alias to PowerShell profile
        aliasLine="Set-Alias -Name araise -Value '$INSTALL_DIR/araise.ps1'"
        powershell -command "
        if (!(Select-String -Path $PROFILE -Pattern 'araise' -Quiet)) {
            Add-Content -Path $PROFILE -Value $aliasLine
        }"
        ;;
esac

echo -e "${GREEN}Araise has been installed successfully!${NC}"
echo "Run 'araise help' to get started"
