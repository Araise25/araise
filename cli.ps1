# Araise Package Manager PowerShell CLI

# Base directory for araise
$ARAISE_DIR = "$env:USERPROFILE\.araise"
$REGISTRY_FILE = "$ARAISE_DIR\registry.json"

# Ensure registry directory exists
function Ensure-Registry {
    if (!(Test-Path $ARAISE_DIR)) {
        New-Item -ItemType Directory -Force -Path $ARAISE_DIR | Out-Null
    }
    if (!(Test-Path $REGISTRY_FILE)) {
        Set-Content -Path $REGISTRY_FILE -Value '{"packages":{}}'
    }
}

# Install a package
function Install-AraisePackage {
    param (
        [string]$package,
        [string]$owner = "Araise25"
    )

    Write-Host "Installing package: $owner/$package" -ForegroundColor Yellow

    # Get package info from GitHub API
    $apiUrl = "https://api.github.com/repos/$owner/$package"
    try {
        $apiResponse = Invoke-RestMethod -Uri $apiUrl
        $repoUrl = $apiResponse.clone_url

        # Create installation directory
        $installPath = "$ARAISE_DIR\packages\$package"
        New-Item -ItemType Directory -Force -Path $installPath | Out-Null

        # Clone repository
        Write-Host "Cloning from: $repoUrl" -ForegroundColor Blue
        git clone $repoUrl $installPath

        if ($LASTEXITCODE -eq 0) {
            Write-Host "Package $package cloned successfully!" -ForegroundColor Green

            # Check for package.json
            if (Test-Path "$installPath\package.json") {
                Write-Host "Found package.json, reading metadata..."
                $metadata = Get-Content "$installPath\package.json" -Raw
            }
            else {
                Write-Host "No package.json found, registering with basic information..."
                $metadata = @{
                    name = $package
                    version = "1.0.0"
                    installed_at = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
                } | ConvertTo-Json
            }

            # Register package
            Register-Package -package $package -owner $owner -path $installPath -metadata $metadata

            # Check for post-install script
            if (Test-Path "$installPath\install.ps1") {
                Write-Host "Running post-install script..." -ForegroundColor Blue
                Push-Location $installPath
                & "$installPath\install.ps1"
                Pop-Location
            }

            Write-Host "Package $owner/$package installed successfully!" -ForegroundColor Green
        }
        else {
            Write-Host "Failed to clone repository" -ForegroundColor Red
            Remove-Item -Path $installPath -Recurse -Force
            exit 1
        }
    }
    catch {
        Write-Host "Failed to fetch repository information: $_" -ForegroundColor Red
        exit 1
    }
}

# Register a package in the local registry
function Register-Package {
    param (
        [string]$package,
        [string]$owner,
        [string]$path,
        [string]$metadata
    )

    Ensure-Registry

    $registry = Get-Content $REGISTRY_FILE | ConvertFrom-Json
    $registry.packages | Add-Member -NotePropertyName $package -NotePropertyValue @{
        owner = $owner
        path = $path
        installed_at = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
        metadata = $metadata | ConvertFrom-Json
    } -Force

    $registry | ConvertTo-Json -Depth 10 | Set-Content $REGISTRY_FILE
    Write-Host "Package registered in local registry"
}

# List installed packages
function List-Packages {
    Ensure-Registry

    Write-Host "Installed packages:" -ForegroundColor Blue
    $registry = Get-Content $REGISTRY_FILE | ConvertFrom-Json

    if ($registry.packages.PSObject.Properties.Count -eq 0) {
        Write-Host "  No packages installed"
    }
    else {
        foreach ($package in $registry.packages.PSObject.Properties) {
            Write-Host "`n  $($package.Name) ($($package.Value.owner)):"
            Write-Host "    Path: $($package.Value.path)"
            Write-Host "    Installed: $($package.Value.installed_at)"
            Write-Host "    Version: $($package.Value.metadata.version)"
        }
    }
}

# Uninstall a package
function Uninstall-AraisePackage {
    param ([string]$package)

    Ensure-Registry
    $registry = Get-Content $REGISTRY_FILE | ConvertFrom-Json

    if ($registry.packages.PSObject.Properties[$package]) {
        $packageInfo = $registry.packages.PSObject.Properties[$package]
        Write-Host "Uninstalling package: $package" -ForegroundColor Yellow

        # Remove package files
        Remove-Item -Path $packageInfo.Value.path -Recurse -Force

        # Remove from registry
        $registry.packages.PSObject.Properties.Remove($package)
        $registry | ConvertTo-Json -Depth 10 | Set-Content $REGISTRY_FILE

        Write-Host "Package $package uninstalled successfully" -ForegroundColor Green
    }
    else {
        Write-Host "Package $package not found in registry" -ForegroundColor Red
        exit 1
    }
}

# Show help
function Show-Help {
    Write-Host "Araise Package Manager" -ForegroundColor Blue
    Write-Host "Usage:"
    Write-Host "  araise install <package>                  - Install a package from Araise25 organization"
    Write-Host "  araise install <owner>/<package>          - Install a package from specific GitHub repository"
    Write-Host "  araise uninstall <package>               - Uninstall a package"
    Write-Host "  araise list                              - List installed packages"
    Write-Host "  araise help                              - Show this help message"
}

# Main logic
$command = $args[0]
switch ($command) {
    "install" {
        if ($args.Length -lt 2) {
            Write-Host "Error: Package name required" -ForegroundColor Red
            Write-Host "Usage: araise install <package> or araise install <owner>/<package>"
            exit 1
        }
        $packageArg = $args[1]
        if ($packageArg -match "/") {
            $owner, $package = $packageArg.Split("/")
            Install-AraisePackage -package $package -owner $owner
        }
        else {
            Install-AraisePackage -package $packageArg
        }
    }
    "uninstall" {
        if ($args.Length -lt 2) {
            Write-Host "Error: Package name required" -ForegroundColor Red
            Write-Host "Usage: araise uninstall <package>"
            exit 1
        }
        Uninstall-AraisePackage -package $args[1]
    }
    "list" {
        List-Packages
    }
    "help" {
        Show-Help
    }
    default {
        Write-Host "Unknown command. Use 'araise help' for usage information." -ForegroundColor Yellow
        exit 1
    }
}
