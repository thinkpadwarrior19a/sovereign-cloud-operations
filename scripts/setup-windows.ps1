#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Sets up a Windows 11 machine for Sovereign Cloud Operations development.

.DESCRIPTION
    Installs Git, VS Code, WSL2 with Ubuntu (for bash build scripts),
    and the full build toolchain inside WSL2 (pandoc, texlive, python).

    The repo lives on the Windows filesystem so both Windows (PowerPoint,
    SharePoint, M365) and WSL2 (bash builds) can access it.

.USAGE
    1. Open PowerShell as Administrator
    2. Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
    3. .\setup-windows.ps1

.NOTES
    Author: Alan Hamilton
    Date:   March 2026
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# ── Colour helpers ──────────────────────────────────────────────────────────
function Write-Step  { param([string]$msg) Write-Host "`n>> $msg" -ForegroundColor Cyan }
function Write-Ok    { param([string]$msg) Write-Host "   OK: $msg" -ForegroundColor Green }
function Write-Skip  { param([string]$msg) Write-Host "   SKIP: $msg" -ForegroundColor Yellow }
function Write-Info  { param([string]$msg) Write-Host "   $msg" -ForegroundColor Gray }

# ── 1. Install winget packages ─────────────────────────────────────────────
Write-Step "Installing Windows packages via winget"

$wingetPackages = @(
    @{ Id = "Git.Git";                    Name = "Git for Windows" },
    @{ Id = "Microsoft.VisualStudioCode"; Name = "VS Code" },
    @{ Id = "Microsoft.WindowsTerminal";  Name = "Windows Terminal" }
)

foreach ($pkg in $wingetPackages) {
    $installed = winget list --id $pkg.Id --accept-source-agreements 2>&1
    if ($installed -match $pkg.Id) {
        Write-Skip "$($pkg.Name) already installed"
    } else {
        Write-Info "Installing $($pkg.Name)..."
        winget install --id $pkg.Id --accept-package-agreements --accept-source-agreements --silent
        Write-Ok "$($pkg.Name) installed"
    }
}

# ── 2. Configure Git defaults ──────────────────────────────────────────────
Write-Step "Configuring Git defaults"

# Line endings: the .gitattributes does the heavy lifting, but set a safety net
git config --global core.autocrlf input
git config --global core.eol lf
# Default branch
git config --global init.defaultBranch main
# Credential helper for GitHub HTTPS
git config --global credential.helper manager
Write-Ok "Git configured (autocrlf=input, credential-manager)"

# ── 3. Install / enable WSL2 ───────────────────────────────────────────────
Write-Step "Setting up WSL2 with Ubuntu"

$wslStatus = wsl --status 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Info "Enabling WSL2 (may require a reboot)..."
    wsl --install --distribution Ubuntu --no-launch
    Write-Ok "WSL2 installed — if prompted, reboot and re-run this script"
    Write-Host "`n** REBOOT REQUIRED — re-run this script after restarting **" -ForegroundColor Red
    exit 0
} else {
    Write-Skip "WSL2 already enabled"
}

# Check if Ubuntu distro is registered
$distros = wsl --list --quiet 2>&1
if ($distros -notmatch "Ubuntu") {
    Write-Info "Installing Ubuntu distro..."
    wsl --install --distribution Ubuntu --no-launch
    Write-Ok "Ubuntu installed in WSL2 — launch it once to set up your user, then re-run this script"
    exit 0
} else {
    Write-Skip "Ubuntu already registered in WSL2"
}

# ── 4. Install build toolchain inside WSL2 ─────────────────────────────────
Write-Step "Installing build toolchain inside WSL2 (Ubuntu)"

# This is the equivalent of the Fedora packages listed in the project docs,
# mapped to Ubuntu/Debian package names matching what the GitHub Actions CI uses.
$wslSetupScript = @'
set -eu

echo ">> Updating package lists..."
sudo apt-get update -qq

echo ">> Installing pandoc, texlive, latexmk, python3, and fonts..."
sudo apt-get install -y -qq \
    pandoc \
    texlive-xetex \
    texlive-fonts-recommended \
    texlive-fonts-extra \
    texlive-latex-recommended \
    texlive-latex-extra \
    latexmk \
    lmodern \
    fonts-dejavu \
    python3 \
    python3-pip \
    make

