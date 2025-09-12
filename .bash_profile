# Ensure Homebrew (Apple Silicon / Intel) is first in PATH
[ -d /opt/homebrew/bin ] && PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"
[ -d /usr/local/bin   ] && PATH="/usr/local/bin:/usr/local/sbin:$PATH"

# Load interactive settings
[ -r "$HOME/.bashrc" ] && source "$HOME/.bashrc"
