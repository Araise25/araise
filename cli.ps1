param(
    [Parameter(Position=0)]
    [string]$Command,

    [Parameter(Position=1)]
    [string]$Package
)

$ErrorActionPreference = "Stop"

function Install-Package {
    param([string]$PackageName)

    Write-Host "Installing package: $PackageName"

    try {
        # Get package info from GitHub API
        $response = Invoke-RestMethod -Uri "https://api.github.com/repos/Araise25/$PackageName"
        $repoUrl = $response.clone_url

        if ($repoUrl) {
            git clone $repoUrl
            Write-Host "Package $PackageName installed successfully!" -ForegroundColor Green
        } else {
            Write-Host "Package not found!" -ForegroundColor Red
        }
    } catch {
        Write-Host "Error installing package: $_" -ForegroundColor Red
    }
}

function Get-PackageList {
    try {
        $packages = Invoke-RestMethod -Uri "https://araise25.github.io/araise/packages.json"
        Write-Host "Available packages:"
        $packages.packages | ForEach-Object {
            Write-Host "  $($_.name) - $($_.description) (v$($_.version))"
        }
    } catch {
        Write-Host "Error fetching package list: $_" -ForegroundColor Red
    }
}

function Show-Help {
    Write-Host "Araise Package Manager"
    Write-Host "Usage:"
    Write-Host "  araise install <package>  - Install a package"
    Write-Host "  araise list               - List available packages"
    Write-Host "  araise help               - Show this help message"
}

switch ($Command) {
    "install" { Install-Package $Package }
    "list" { Get-PackageList }
    "help" { Show-Help }
    default {
        Write-Host "Unknown command. Use 'araise help' for usage information." -ForegroundColor Yellow
    }
}
