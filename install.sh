#!/bin/bash

# Colors for output
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

        # Download CLI script directly from the repository
        CLI_URL="https://raw.githubusercontent.com/Araise25/araise/main/cli.sh"
        if command -v curl &> /dev/null; then
            curl -fsSL "$CLI_URL" > "$INSTALL_DIR/araise"
        elif command -v wget &> /dev/null; then
            wget -q -O "$INSTALL_DIR/araise" "$CLI_URL"
        else
            echo -e "${RED}Error: Neither curl nor wget is installed${NC}"
            exit 1
        fi

        # Make CLI executable
        chmod +x "$INSTALL_DIR/araise"

        # Add to PATH if not already added
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
        CLI_URL="https://raw.githubusercontent.com/Araise25/araise/main/cli.ps1"
        powershell -Command "
            New-Item -ItemType Directory -Force -Path '$INSTALL_DIR'
            Invoke-WebRequest -Uri '$CLI_URL' -OutFile '$INSTALL_DIR/araise.ps1'
        "

        # Add to PATH for PowerShell
        powershell -Command "
            `$userPath = [Environment]::GetEnvironmentVariable('Path', 'User')
            if (`$userPath -notlike '*$INSTALL_DIR*') {
                [Environment]::SetEnvironmentVariable(
                    'Path',
                    `$userPath + ';$INSTALL_DIR',
                    'User'
                )
            }

            # Create PowerShell profile if it doesn't exist
            if (!(Test-Path `$PROFILE)) {
                New-Item -Path `$PROFILE -Type File -Force
            }

            # Add alias to PowerShell profile
            `$aliasLine = \"Set-Alias -Name araise -Value '$INSTALL_DIR/araise.ps1'\"
            if (!(Select-String -Path `$PROFILE -Pattern 'araise' -Quiet)) {
                Add-Content -Path `$PROFILE -Value `$aliasLine
            }
        "
        ;;
esac

echo -e "${GREEN}Araise has been installed successfully!${NC}"
echo "Run 'araise help' to get started"
