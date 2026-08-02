# Zsh Configuration

Minimal, XDG-compliant Zsh configuration using native Zsh features and Zinit.

## Installation

```bash
sudo dnf install -y zsh git fzf zoxide neovim
chsh -s "$(which zsh)"

git clone https://github.com/amyrhexa/dotfiles.git /tmp/dotfiles
mkdir -p ~/.config
mv /tmp/dotfiles/zsh ~/.config/zsh
rm -rf /tmp/dotfiles

ln -sf ~/.config/zsh/.zshenv ~/.zshenv
