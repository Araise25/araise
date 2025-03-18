# Araise Package Manager 🚀

A lightweight, cross-platform package manager that simplifies repository management and installation.

![Last Updated](https://img.shields.io/badge/last%20updated-2025--03--18-blue)
![Version](https://img.shields.io/badge/version-1.0.0-brightgreen)
![Platform](https://img.shields.io/badge/platform-Windows%20%7C%20macOS%20%7C%20Linux-lightgrey)
![License](https://img.shields.io/badge/license-MIT-green)

## 🌟 Features

- 📦 Simple package installation with one command
- 🔄 Cross-platform support (Windows, macOS, Linux)
- 💻 Multiple shell support (Bash, Zsh, PowerShell)
- 🛠 Easy package management through GitHub repositories
- 🎨 Clean and intuitive web interface
- 🔒 Secure installation process

## 🚀 Quick Install

### Unix-like Systems (macOS/Linux)

```bash
# Using curl
curl -fsSL https://araise25.github.io/araise/install.sh | bash

# Using wget
wget -qO- https://araise25.github.io/araise/install.sh | bash
```

### Windows

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://araise25.github.io/araise/install.ps1'))
```

## 📚 Usage

After installation, you can use the following commands:

```bash
# Install a package
araise install <package-name>

# List available packages
araise list

# Get help
araise help
```

## 🛠️ Adding New Packages

To add a new package to Araise:

1. Create a new GitHub repository with your package
2. Add a `manifest.json` file:

```json
{
  "name": "your-package",
  "description": "Your package description",
  "version": "1.0.0",
  "author": "Your Name",
  "repository": "https://github.com/yourusername/your-package",
  "installCommand": "git clone https://github.com/yourusername/your-package.git"
}
```

3. Submit a pull request to add your package to our `packages.json`

## 🔧 System Requirements

- **Windows**: PowerShell 5.1 or later
- **macOS/Linux**: Bash 3.2+ or Zsh
- **Git**: Required for package installation
- **curl** or **wget**: Required for installation

## 📂 Project Structure

```
araise/
├── index.html           # Landing page
├── install.html         # Installation page
├── install.sh          # Unix installation script
├── cli.sh             # Unix CLI implementation
├── cli.ps1            # PowerShell CLI implementation
├── main.js            # Web interface functionality
├── style.css          # Web interface styling
└── packages.json      # Package registry
```

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch: `git checkout -b feature/amazing-feature`
3. Commit your changes: `git commit -m 'Add amazing feature'`
4. Push to the branch: `git push origin feature/amazing-feature`
5. Open a Pull Request

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👤 Author

**RushiChaganti**

- GitHub: [@Araise25](https://github.com/Araise25)
- Created: March 18, 2025

## 🙏 Acknowledgments

- Inspired by package managers like winget
- Built with simplicity and ease of use in mind
- Powered by GitHub Pages and GitHub API

## 📄 Changelog

### 1.0.0 (2025-03-18)
- Initial release
- Cross-platform support
- Basic package management features
- Web interface implementation

## 🆘 Support

If you encounter any issues or have questions:
1. Check the [Issues](https://github.com/Araise25/araise/issues) page
2. Create a new issue if your problem isn't already listed
3. Provide detailed information about your environment and the problem

---
Made with ❤️ by RushiChaganti