echo ""
echo ">> Verifying installations..."
echo "   pandoc   : $(pandoc --version | head -1)"
echo "   xelatex  : $(xelatex --version | head -1)"
echo "   latexmk  : $(latexmk --version | head -1)"
echo "   python3  : $(python3 --version)"
echo ""
echo ">> WSL2 build toolchain ready."
'@

wsl --distribution Ubuntu -- bash -c $wslSetupScript
Write-Ok "WSL2 build toolchain installed"

# ── 5. Clone the repo (if not already present) ─────────────────────────────
Write-Step "Repository setup"

$repoUrl  = "https://github.com/alan-hamilton/sovereign-cloud-operations.git"
$repoName = "sovereign-cloud-operations"
$defaultCloneDir = Join-Path $env:USERPROFILE "source\repos"

if (-not (Test-Path $defaultCloneDir)) {
    New-Item -ItemType Directory -Path $defaultCloneDir -Force | Out-Null
}

$repoPath = Join-Path $defaultCloneDir $repoName

if (Test-Path (Join-Path $repoPath ".git")) {
    Write-Skip "Repo already cloned at $repoPath"
} else {
    Write-Info "Cloning repo to $repoPath..."
    git clone $repoUrl $repoPath
    Write-Ok "Repo cloned"
}

Write-Info "Repo path: $repoPath"

# ── 6. VS Code extensions ──────────────────────────────────────────────────
Write-Step "Installing recommended VS Code extensions"

$vsCodeExtensions = @(
    "ms-vscode-remote.remote-wsl",
    "yzhang.markdown-all-in-one",
    "James-Yu.latex-workshop",
    "ms-python.python",
    "GitHub.vscode-pull-request-github",
    "streetsidesoftware.code-spell-checker"
)

foreach ($ext in $vsCodeExtensions) {
    $out = code --list-extensions 2>&1
    if ($out -match $ext) {
        Write-Skip "$ext"
    } else {
        code --install-extension $ext --force 2>&1 | Out-Null
        Write-Ok "$ext"
    }
}

# ── 7. Print summary ───────────────────────────────────────────────────────
Write-Host "`n" -NoNewline
Write-Host "============================================================" -ForegroundColor Green
Write-Host "  Setup complete!" -ForegroundColor Green
Write-Host "============================================================" -ForegroundColor Green
Write-Host ""
Write-Host "  Repo location : $repoPath" -ForegroundColor White
Write-Host ""
Write-Host "  Quick start:" -ForegroundColor White
Write-Host "    cd '$repoPath'" -ForegroundColor Gray
Write-Host "    code ." -ForegroundColor Gray
Write-Host ""
Write-Host "  Build PDF (from WSL2 terminal or VS Code WSL):" -ForegroundColor White
Write-Host "    bash scripts/build-pdf.sh" -ForegroundColor Gray
Write-Host ""
Write-Host "  Build ePub:" -ForegroundColor White
Write-Host "    bash scripts/build-epub.sh" -ForegroundColor Gray
Write-Host ""
Write-Host "  Build artefacts (executive abridged, sales play, pptx):" -ForegroundColor White
Write-Host "    bash artefacts/build-artefacts.sh" -ForegroundColor Gray
Write-Host ""
Write-Host "  Build HTML site:" -ForegroundColor White
Write-Host "    bash scripts/build-html.sh" -ForegroundColor Gray
Write-Host ""
Write-Host "  Edit PowerPoint natively:" -ForegroundColor White
Write-Host "    Open .build\artefacts\internal-presentation.pptx in PowerPoint" -ForegroundColor Gray
Write-Host ""
Write-Host "  SharePoint / M365:" -ForegroundColor White
Write-Host "    Upload finished artefacts via Explorer or browser as usual" -ForegroundColor Gray
Write-Host ""
Write-Host "  WSL2 can access this repo at:" -ForegroundColor White
$wslPath = "/mnt/" + ($repoPath.Substring(0,1).ToLower()) + ($repoPath.Substring(2) -replace '\\','/')
Write-Host "    $wslPath" -ForegroundColor Gray
Write-Host ""
