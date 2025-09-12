# Dotfiles

Personal dotfiles managed with **GNU Stow**. Minimal, portable, reproducible.

## Requirements
- macOS/Linux
- Git, GNU Stow (`brew install stow`)

## Migration
```bash
brew bundle dump --file=~/Brewfile --force   # export everything (formulae + casks + taps)
brew bundle --file=~/Brewfile                 # install from file
```
This is more reproducible and doesn't require manual xargs.

## Quick start
First, check out the dotfiles repo in your $HOME directory using git

```bash
git clone git@github.com:yurictl/dotfiles.git ~/dotfiles
cd ~/dotfiles
```

then use GNU stow to create symlinks

```bash
stow .
```
