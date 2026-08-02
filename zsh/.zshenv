# Set ZDOTDIR immediately so all further zsh files resolve to ~/.config/zsh
export ZDOTDIR="${XDG_CONFIG_HOME:-$HOME/.config}/zsh"

# Bypass slow global startup scripts (/etc/zprofile, /etc/zshrc, /etc/profile.d)
setopt NO_GLOBAL_RCS

# -----------------------------
# XDG Base Directories
# -----------------------------
# Exported (not just defaulted) so non-zsh programs that respect the spec
# (fzf, zoxide, less, npm, etc.) agree with this config on where things live.
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"

# Ensure PATH contains user binaries without duplicates
typeset -U path PATH
path=(
    "$HOME/.local/bin"
    "/usr/local/bin"
    $path
)
export PATH

# Default Applications
export EDITOR="nvim"
export VISUAL="nvim"
export PAGER="${PAGER:-less}"
export LANG="${LANG:-C.UTF-8}"

# less: -R keeps color codes, -F auto-exits on single screen, -X skips the
# clear-on-exit so short output (e.g. git diff) stays readable in scrollback.
export LESS="${LESS:--R -F -X}"
export LESSHISTFILE="$XDG_STATE_HOME/less/history"
[[ -d "${LESSHISTFILE:h}" ]] || mkdir -p -m 700 "${LESSHISTFILE:h}"

# Colorize man pages through bat when present; falls back to the system
# pager untouched otherwise (checked here since .zshenv also runs for
# non-interactive/script invocations that may shell out to `man`).
if (( $+commands[bat] )); then
    export MANPAGER="sh -c 'col -bx | bat -l man -p'"
elif (( $+commands[batcat] )); then
    export MANPAGER="sh -c 'col -bx | batcat -l man -p'"
fi

# Flatpak data directories configuration (prioritize user over system)
typeset -aU _flatpak_dirs
[[ -d "$HOME/.local/share/flatpak/exports/share" ]] && _flatpak_dirs+=("$HOME/.local/share/flatpak/exports/share")
[[ -d "/var/lib/flatpak/exports/share" ]] && _flatpak_dirs+=("/var/lib/flatpak/exports/share")

if (( $#_flatpak_dirs )); then
    typeset -T -x XDG_DATA_DIRS xdg_data_dirs :
    typeset -U xdg_data_dirs
    xdg_data_dirs=( $_flatpak_dirs ${xdg_data_dirs:-/usr/local/share:/usr/share} )
fi
unset _flatpak_dirs
