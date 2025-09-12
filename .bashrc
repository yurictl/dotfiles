# ----- guard: only for interactive shells -----
[[ $- != *i* ]] && return

# ----- locale & basics -----
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
umask 022

# ----- PATH commons -----
for d in "$HOME/.local/bin" "$HOME/bin"; do
  [ -d "$d" ] && case ":$PATH:" in *":$d:"*) ;; *) PATH="$d:$PATH";; esac
done
export PATH

# ----- shell options (safe, useful) -----
set -o noclobber          # forbid ">" from clobbering files (use >| to override)
shopt -s histappend       # append history instead of overwrite
shopt -s cmdhist          # multi-line cmd as one history entry
shopt -s checkwinsize     # fix LINES/COLUMNS after each command
shopt -s no_empty_cmd_completion

# Bash 4+ niceties, guarded for macOS /bin/bash (3.2)
if [ "${BASH_VERSINFO[0]:-3}" -ge 4 ]; then
  shopt -s autocd dirspell direxpand
  shopt -s globstar       # ** recursive globs
fi

# ----- history settings (large, dedup, timestamp) -----
export HISTFILE="$HOME/.bash_history"
export HISTSIZE=100000
export HISTFILESIZE=200000
export HISTCONTROL=ignoredups:erasedups     # drop dups on save
export HISTIGNORE="ls:ll:la:cd:pwd:clear:history"
export HISTTIMEFORMAT="%F %T  "

# Write/read history continuously across sessions
__hist_sync() {
  history -a    # append new lines
  history -c    # clear in-mem
  history -r    # reload from file
}
# chain with existing PROMPT_COMMAND if set
PROMPT_COMMAND="__hist_sync${PROMPT_COMMAND:+;$PROMPT_COMMAND}"

# ----- colors for BSD ls/grep on macOS -----
export CLICOLOR=1
export LSCOLORS=ExFxBxDxCxegedabagacad

# Prefer GNU coreutils if installed (gls), else BSD defaults
if command -v gls >/dev/null 2>&1; then
  alias ls='gls --group-directories-first -F -h --color=auto'
else
  alias ls='ls -GFh'
fi
# grep: BSD grep lacks reliable --color; prefer ggrep if present
if command -v ggrep >/dev/null 2>&1; then
  alias grep='ggrep --color=auto'
else
  alias grep='grep'
fi

# ----- prompt with Git status (fast, readable) -----
# Try to load git-prompt if present (Homebrew paths + system)
for gp in \
  /opt/homebrew/etc/bash_completion.d/git-prompt.sh \
  /usr/local/etc/bash_completion.d/git-prompt.sh \
  /etc/bash_completion.d/git-prompt; do
  [ -r "$gp" ] && source "$gp" && break
done

# Colors (portable via tput)
if tput setaf 1 >/dev/null 2>&1; then
  c_reset="$(tput sgr0)"
  c_dim="$(tput dim)"; c_bold="$(tput bold)"
  c_red="$(tput setaf 1)"; c_grn="$(tput setaf 2)"
  c_yel="$(tput setaf 3)"; c_blu="$(tput setaf 4)"
else
  c_reset=""; c_dim=""; c_bold=""; c_red=""; c_grn=""; c_yel=""; c_blu=""
fi

# Exit status marker
__ret_mark() { [ "$1" -eq 0 ] && printf "" || printf "%s✗%s " "$c_red" "$c_reset"; }

# PS1: [time] cwd (git) $
__git_ps1_fmt=" (%s)"
if type __git_ps1 >/dev/null 2>&1; then
  PS1='\[$c_dim\][\t]\[$c_reset\] \[$c_blu\]\w\[$c_reset\]$(__git_ps1 "'"$__git_ps1_fmt"'") \[$c_yel\]$(__ret_mark $?)\[$c_reset\]\n\$ '
else
  PS1='\[$c_dim\][\t]\[$c_reset\] \[$c_blu\]\w\[$c_reset\] \[$c_yel\]$(__ret_mark $?)\[$c_reset\]\n\$ '
fi

# Title for Terminal tab
case "$TERM" in
  xterm*|screen*|tmux*) PROMPT_COMMAND="echo -ne \"\033]0;\w\007\";${PROMPT_COMMAND}" ;;
esac

# ----- completions (if installed) -----
# Bash completion core
for bc in \
  /opt/homebrew/etc/profile.d/bash_completion.sh \
  /usr/local/etc/bash_completion \
  /etc/bash_completion; do
  [ -r "$bc" ] && source "$bc" && break
done

# Tool-specific completions (silent if missing)
command -v kubectl >/dev/null 2>&1 && source <(kubectl completion bash)
command -v helm    >/dev/null 2>&1 && source <(helm completion bash)
command -v aws     >/dev/null 2>&1 && complete -C "$(command -v aws_completer)" aws
command -v terraform >/dev/null 2>&1 && complete -C "$(command -v terraform)" terraform
command -v gh >/dev/null 2>&1 && eval "$(gh completion -s bash)"

# fzf integration (if installed)
[ -f "$HOME/.fzf.bash" ] && source "$HOME/.fzf.bash"

# direnv (if installed)
command -v direnv >/dev/null 2>&1 && eval "$(direnv hook bash)"

# ----- quality-of-life readline tweaks -----
bind '"\t":complete'
bind "set show-all-if-ambiguous off"
bind "set page-completions off"

# ----- raise file descriptor limit (if allowed) -----
ulimit -n 4096 2>/dev/null || true

# ----- per-host/per-project overrides -----
[ -d "$HOME/.bashrc.d" ] && for f in "$HOME/.bashrc.d/"*.bash; do [ -r "$f" ] && source "$f"; done
