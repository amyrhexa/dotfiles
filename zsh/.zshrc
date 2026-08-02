# 0. Early Return for Non-Interactive Shells
[[ -o interactive ]] || return

# -----------------------------
# History Configuration
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

[[ -d "${HISTFILE:h}" ]] || mkdir -p -m 700 "${HISTFILE:h}"

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
# Prompt (Native Git-Aware)
# -----------------------------
autoload -Uz vcs_info add-zsh-hook
add-zsh-hook precmd vcs_info

zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:*' max-exports 1
zstyle ':vcs_info:git:*' formats ' %F{yellow}(%b)%f'
zstyle ':vcs_info:git:*' actionformats ' %F{yellow}(%b|%F{red}%a%F{yellow})%f'

setopt PROMPT_SUBST
# %? reflects the exit status of the last typed command even after precmd
# hooks (like vcs_info's git calls) run — zsh caches it for prompt expansion,
# so no manual capture is needed. Only shown when the last command failed.
PROMPT='%F{blue}%~%f${vcs_info_msg_0_}
%(?..%F{red}%?%f )› '
# -----------------------------
# Modular Aliases & Functions (Isolated from plugin failures)
# -----------------------------
[[ -f "$ZDOTDIR/aliases.zsh" ]] && source "$ZDOTDIR/aliases.zsh"
[[ -f "$ZDOTDIR/functions.zsh" ]] && source "$ZDOTDIR/functions.zsh"

# -----------------------------
# Plugin Manager Bootstrap (Zinit)
# -----------------------------
typeset -g _zinit_ready=0
ZINIT_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/zinit/zinit.git"
if [[ ! -f "$ZINIT_HOME/zinit.zsh" ]]; then
    if (( ! $+commands[git] )); then
        print -u2 "zsh: git required for Zinit installation"
    else
        mkdir -p "${ZINIT_HOME:h}"
        if git clone --depth 1 https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"; then
            source "$ZINIT_HOME/zinit.zsh"
            _zinit_ready=1
        else
            print -u2 "zsh: failed to clone Zinit repository"
        fi
    fi
else
    source "$ZINIT_HOME/zinit.zsh"
    _zinit_ready=1
fi

# Pre-compinit completions (blockf avoids O(N) scans; src directory injected manually)
if (( _zinit_ready )); then
    zinit ice depth"1" blockf
    zinit light zsh-users/zsh-completions
    [[ -d "${ZINIT_HOME:h}/plugins/zsh-users---zsh-completions/src" ]] && \
        fpath=("${ZINIT_HOME:h}/plugins/zsh-users---zsh-completions/src" $fpath)
fi

# -----------------------------
# Completion Initialization
# -----------------------------
autoload -Uz compinit
CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/zsh"
[[ -d "$CACHE_DIR" ]] || mkdir -p -m 700 "$CACHE_DIR"

DUMP_FILE="$CACHE_DIR/.zcompdump-${ZSH_VERSION}"
typeset -a dump_check=("$DUMP_FILE"(#qN.mh+24))

if [[ ! -f "$DUMP_FILE" ]] || (( $#dump_check )); then
    compinit -d "$DUMP_FILE"
    zcompile -U "$DUMP_FILE"
else
    compinit -C -d "$DUMP_FILE"
    [[ -f "${DUMP_FILE}.zwc" ]] || zcompile -U "$DUMP_FILE"
fi
unset dump_check

# -----------------------------
# Completion Styling
# -----------------------------
zmodload -i zsh/complist

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
    FZF_CACHE="$CACHE_DIR/fzf_init.zsh"
    FZF_TMP="${FZF_CACHE}.tmp"
    if [[ ! -s "$FZF_CACHE" || "$commands[fzf]" -nt "$FZF_CACHE" ]]; then
        if fzf --zsh > "$FZF_TMP" 2>/dev/null; then
            mv "$FZF_TMP" "$FZF_CACHE"
        else
            rm -f "$FZF_TMP"
            print '# disabled' > "$FZF_CACHE"
        fi
    fi
    [[ -s "$FZF_CACHE" ]] && source "$FZF_CACHE"
fi

if (( $+commands[zoxide] )); then
    ZOXIDE_CACHE="$CACHE_DIR/zoxide_init.zsh"
    ZOXIDE_TMP="${ZOXIDE_CACHE}.tmp"
    if [[ ! -s "$ZOXIDE_CACHE" || "$commands[zoxide]" -nt "$ZOXIDE_CACHE" ]]; then
        if zoxide init zsh > "$ZOXIDE_TMP" 2>/dev/null; then
            mv "$ZOXIDE_TMP" "$ZOXIDE_CACHE"
        else
            rm -f "$ZOXIDE_TMP"
            print '# disabled' > "$ZOXIDE_CACHE"
        fi
    fi
    [[ -s "$ZOXIDE_CACHE" ]] && source "$ZOXIDE_CACHE"
fi

# -----------------------------
# Tab Completion & Deferred Plugins
# -----------------------------
if (( _zinit_ready )); then
    # Synchronously load fzf-tab after compinit and fzf --zsh to guarantee Tab ownership
    zinit ice depth"1"
    zinit light Aloxaf/fzf-tab

    # fast-syntax-highlighting strictly loaded last
    zinit wait"0" lucid depth"1" for \
        atload"_zsh_autosuggest_start" \
        zsh-users/zsh-autosuggestions \
        zdharma-continuum/fast-syntax-highlighting
fi

# >>> mamba initialize >>>
export MAMBA_EXE="${HOME}/.local/bin/micromamba"
export MAMBA_ROOT_PREFIX="${HOME}/.micromamba"

if [[ -x "$MAMBA_EXE" ]]; then
    MAMBA_CACHE="$CACHE_DIR/micromamba_init.zsh"
    MAMBA_TMP="${MAMBA_CACHE}.tmp"
    if [[ ! -s "$MAMBA_CACHE" || "$MAMBA_EXE" -nt "$MAMBA_CACHE" ]]; then
        if "$MAMBA_EXE" shell hook --shell zsh --root-prefix "$MAMBA_ROOT_PREFIX" > "$MAMBA_TMP" 2>/dev/null; then
            mv "$MAMBA_TMP" "$MAMBA_CACHE"
        else
            rm -f "$MAMBA_TMP"
        fi
    fi
    [[ -s "$MAMBA_CACHE" ]] && source "$MAMBA_CACHE" || alias micromamba="$MAMBA_EXE"
fi
# <<< mamba initialize <<<

# -----------------------------
# Self-Compilation (same stale-check idiom as the completion dump above)
# -----------------------------
for _rc_file in "$ZDOTDIR"/.zshenv "$ZDOTDIR"/.zshrc "$ZDOTDIR"/aliases.zsh "$ZDOTDIR"/functions.zsh; do
    [[ -s "$_rc_file" && ( ! -s "${_rc_file}.zwc" || "$_rc_file" -nt "${_rc_file}.zwc" ) ]] && zcompile -U "$_rc_file"
done
unset _rc_file
