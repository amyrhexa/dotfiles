# ~/.config/zsh/.zshrc — Nord Dark
# Colours below use ANSI names (blue, cyan, red...), so kitty's palette themes
# the prompt and completion automatically. Only fzf needs explicit hex values.

# 0. Early return for non-interactive shells
[[ -o interactive ]] || return

# Powerlevel10k instant prompt. Must stay near the top; nothing above this
# may print output or read input.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
    source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# -----------------------------
# History & State Directories
# -----------------------------
HISTFILE="${XDG_STATE_HOME:-$HOME/.local/state}/zsh/history"
HISTSIZE=50000
SAVEHIST=50000

setopt EXTENDED_HISTORY
setopt INC_APPEND_HISTORY
setopt HIST_FIND_NO_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_SAVE_NO_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_REDUCE_BLANKS

[[ -d "${HISTFILE:h}" ]] || command mkdir -p -m 700 "${HISTFILE:h}"
[[ -n "$LESSHISTFILE" && ! -d "${LESSHISTFILE:h}" ]] && command mkdir -p -m 700 "${LESSHISTFILE:h}"

# -----------------------------
# Core Shell Options
# -----------------------------
setopt AUTO_MENU COMPLETE_IN_WORD ALWAYS_TO_END LIST_AMBIGUOUS
setopt AUTO_CD AUTO_PUSHD PUSHD_IGNORE_DUPS
setopt EXTENDED_GLOB NUMERIC_GLOB_SORT
setopt NO_CLOBBER INTERACTIVE_COMMENTS HASH_LIST_ALL

