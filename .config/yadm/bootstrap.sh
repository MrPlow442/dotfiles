#!/usr/bin/env bash

# YADM Bootstrap Script for macOS Setup
# This script automatically configures a new macOS system based on your dotfiles

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Print colored output
print_status() {
    echo -e "${BLUE}==>${NC} $1"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

# Check if running on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    print_error "This script is designed for macOS only"
    exit 1
fi

print_status "Starting macOS bootstrap with YADM..."

# Install Oh My Zsh
print_status "Installing Oh My Zsh..."
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    print_success "Oh My Zsh installed"
else
    print_success "Oh My Zsh already installed"
fi

# Install Homebrew if not present
print_status "Installing Homebrew..."
if ! command -v brew &> /dev/null; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Add Homebrew to PATH for Apple Silicon Macs
    if [[ $(uname -m) == "arm64" ]]; then
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
        eval "$(/opt/homebrew/bin/brew shellenv)"
    else
        echo 'eval "$(/usr/local/bin/brew shellenv)"' >> ~/.zprofile
        eval "$(/usr/local/bin/brew shellenv)"
    fi
    print_success "Homebrew installed successfully"
else
    print_success "Homebrew already installed"
    brew update
fi

# Install packages from Brewfile if it exists
if [[ -f "$HOME/.Brewfile" ]]; then
    print_status "Installing packages from Brewfile..."
    brew bundle --global
    print_success "Packages installed from Brewfile"
fi

# Install Zinit
print_status "Installing Zinit..."
if [[ ! -d "$HOME/.local/share/zinit" ]]; then
    bash -c "$(curl --fail --show-error --silent --location https://raw.githubusercontent.com/zdharma-continuum/zinit/HEAD/scripts/install.sh)"
    print_success "Zinit installed"
else
    print_success "Zinit already installed"
fi

# Set up mise if not already configured
print_status "Configuring mise..."
if command -v mise &> /dev/null && ! grep -q 'eval "$(mise activate zsh)"' ~/.zshrc; then
    echo 'eval "$(mise activate zsh)"' >> ~/.zshrc
    print_success "mise activation added to .zshrc"
fi

# Configure Docker with Colima
# print_status "Setting up Docker with Colima..."
# if command -v colima &> /dev/null; then
#     # Create docker config directory
#     mkdir -p ~/.docker

#     # Start colima if not running
#     if ! colima status &> /dev/null; then
#         colima start
#         print_success "Colima started"
#     else
#         print_success "Colima already running"
#     fi
# fi

# Set macOS defaults
# print_status "Setting macOS defaults..."

# Show hidden files in Finder
# defaults write com.apple.finder AppleShowAllFiles -bool true

# Show file extensions
# defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# print_success "macOS defaults configured"

print_success "macOS bootstrap completed successfully!"
print_status "Please restart your terminal to see all changes"

# Print manual steps reminder
print_warning "Manual steps that may be required:"
echo "  1. Configure your Git credentials if not done:"
echo "     git config --global user.email 'mlovrekov@gmail.com'"  
echo "     git config --global user.name 'mlovrekovic'"
echo "  2. Sign into applications (VS Code, etc.)"
echo "  3. Configure SSH keys for GitHub"
echo "  4. Install Rosetta 2 if needed: softwareupdate --install-rosetta"
echo "  5. Configure Oh My Posh theme in ~/.zshrc"
echo "  6. Set up development environments with mise"
