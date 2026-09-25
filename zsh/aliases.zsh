# Navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias aliases='${EDITOR:-nvim} "${ZDOTDIR:-$HOME/.config/zsh}/aliases.zsh"'
alias nv="nvim"
alias grep='grep --color=auto'
alias reload='exec zsh'
alias sysup="sudo dnf upgrade --refresh && sudo dnf autoremove && flatpak update && flatpak uninstall --unused"

# Modern CLI substitutions (guarded & portable)
if (( $+commands[eza] )); then
    alias ls='eza --sort=time --color=auto --group-directories-first'
    alias ll='eza --sort=time --icons --color=auto --group-directories-first --long'
    alias la='eza --sort=time --icons --color=auto --group-directories-first --long --all'
    alias lt='eza --sort=time --icons --group-directories-first --tree --level=2'
    alias lg='eza --sort=time --icons --group-directories-first --git --no-permissions --no-user --no-filesize --long'
    alias tree='eza --tree --icons'
else
    if [[ "$OSTYPE" == darwin* ]]; then
        alias ls='ls -G'
        alias ll='ls -G -lh'
        alias la='ls -G -lah'
    else
        alias ls='ls --color=auto'
        alias ll='ls --color=auto -lh'
        alias la='ls --color=auto -lah'
    fi
fi

if (( $+commands[bat] )); then
    alias cat='bat --plain --paging=never'
elif (( $+commands[batcat] )); then
    alias bat='batcat'
    alias cat='batcat --plain --paging=never'
fi

(( ! $+commands[fd] && $+commands[fdfind] )) && alias fd='fdfind'

# Human-readable disk/memory usage
alias df='df -h'
alias du='du -h'
alias free='free -h'

# Git shortcuts
alias g='git'
alias gs='git status -sb'
alias gd='git diff'
alias gl='git log --oneline --graph'
alias gaa='git add -A'
alias gcm='git commit -m'
alias gp='git push'
alias gpl='git pull'

# Micromamba shortcuts
alias mic='micromamba'
alias mica='micromamba activate'
alias mici='micromamba install'
alias micd='micromamba deactivate'
alias micl='micromamba env list'

# Safe global aliases
alias -g @ne='2>/dev/null'
alias -g @nul='>/dev/null 2>&1'
