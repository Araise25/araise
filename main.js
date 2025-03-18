// Package registry manager
class PackageManager {
    constructor() {
        this.packages = [];
        this.loadPackages();
    }

    async loadPackages() {
        try {
            const response = await fetch('packages.json');
            this.packages = await response.json();
            this.renderPackages();
        } catch (error) {
            console.error('Error loading packages:', error);
        }
    }

    renderPackages() {
        const packageList = document.getElementById('packageList');
        packageList.innerHTML = this.packages.map(pkg => `
            <div class="package-card">
                <h3>${pkg.name}</h3>
                <p>${pkg.description}</p>
                <div class="package-meta">
                    <span>Version: ${pkg.version}</span>
                    <span>Author: ${pkg.author}</span>
                </div>
                <code>araise install ${pkg.name}</code>
            </div>
        `).join('');
    }
}

// Initialize package manager
const manager = new PackageManager();

// Copy command functionality
function copyCommand() {
    const command = document.querySelector('.command-box code').textContent;
    navigator.clipboard.writeText(command).then(() => {
        const btn = document.querySelector('.copy-btn');
        btn.textContent = 'Copied!';
        setTimeout(() => {
            btn.textContent = 'Copy';
        }, 2000);
    });
}