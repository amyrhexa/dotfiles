# ~/.zshenv — must live in $HOME (it is what points zsh at ~/.config/zsh).
# Read by EVERY zsh invocation, including scripts: keep it fast and side-effect free.

# Set ZDOTDIR immediately so all further zsh files resolve to ~/.config/zsh
export ZDOTDIR="${XDG_CONFIG_HOME:-$HOME/.config}/zsh"

# Bypass slow global startup scripts (/etc/zprofile, /etc/zshrc, /etc/zlogin).
# Note: /etc/zshenv always executes before ~/.zshenv if present.
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

# Default Applications & Locale (respect existing user overrides)
export EDITOR="${EDITOR:-nvim}"
export VISUAL="${VISUAL:-nvim}"
export PAGER="${PAGER:-less}"
export LANG="${LANG:-C.UTF-8}"

# less: -R keeps color codes, -F auto-exits on single screen, -X skips the
# clear-on-exit so short output (e.g. git diff) stays readable in scrollback.
# Directory creation for LESSHISTFILE is deferred to .zshrc to keep .zshenv
# free of filesystem writes.
export LESS="${LESS:--R -F -X}"
export LESSHISTFILE="${LESSHISTFILE:-$XDG_STATE_HOME/less/history}"

# bat ships a built-in Nord theme; this keeps `bat`, man pages and git-diff
# pagers consistent with the rest of the desktop.
export BAT_THEME="${BAT_THEME:-Nord}"

# Colorize man pages through bat when present; falls back to the system
# pager untouched otherwise.
if [[ -z "$MANPAGER" ]]; then
    if (( $+commands[bat] )); then
        export MANPAGER="sh -c 'col -bx | bat -l man -p'"
    elif (( $+commands[batcat] )); then
        export MANPAGER="sh -c 'col -bx | batcat -l man -p'"
    fi
fi

# Flatpak data directories configuration (prioritize user over system).
# Note: this only affects processes started from zsh. GUI apps started by
# Hyprland/rofi inherit the session environment instead.
typeset -aU _flatpak_dirs
[[ -d "$XDG_DATA_HOME/flatpak/exports/share" ]] && _flatpak_dirs+=("$XDG_DATA_HOME/flatpak/exports/share")
[[ -d "/var/lib/flatpak/exports/share" ]] && _flatpak_dirs+=("/var/lib/flatpak/exports/share")

if (( $#_flatpak_dirs )); then
    typeset -T -x XDG_DATA_DIRS xdg_data_dirs :
    typeset -U xdg_data_dirs
    xdg_data_dirs=(${xdg_data_dirs:#})
    (( $#xdg_data_dirs )) || xdg_data_dirs=(/usr/local/share /usr/share)
    xdg_data_dirs=("${_flatpak_dirs[@]}" "${xdg_data_dirs[@]}")
fi
unset _flatpak_dirs
