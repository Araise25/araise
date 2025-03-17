#!/usr/bin/env python3
import sys
import os
import subprocess
import requests
import json
from datetime import datetime

# Updated configuration
GITHUB_USER = "Araise25"
REPO_NAME = "araise"
CONFIG_FILE = os.path.expanduser("~/.araise/config.json")
CURRENT_USER = "RushiChaganti"
CURRENT_UTC = "2025-03-17 19:14:25"

class AraiseManager:
    def __init__(self):
        self.setup()
        
    def setup(self):
        """Initial setup for araise"""
        os.makedirs(os.path.dirname(CONFIG_FILE), exist_ok=True)
        if not os.path.exists(CONFIG_FILE):
            self.create_initial_config()

    def create_initial_config(self):
        """Create initial configuration file"""
        config = {
            "installed": {},
            "system": {
                "last_update": CURRENT_UTC,
                "user": CURRENT_USER,
                "repository": f"{GITHUB_USER}/{REPO_NAME}"
            }
        }
        with open(CONFIG_FILE, 'w') as f:
            json.dump(config, f, indent=2)

    def execute_command(self, app_name):
        """Execute araise command for an app"""
        if app_name in ["help", "--help", "-h"]:
            self.show_help()
            return
        
        if app_name == "list":
            self.list_apps()
            return
            
        if app_name == "version":
            self.show_version()
            return
            
        self.install_app(app_name)

    def install_app(self, app_name):
        """Install/setup an application"""
        print(f"🔍 Looking for {app_name}...")
        
        # Check if app exists in repository
        api_url = f"https://api.github.com/repos/{GITHUB_USER}/{app_name}"
        response = requests.get(api_url)
        
        if response.status_code != 200:
            print(f"❌ Error: Application '{app_name}' not found")
            return

        # Get latest release
        releases_url = f"https://api.github.com/repos/{GITHUB_USER}/{app_name}/releases/latest"
        response = requests.get(releases_url)
        
        if response.status_code != 200:
            print(f"❌ Error: No releases available for '{app_name}'")
            return

        release_data = response.json()
        
        # Update installation record
        with open(CONFIG_FILE, 'r') as f:
            config = json.load(f)
        
        config['installed'][app_name] = {
            'version': release_data['tag_name'],
            'installed_at': CURRENT_UTC,
            'installed_by': CURRENT_USER
        }
        
        with open(CONFIG_FILE, 'w') as f:
            json.dump(config, f, indent=2)
        
        print(f"✅ Successfully set up {app_name}")

    def list_apps(self):
        """List installed applications"""
        with open(CONFIG_FILE, 'r') as f:
            config = json.load(f)
        
        print("\n📱 Installed Applications:")
        print(f"System Time (UTC): {CURRENT_UTC}")
        print(f"Current User: {CURRENT_USER}")
        print("-" * 50)
        
        if not config['installed']:
            print("No applications installed yet.")
            return
            
        for app, details in config['installed'].items():
            print(f"• {app}")
            print(f"  Version: {details['version']}")
            print(f"  Installed: {details['installed_at']}")
            print(f"  By: {details['installed_by']}")
            print()

    def show_version(self):
        """Show araise version information"""
        print(f"Araise Package Manager")
        print(f"Repository: https://github.com/{GITHUB_USER}/{REPO_NAME}")
        print(f"Current UTC: {CURRENT_UTC}")
        print(f"User: {CURRENT_USER}")

    def show_help(self):
        """Show help information"""
        print("Araise Package Manager - Help")
        print("\nUsage:")
        print("  araise <appname>    Install/setup an application")
        print("  araise list         Show installed applications")
        print("  araise version      Show version information")
        print("  araise help         Show this help message")

def main():
    """Main entry point"""
    manager = AraiseManager()
    
    if len(sys.argv) < 2:
        manager.show_help()
        return

    manager.execute_command(sys.argv[1])

if __name__ == "__main__":
    main()