# Treat path separators as word boundaries so ^W / word-motions stop at each
# path segment instead of deleting a whole /long/path/like/this in one go.
WORDCHARS=${WORDCHARS//[\/]/}

# -----------------------------
# Keybindings (terminfo + portable fallbacks)
# -----------------------------
bindkey -e
zmodload -i zsh/terminfo

typeset -A key
key[Home]="${terminfo[khome]}"
key[End]="${terminfo[kend]}"
key[Delete]="${terminfo[kdch1]}"

[[ -n "${key[Home]}" ]]   && bindkey "${key[Home]}"   beginning-of-line
[[ -n "${key[End]}" ]]    && bindkey "${key[End]}"    end-of-line
[[ -n "${key[Delete]}" ]] && bindkey "${key[Delete]}" delete-char
unset key

# Universal fallbacks & word operations
bindkey "^[[H"    beginning-of-line
bindkey "^[[F"    end-of-line
bindkey "^[[3~"   delete-char
bindkey "^[[3;5~" kill-word
bindkey "^H"      backward-delete-char
bindkey "^W"      backward-kill-word
bindkey "^[^?"    backward-kill-word
bindkey "^[[1;5C" forward-word
bindkey "^[[1;5D" backward-word
bindkey "^?"      backward-delete-char

# -----------------------------
# Modular Aliases & Functions (Isolated from plugin failures)
# -----------------------------
[[ -r "$ZDOTDIR/aliases.zsh" ]] && source "$ZDOTDIR/aliases.zsh"
[[ -r "$ZDOTDIR/functions.zsh" ]] && source "$ZDOTDIR/functions.zsh"

# -----------------------------
# Plugin Manager Bootstrap (Zinit)
# -----------------------------
typeset -g _zinit_ready=0
ZINIT_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/zinit/zinit.git"
if [[ ! -r "$ZINIT_HOME/zinit.zsh" ]]; then
    if [[ -e "$ZINIT_HOME" ]]; then
        print -u2 "zsh: incomplete Zinit installation at $ZINIT_HOME"
    elif (( ! $+commands[git] )); then
        print -u2 "zsh: git required for Zinit installation"
    else
        command mkdir -p "${ZINIT_HOME:h}" &&
            command git clone --depth 1 https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME" ||
            print -u2 "zsh: failed to clone Zinit repository"
    fi
fi

# Source outside `if` condition so ERR_RETURN inside plugins is not suppressed
if [[ -r "$ZINIT_HOME/zinit.zsh" ]]; then
    source "$ZINIT_HOME/zinit.zsh"
    (( $? == 0 && $+functions[zinit] )) && _zinit_ready=1
fi

# -----------------------------
# Prompt (Powerlevel10k with native fallback)
# -----------------------------
if (( _zinit_ready )); then
    zinit ice depth"1"
    zinit light romkatv/powerlevel10k
fi

if (( $+functions[p10k] )); then
    typeset -g POWERLEVEL9K_CONFIG_FILE="$ZDOTDIR/p10k.zsh"
    [[ -r "$POWERLEVEL9K_CONFIG_FILE" ]] && source "$POWERLEVEL9K_CONFIG_FILE"
else
    PROMPT='%F{cyan}%~%f %F{blue}›%f '   # fallback if Zinit/p10k is unavailable
fi

# Pre-compinit completions (blockf avoids O(N) scans; src directory injected manually)
typeset -U fpath
if (( _zinit_ready )); then
    zinit ice depth"1" blockf
    zinit light zsh-users/zsh-completions
    [[ -d "${ZINIT_HOME:h}/plugins/zsh-users---zsh-completions/src" ]] &&
        fpath=("${ZINIT_HOME:h}/plugins/zsh-users---zsh-completions/src" $fpath)
fi

# -----------------------------
# Completion Initialization
# -----------------------------
autoload -Uz compinit
CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/zsh"
[[ -d "$CACHE_DIR" ]] || command mkdir -p -m 700 "$CACHE_DIR"

DUMP_FILE="$CACHE_DIR/.zcompdump-${ZSH_VERSION}"
# Run full compinit (including compaudit security checks and fpath file-count
# validation) on every startup instead of bypassing security with compinit -C.
compinit -d "$DUMP_FILE"
if [[ -s "$DUMP_FILE" && ( ! -s "${DUMP_FILE}.zwc" || "$DUMP_FILE" -nt "${DUMP_FILE}.zwc" ) ]]; then
    if zcompile -U "${DUMP_FILE}.tmp.$$.zwc" "$DUMP_FILE"; then
        command mv -f -- "${DUMP_FILE}.tmp.$$.zwc" "${DUMP_FILE}.zwc"
    else
        command rm -f -- "${DUMP_FILE}.tmp.$$.zwc" "${DUMP_FILE}.zwc"
    fi
fi

# -----------------------------
# LS_COLORS (cached, atomic under NO_CLOBBER)
# -----------------------------
# NO_GLOBAL_RCS in .zshenv skips the distro's /etc/profile.d/colorls.sh, so
# LS_COLORS would be empty (no colours in `ls` completion lists). Rebuild it once
# and cache it via a PID-unique temporary file.
if [[ -z "$LS_COLORS" ]] && (( $+commands[dircolors] )); then
    LSC_CACHE="$CACHE_DIR/dircolors.zsh"
    if [[ -s "$LSC_CACHE" && ! "$commands[dircolors]" -nt "$LSC_CACHE" ]]; then
        source "$LSC_CACHE"
    fi
    if [[ ! -s "$LSC_CACHE" || "$commands[dircolors]" -nt "$LSC_CACHE" || -z "$LS_COLORS" ]]; then
        LSC_TMP="${LSC_CACHE}.tmp.$$"
        if dircolors -b >| "$LSC_TMP" 2>/dev/null && [[ -s "$LSC_TMP" ]]; then
            command mv -f -- "$LSC_TMP" "$LSC_CACHE"
        else
            command rm -f -- "$LSC_TMP"
        fi
        [[ -s "$LSC_CACHE" ]] && source "$LSC_CACHE"
    fi
fi

# -----------------------------
# Completion Styling
# -----------------------------
zmodload -i zsh/complist

# Default to native menu selection; overridden to `menu no` below only after
# fzf-tab is confirmed loaded.
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*'
zstyle ':completion:*' group-name ''
zstyle ':completion:*:descriptions' format '%F{yellow}-- %d --%f'
zstyle ':completion:*:warnings' format '%F{red}-- no matches --%f'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' squeeze-slashes true

# -----------------------------
# CLI Integrations (Cached Output; must precede fzf-tab)
# -----------------------------
if (( $+commands[fzf] )); then
    # Nord Dark for fzf and fzf-tab (fzf-tab reads FZF_DEFAULT_OPTS too).
    export FZF_DEFAULT_OPTS="--height=40% --layout=reverse --border=rounded \
--color=bg:-1,bg+:#353d4b,fg:#aeb8c8,fg+:#eceff4,hl:#88c0d0,hl+:#9bd0df \
--color=info:#8b97b0,prompt:#88c0d0,pointer:#88c0d0,marker:#a3be8c,spinner:#81a1c1 \
--color=header:#8b97b0,border:#444d5e,gutter:-1"

    FZF_CACHE="$CACHE_DIR/fzf_init.zsh"
    if [[ -s "$FZF_CACHE" && ! "$commands[fzf]" -nt "$FZF_CACHE" ]]; then
        source "$FZF_CACHE"
    fi
    if [[ ! -s "$FZF_CACHE" || "$commands[fzf]" -nt "$FZF_CACHE" ]] || (( ! $+functions[fzf-file-widget] )); then
        FZF_TMP="${FZF_CACHE}.tmp.$$"
        if fzf --zsh >| "$FZF_TMP" 2>/dev/null && [[ -s "$FZF_TMP" ]]; then
            command mv -f -- "$FZF_TMP" "$FZF_CACHE"
        else
            command rm -f -- "$FZF_TMP"
        fi
        [[ -s "$FZF_CACHE" ]] && source "$FZF_CACHE"
    fi
fi

if (( $+commands[zoxide] )); then
    ZOXIDE_CACHE="$CACHE_DIR/zoxide_init.zsh"
    if [[ -s "$ZOXIDE_CACHE" && ! "$commands[zoxide]" -nt "$ZOXIDE_CACHE" ]]; then
        source "$ZOXIDE_CACHE"
    fi
    if [[ ! -s "$ZOXIDE_CACHE" || "$commands[zoxide]" -nt "$ZOXIDE_CACHE" ]] || (( ! $+functions[__zoxide_z] )); then
        ZOXIDE_TMP="${ZOXIDE_CACHE}.tmp.$$"
        if zoxide init zsh >| "$ZOXIDE_TMP" 2>/dev/null && [[ -s "$ZOXIDE_TMP" ]]; then
            command mv -f -- "$ZOXIDE_TMP" "$ZOXIDE_CACHE"
        else
            command rm -f -- "$ZOXIDE_TMP"
        fi
        [[ -s "$ZOXIDE_CACHE" ]] && source "$ZOXIDE_CACHE"
    fi
fi

# -----------------------------
# Tab Completion & Deferred Plugins
# -----------------------------
typeset -g _use_fzf_tab=0
if (( _zinit_ready )); then
    # Synchronously load fzf-tab after compinit and fzf --zsh to guarantee Tab ownership.
    # Disable native completion menu only if fzf-tab actually loaded.
    if (( $+commands[fzf] )); then
        zinit ice depth"1"
        zinit light Aloxaf/fzf-tab
        if (( $+functions[fzf-tab-complete] )); then
            _use_fzf_tab=1
            zstyle ':completion:*' menu no
        fi
    fi

    # Autosuggestions use ANSI "bright black" (color8 = #8490a8 in kitty) by default.
    # fast-syntax-highlighting strictly loaded last.
    zinit wait"0" lucid depth"1" for \
        atload"_zsh_autosuggest_start" \
        zsh-users/zsh-autosuggestions \
        zdharma-continuum/fast-syntax-highlighting
fi

# >>> mamba initialize >>>
export MAMBA_EXE="${HOME}/.local/bin/micromamba"
export MAMBA_ROOT_PREFIX="${HOME}/.micromamba"

if [[ -x "$MAMBA_EXE" ]]; then
    # Unalias micromamba before sourcing so a fallback alias cannot expand inside
    # the hook's `micromamba() { ... }` definition. Only fall back to the alias
    # when the hook fails to define the `micromamba` function.
    unalias micromamba 2>/dev/null
    MAMBA_CACHE="$CACHE_DIR/micromamba_init.zsh"
    if [[ -s "$MAMBA_CACHE" && ! "$MAMBA_EXE" -nt "$MAMBA_CACHE" ]]; then
        source "$MAMBA_CACHE"
    fi
    if [[ ! -s "$MAMBA_CACHE" || "$MAMBA_EXE" -nt "$MAMBA_CACHE" ]] || (( ! $+functions[micromamba] )); then
        MAMBA_TMP="${MAMBA_CACHE}.tmp.$$"
        if "$MAMBA_EXE" shell hook --shell zsh --root-prefix "$MAMBA_ROOT_PREFIX" >| "$MAMBA_TMP" 2>/dev/null && [[ -s "$MAMBA_TMP" ]]; then
            command mv -f -- "$MAMBA_TMP" "$MAMBA_CACHE"
        else
            command rm -f -- "$MAMBA_TMP"
        fi
        [[ -s "$MAMBA_CACHE" ]] && source "$MAMBA_CACHE"
    fi
    (( $+functions[micromamba] )) || alias micromamba="$MAMBA_EXE"
fi
# <<< mamba initialize <<<

# -----------------------------
# Self-Compilation (atomic .zwc generation; removes stale .zwc on syntax error)
# -----------------------------
# (~/.zshenv is intentionally not listed: it lives in $HOME, not in $ZDOTDIR.)
for _rc_file in "$ZDOTDIR"/{.zshrc,aliases.zsh,functions.zsh,p10k.zsh}(N); do
    if [[ ! -s "${_rc_file}.zwc" || "$_rc_file" -nt "${_rc_file}.zwc" ]]; then
        if zcompile -U "${_rc_file}.tmp.$$.zwc" "$_rc_file"; then
            command mv -f -- "${_rc_file}.tmp.$$.zwc" "${_rc_file}.zwc"
        else
            command rm -f -- "${_rc_file}.tmp.$$.zwc" "${_rc_file}.zwc"
        fi
    fi
done
unset _rc_file CACHE_DIR DUMP_FILE LSC_CACHE LSC_TMP FZF_CACHE FZF_TMP ZOXIDE_CACHE ZOXIDE_TMP MAMBA_CACHE MAMBA_TMP
