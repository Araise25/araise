#!/bin/bash

echo "Installing Araise Package Manager..."
echo "Repository: https://github.com/Araise25/araise"
echo "Current UTC: 2025-03-17 19:14:25"
echo "User: RushiChaganti"

# Create directory for araise
mkdir -p ~/.araise/bin

# Download the araise script
curl -o ~/.araise/bin/araise https://raw.githubusercontent.com/Araise25/araise/main/src/cli/araise.py

# Make it executable
chmod +x ~/.araise/bin/araise

# Add to PATH if not already added
if ! grep -q "export PATH=\$PATH:~/.araise/bin" ~/.bashrc; then
    echo 'export PATH=$PATH:~/.araise/bin' >> ~/.bashrc
fi

# Create initial configuration
mkdir -p ~/.araise
cat > ~/.araise/config.json << EOL
{
  "system": {
    "installed_at": "2025-03-17 19:14:25",
    "user": "RushiChaganti",
    "repository": "Araise25/araise"
  },
  "installed": {}
}
EOL

echo "✅ Araise has been installed!"
echo "Please restart your terminal or run 'source ~/.bashrc'"