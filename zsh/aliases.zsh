# Navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias aliases='${EDITOR:-nvim} "${ZDOTDIR:-$HOME/.config/zsh}/aliases.zsh"'
alias nv="nvim"
alias grep='grep --color=auto'
alias reload='exec zsh'

alias utm-login="curl 'https://utm.mums.ac.ir:8090/login.xml' --data-raw 'mode=191&username=zareh&password=100200&a=1792062275388&producttype=0'"

# Modern CLI substitutions (guarded & portable)
if (( $+commands[eza] )); then
    # Default ls: sorted by modification time, dirs first
    alias ls='eza --color=auto --group-directories-first --sort=name'
    # Long listing
    alias ll='eza --long --header --icons=auto --color=auto --group-directories-first --sort=modified'

    # Long + hidden files
    alias la='eza --long --header --all --icons=auto --color=auto --group-directories-first --sort=modified'

    # Tree view
    alias lt='eza --tree --level=2 --icons=auto --color=auto --group-directories-first'

    # Deep tree
    alias ltt='eza --tree --level=3 --icons=auto --color=auto --group-directories-first'

    # Git-aware listing
    alias lg='eza --long --header --git --icons=auto --color=auto --no-permissions --no-user --no-filesize --group-directories-first'

    # Only directories
    alias ldir='eza --only-dirs --icons=auto --color=auto --group-directories-first'

    # Only files
    alias lfile='eza --only-files --icons=auto --color=auto'

    # Size sorted
    alias lsize='eza --long --header --icons=auto --color=auto --sort=size --reverse'

    # Recent files first
    alias recent='eza --long --header --icons=auto --color=auto --sort=modified --reverse'

    # Replacement for tree command
    alias tree='eza --tree --icons=auto --color=auto'
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
    alias cat='bat --plain --paging=never --style=full --theme=auto'
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
