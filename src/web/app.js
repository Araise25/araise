// Fetch and display available applications
async function loadApps() {
    const apps = await fetch('https://api.github.com/users/RushiChaganti/repos')
        .then(response => response.json())
        .then(repos => repos.filter(repo => repo.topics?.includes('araise-app')));

    const appsContainer = document.getElementById('apps');
    
    apps.forEach(app => {
        const appCard = document.createElement('div');
        appCard.className = 'app-card';
        appCard.innerHTML = `
            <h3>${app.name}</h3>
            <p>${app.description || 'No description available'}</p>
            <div class="install-command">araise install ${app.name}</div>
            <button class="install-btn" onclick="copyCommand('araise install ${app.name}')">
                Copy Install Command
            </button>
        `;
        appsContainer.appendChild(appCard);
    });
}

function copyCommand(command) {
    navigator.clipboard.writeText(command);
    alert('Install command copied to clipboard!');
}

loadApps();