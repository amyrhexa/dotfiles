# functions.zsh - interactive shell utilities
#
# Logging: _log_{info,success,warn,error,debug} MSG...
#   Output goes to stderr as "func: level: message", keeping stdout clean for
#   data (pp, y). Colour only on a terminal; NO_COLOR and TERM=dumb disable it.
#   Set FUNCTIONS_DEBUG=1 to see debug lines.
# Helpers: _usage, _need, _first, _free_path
# Exit codes: 0 ok, 1 runtime failure, 2 usage error.
# Needs GNU coreutils (cp -T, mv -T, chmod --reference, mktemp --suffix).

# ---------------------------------------------------------------------------
# Logging and helpers
# ---------------------------------------------------------------------------

_log() {
    local lvl=$1 tag=$1 ctx f c
    shift
    case $lvl in
        info)    c=34 ;;
        success) c=32 ;;
        warn)    c=33 ;;
        error)   c=31 ;;
        debug)   [[ -n $FUNCTIONS_DEBUG ]] || return 0; c=90 ;;
    esac
    # Context = nearest calling function that is not a private helper.
    for f in $funcstack[2,-1]; do
        [[ $f == _* ]] || { ctx=$f; break }
    done
    [[ -t 2 && -z $NO_COLOR && $TERM != dumb ]] && tag=$'\e[1;'$c$'m'$lvl$'\e[0m'
    print -ru2 -- "${ctx:+$ctx: }$tag: $*"
}

_log_info()    { _log info "$@" }
_log_success() { _log success "$@" }
_log_warn()    { _log warn "$@" }
_log_error()   { _log error "$@" }
_log_debug()   { _log debug "$@" }

# _usage TEXT [MSG...]: optionally log MSG as an error, print usage, return 2.
_usage() {
    local text=$1
    shift
    (( $# )) && _log_error "$@"
    print -ru2 -- "$text"
    return 2
}

# _need CMD...: succeed only if every command is available.
_need() {
    local c
    for c; do
        (( $+commands[$c] )) || { _log_error "'$c' is not installed or not in PATH"; return 1 }
    done
}

# _first CMD...: set REPLY to the first available command.
_first() {
    local c
    for c; do
        (( $+commands[$c] )) && { REPLY=$c; return 0 }
    done
    REPLY=
    return 1
}

# _free_path BASE: set REPLY to BASE, or BASE-N if it already exists.
_free_path() {
    local n=1
    REPLY=$1
    while [[ -e $REPLY || -L $REPLY ]]; do
        REPLY=$1-$((n++))
    done
}

# ---------------------------------------------------------------------------
# Navigation and transfer
# ---------------------------------------------------------------------------

# y: run yazi and cd to the directory it was left in.
y() {
    emulate -L zsh
    _need yazi || return

    local tmp cwd rc
    tmp=$(command mktemp -t yazi-cwd.XXXXXX) || return 1
    {
        command yazi --cwd-file="$tmp" "$@"
        rc=$?
        cwd=$(<"$tmp")
        if [[ -n $cwd && $cwd != $PWD && -d $cwd ]]; then
            builtin cd -- "$cwd" || _log_warn "cannot cd to '$cwd'"
        fi
    } always {
        command rm -f -- "$tmp"
    }
    return $rc
}

# rsync-copy: rsync with progress; extra rsync options are passed through.
rsync-copy() {
    emulate -L zsh
    (( $# >= 2 )) || { _usage 'Usage: rsync-copy [rsync options] <source...> <destination>'; return }
    _need rsync || return
    command rsync -aHh --info=progress2 --partial "$@"
}

# mkcd: create a directory (with parents) and enter it.
mkcd() {
    emulate -L zsh
    (( $# == 1 )) && [[ -n $1 ]] || { _usage 'Usage: mkcd <directory>'; return }

    local dir=$1
    [[ $dir == /* ]] || dir=./$dir   # immune to CDPATH and leading dashes
    command mkdir -p -- "$dir" && builtin cd -- "$dir"
}

# ---------------------------------------------------------------------------
# Python environments
# ---------------------------------------------------------------------------

# vscode_env: register a micromamba env as a Jupyter kernel and, inside a
# project root, point VS Code's default interpreter at it.
vscode_env() {
    emulate -L zsh
    (( $# == 1 )) && [[ -n $1 ]] || { _usage 'Usage: vscode_env <env_name>'; return }

    local env_name=$1
    local env_path=${MAMBA_ROOT_PREFIX:-$HOME/.micromamba}/envs/$env_name
    local py=$env_path/bin/python out

    [[ -d $env_path ]] || { _log_error "environment '$env_name' not found at $env_path"; return 1 }
    [[ -x $py ]]       || { _log_error "python not found at $py"; return 1 }

    "$py" -c 'import ipykernel' &>/dev/null || {
        _log_error "'ipykernel' is not installed in '$env_name'"
        _log_info "install with: micromamba install -n ${(q)env_name} ipykernel"
        return 1
    }

    if out=$("$py" -m ipykernel install --user --name "$env_name" \
                 --display-name "Python ($env_name)" 2>&1); then
        _log_success "Jupyter kernel '$env_name' registered"
    else
        _log_error "failed to register Jupyter kernel: $out"
        return 1
    fi

    [[ -e .git || -d .vscode ]] || return 0

    local settings=.vscode/settings.json tmp esc
    command mkdir -p -- .vscode || return 1

    if [[ ! -f $settings ]]; then
        esc=${py//\\/\\\\}
        esc=${esc//\"/\\\"}
        printf '{\n  "python.defaultInterpreterPath": "%s"\n}\n' "$esc" > "$settings"
        _log_info "created $settings"
    elif (( $+commands[jq] )); then
        tmp=$(command mktemp -- "$settings.XXXXXX") || return 1
        if command jq --arg p "$py" '. + {"python.defaultInterpreterPath": $p}' \
                "$settings" > "$tmp" 2>/dev/null; then
            command chmod --reference="$settings" -- "$tmp"
            command mv -f -- "$tmp" "$settings" && _log_info "updated interpreter in $settings"
        else
            command rm -f -- "$tmp"
            _log_warn "$settings is not plain JSON (comments?); set python.defaultInterpreterPath manually"
        fi
    else
        _log_warn "$settings exists; install 'jq' to update it automatically"
    fi
    return 0
}

# ---------------------------------------------------------------------------
# Archives and backups
# ---------------------------------------------------------------------------

# extract: unpack each archive into its own fresh directory.
extract() {
    emulate -L zsh
    setopt pipefail

    local usage='Usage: extract [-r] [-t DIR] [--] archive...'
    local -a o_rm o_to o_help
    zparseopts -D -F -- r=o_rm -remove=o_rm t:=o_to -to:=o_to h=o_help -help=o_help 2>/dev/null ||
        { _usage "$usage" 'invalid option or missing value'; return }
    (( $#o_help )) && { print -r -- "$usage"; return 0 }
    (( $# )) || { _usage "$usage"; return }

    local target=${o_to[-1]#=}
    if (( $#o_to )); then
        [[ -n $target ]] || { _usage "$usage" '-t needs a directory'; return }
        target=${target:A}
    fi

    local archive full name stem out kind st rc=0
    local -a need
    for archive in "$@"; do
        if [[ ! -f $archive ]]; then
            _log_error "'$archive' is not a file"
            rc=1; continue
        fi

        full=${archive:A}
        name=${archive:t}

        case ${name:l} in
            *.tar|*.tar.gz|*.tgz|*.tar.xz|*.txz|*.tar.zst|*.tzst|*.tar.bz2|*.tbz2|*.tbz)
                kind=tar;     need=(tar) ;;
            *.tar.lz|*.tlz)   kind=tar_lz;  need=(tar lzip) ;;
            *.tar.lz4)        kind=tar_lz4; need=(tar lz4) ;;
            *.zip|*.jar|*.war|*.ear|*.whl)
                kind=zip;     need=(unzip) ;;
            *.7z)
                kind=7z;      _first 7zz 7z 7za; need=(${REPLY:-7zz}) ;;
            *.rar)
                kind=rar;     _first unrar bsdtar; need=(${REPLY:-unrar}) ;;
            *.gz)             kind=filter; need=(gzip) ;;
            *.bz2)            kind=filter; need=(bzip2) ;;
            *.xz)             kind=filter; need=(xz) ;;
            *.zst)            kind=filter; need=(zstd) ;;
            *.lz4)            kind=filter; need=(lz4) ;;
            *.lz)             kind=filter; need=(lzip) ;;
            *)
                _log_error "unsupported archive '$archive'"
                rc=1; continue
                ;;
        esac
        _need $need || { rc=1; continue }

        stem=${name:r}
        [[ ${stem:l} == *.tar ]] && stem=${stem:r}
        [[ -n $stem ]] || stem=$name.out

        _free_path ${target:-$PWD}/$stem
        out=$REPLY
        command mkdir -p -- "$out" || { rc=1; continue }

        _log_debug "kind=$kind tool=$need[1]"
        _log_info "$archive -> $out"

        case $kind in
            tar)     command tar -xf "$full" -C "$out" ;;
            tar_lz)  command lzip -dc "$full" | command tar -xf - -C "$out" ;;
            tar_lz4) command lz4 -dc "$full" | command tar -xf - -C "$out" ;;
            zip)     command unzip -q "$full" -d "$out" ;;
            7z)      command $need[1] x -y -bso0 -bsp0 -o"$out" "$full" ;;
            rar)
                if [[ $need[1] == unrar ]]; then
                    command unrar x -o+ -idq "$full" "$out/"
                else
                    command bsdtar -xf "$full" -C "$out"
                fi
                ;;
            filter)  command $need[1] -dc "$full" > "$out/$stem" ;;
        esac
        st=$?

        if (( st )); then
            _log_error "failed to extract '$archive'"
            command rmdir -- "$out" 2>/dev/null || _log_warn "partial output kept in '$out'"
            rc=1; continue
        fi

        if (( $#o_rm )); then
            command rm -- "$full" || rc=1
        fi
    done

    return $rc
}

# compress: archive paths that share one parent directory.
compress() {
    emulate -L zsh
    setopt pipefail

    local usage='Usage: compress [-f FORMAT] [-o OUTPUT] [-l LEVEL] [-F] [--] path...
Formats: tar tar.gz tar.xz tar.zst tar.bz2 zip 7z (default: tar.zst)'
    local -a o_fmt o_out o_lvl o_force o_help
    zparseopts -D -F -- f:=o_fmt -format:=o_fmt o:=o_out -output:=o_out \
        l:=o_lvl -level:=o_lvl F=o_force -force=o_force h=o_help -help=o_help 2>/dev/null ||
        { _usage "$usage" 'invalid option or missing value'; return }
    (( $#o_help )) && { print -r -- "$usage"; return 0 }
    (( $# )) || { _usage "$usage"; return }

    local fmt=${${o_fmt[-1]#=}:l} output=${o_out[-1]#=} level=${o_lvl[-1]#=}
    fmt=${fmt#.}
    [[ -z $level || $level == <-> ]] || { _usage "$usage" 'level must be a number'; return }

    local -a names
    local p a parent
    for p in "$@"; do
        a=${p:a}
        if [[ -z $p ]] || [[ ! -e $a && ! -L $a ]]; then
            _log_error "'$p' does not exist"
            return 1
        fi
        [[ -n ${a:t} ]] || { _log_error "cannot archive '$p'"; return 1 }
        [[ -z $parent || ${a:h} == $parent ]] ||
            { _log_error 'inputs must share one parent directory'; return 1 }
        parent=${a:h}
        names+=(${a:t})
    done

    if [[ -z $fmt ]]; then
        case ${output:l} in
            "")               fmt=tar.zst ;;
            *.tar.gz|*.tgz)   fmt=tar.gz ;;
            *.tar.xz|*.txz)   fmt=tar.xz ;;
            *.tar.zst|*.tzst) fmt=tar.zst ;;
            *.tar.bz2|*.tbz2) fmt=tar.bz2 ;;
            *.tar)            fmt=tar ;;
            *.zip)            fmt=zip ;;
            *.7z)             fmt=7z ;;
            *) _log_error "cannot infer format from '$output'; use -f"; return 2 ;;
        esac
    fi

    local -a comp
    local z7
    case $fmt in
        tar)     ;;
        tar.gz)  comp=(gzip -c) ;;
        tar.xz)  comp=(xz -T0 -c) ;;
        tar.zst) comp=(zstd -T0 -q -c) ;;
        tar.bz2) comp=(bzip2 -c) ;;
        zip)     _need zip || return ;;
        7z)      _first 7zz 7z 7za; z7=${REPLY:-7zz}; _need $z7 || return ;;
        *)       _log_error "unsupported format '$fmt'"; return 2 ;;
    esac
    [[ $fmt == tar* ]] && { _need tar $comp[1] || return }
    [[ -n $level ]] && (( $#comp )) && comp+=(-$level)

    if [[ -z $output ]]; then
        local stem=${PWD:t}
        (( $#names == 1 )) && stem=$names[1]
        output=${stem:-archive}.$fmt
    fi
    local out=${output:a}

    for p in $names; do
        if [[ $out == "$parent/$p" || $out == "$parent/$p"/* ]]; then
            _log_error "output '$output' is inside the input"
            return 1
        fi
    done

    if [[ -d $out ]]; then
        _log_error "'$output' is a directory"
        return 1
    elif [[ -e $out || -L $out ]] && (( ! $#o_force )); then
        _log_error "'$output' exists (use -F to overwrite)"
        return 1
    fi

    # Build beside the target (extension kept: zip/7z pick the format from
    # it) and move into place only on success.
    local tmp=${out:h}/.compress-$$-${out:t}
    _log_debug "fmt=$fmt tmp=$tmp"
    _log_info "${names[*]} -> $output"
    {
        (
            builtin cd -- "$parent" || exit 1
            case $fmt in
                tar)   command tar -cf "$tmp" -- "${names[@]}" ;;
                tar.*) command tar -cf - -- "${names[@]}" | command "${comp[@]}" > "$tmp" ;;
                zip)   command zip -qry ${level:+-$level} "$tmp" -- "${names[@]}" ;;
                7z)    command $z7 a -bso0 -bsp0 ${level:+-mx=$level} "$tmp" -- "${names[@]}" ;;
            esac
        ) && command mv -fT -- "$tmp" "$out" || { _log_error 'compression failed'; return 1 }
    } always {
        [[ -e $tmp || -L $tmp ]] && command rm -f -- "$tmp"
    }
    return 0
}

# bak: copy files or directories to NAME.bak-YYYYmmdd-HHMMSS.
bak() {
    emulate -L zsh

    local usage='Usage: bak [-d DIR] [--] path...'
    local -a o_dir o_help
    zparseopts -D -F -- d:=o_dir -dir:=o_dir h=o_help -help=o_help 2>/dev/null ||
        { _usage "$usage" 'invalid option or missing value'; return }
    (( $#o_help )) && { print -r -- "$usage"; return 0 }
    (( $# )) || { _usage "$usage"; return }

    local dest=${o_dir[-1]#=}
    if (( $#o_dir )); then
        [[ -n $dest && -d $dest ]] || { _log_error "'$dest' is not a directory"; return 1 }
        dest=${dest:A}
    fi

    local ts p src out rc=0
    print -Pv ts '%D{%Y%m%d-%H%M%S}'

    for p in "$@"; do
        src=${p:a}
        if [[ -z $p ]] || [[ ! -e $src && ! -L $src ]]; then
            _log_error "'$p' does not exist"
            rc=1; continue
        fi
        if [[ -z ${src:t} ]]; then
            _log_error "cannot back up '$p'"
            rc=1; continue
        fi

        _free_path ${dest:-${src:h}}/${src:t}.bak-$ts
        out=$REPLY
        if command cp -aT -- "$src" "$out"; then
            _log_success "$p -> $out"
        else
            [[ -e $out || -L $out ]] && command rm -rf -- "$out"
            _log_error "failed to back up '$p'"
            rc=1
        fi
    done

    return $rc
}

# ---------------------------------------------------------------------------
# Pretty-print and validate
# ---------------------------------------------------------------------------

# pp: pretty-print or validate json, yaml, xml and markdown (markdown opens in
# leaf; its -c uses markdownlint, so that is a style check, not validity).
pp() {
    emulate -L zsh
    setopt pipefail

    local usage='Usage: pp [-c] [-w] [-t TYPE] [--] [file...]
  (default)  pretty-print to stdout (md: open in leaf)
  -c         validate only
  -w         rewrite the file in place (json yaml xml)
  -t TYPE    json | yaml | xml | md (default: from extension; required for stdin)'
    local -a o_chk o_wr o_type o_help
    zparseopts -D -F -- c=o_chk -check=o_chk w=o_wr -write=o_wr \
        t:=o_type -type:=o_type h=o_help -help=o_help 2>/dev/null ||
        { _usage "$usage" 'invalid option or missing value'; return }
    (( $#o_help )) && { print -r -- "$usage"; return 0 }

    local check=$#o_chk write=$#o_wr type=${${o_type[-1]#=}:l}
    case $type in
        ""|json|yaml|xml|md) ;;
        yml)      type=yaml ;;
        markdown) type=md ;;
        *) _usage "$usage" "unsupported type '$type'"; return ;;
    esac
    (( check && write )) && { _usage "$usage" '-c and -w cannot be combined'; return }

    local -a files=("$@")
    local tmpin
    if (( ! $# )); then
        [[ -t 0 ]]      && { _usage "$usage"; return }
        [[ -n $type ]]  || { _usage "$usage" 'stdin needs -t TYPE'; return }
        (( write ))     && { _usage "$usage" '-w cannot be used with stdin'; return }
        tmpin=$(command mktemp --suffix=".$type") || return 1
        command cat > "$tmpin" || { command rm -f -- "$tmpin"; return 1 }
        files=("$tmpin")
    fi

    local f t src label tmp rc=0
    local -a cmd
    {
        for f in "${files[@]}"; do
            label=$f
            [[ -n $tmpin && $f == $tmpin ]] && label=stdin

            if [[ ! -f $f ]]; then
                _log_error "'$f' is not a file"
                rc=1; continue
            fi

            t=$type
            if [[ -z $t ]]; then
                case ${f:l} in
                    *.json)          t=json ;;
                    *.yaml|*.yml)    t=yaml ;;
                    *.xml)           t=xml ;;
                    *.md|*.markdown) t=md ;;
                    *)
                        _log_error "cannot detect type of '$f'; use -t"
                        rc=1; continue
                        ;;
                esac
            fi

            case $t in
                json) cmd=(jq .);             (( check )) && cmd=(jq empty) ;;
                yaml) cmd=(yq -P .);          (( check )) && cmd=(yq .) ;;
                xml)  cmd=(xmllint --format); (( check )) && cmd=(xmllint --noout) ;;
                md)   cmd=(leaf);             (( check )) && cmd=(markdownlint) ;;
            esac
            _need $cmd[1] || { rc=1; continue }
            _log_debug "type=$t cmd=${cmd[*]}"

            src=${f:A}   # absolute: can never be mistaken for an option

            if (( check )); then
                if command "${cmd[@]}" "$src" >/dev/null; then
                    _log_success "$label: valid"
                else
                    _log_error "$label: invalid"
                    rc=1
                fi

            elif (( write )); then
                if [[ $t == md ]]; then
                    _log_error "$label: -w is not supported for markdown"
                    rc=1; continue
                fi
                tmp=$(command mktemp -- "$src.pp.XXXXXX") || { rc=1; continue }
                if ! command "${cmd[@]}" "$src" > "$tmp" || [[ ! -s $tmp ]]; then
                    command rm -f -- "$tmp"
                    _log_error "$label: formatting failed (file left untouched)"
                    rc=1; continue
                fi
                if command cmp -s -- "$tmp" "$src"; then
                    command rm -f -- "$tmp"
                    _log_info "$label: unchanged"
                else
                    command chmod --reference="$src" -- "$tmp"
                    command mv -f -- "$tmp" "$src" || { rc=1; continue }
                    _log_success "$label: formatted"
                fi

            else
                (( $#files > 1 )) && [[ $t != md ]] && _log_info "==> $label"
                command "${cmd[@]}" "$src" || { _log_error "$label: failed"; rc=1 }
            fi
        done
    } always {
        [[ -n $tmpin ]] && command rm -f -- "$tmpin"
    }

    return $rc
}



# ---------------------------------------------------------------------------
# Proxy
# ---------------------------------------------------------------------------

# proxy: enable, disable, toggle, or inspect the local proxy.
# Default endpoint: HTTP proxy at 127.0.0.1:2080.
# Usage: proxy [on [URL] | off | toggle | status]
proxy() {
    emulate -L zsh

    local usage='Usage: proxy [on [URL] | off | toggle | status]
  on [URL]  Enable proxy (default: http://127.0.0.1:2080)
  off       Disable proxy environment variables
  toggle    Toggle proxy (default action)
  status    Show proxy status'

    local action=${1:-toggle}
    local url=${2:-http://127.0.0.1:2080}
    local active=0 v
    local -a vars=(http_proxy https_proxy all_proxy HTTP_PROXY HTTPS_PROXY ALL_PROXY)

    case $action in
        on)
            (( $# <= 2 )) || { _usage "$usage"; return }
            [[ -n $url ]] || { _usage "$usage" 'proxy URL cannot be empty'; return }

            export http_proxy="$url"
            export https_proxy="$url"
            export all_proxy="$url"
            export HTTPS_PROXY="$url"
            export ALL_PROXY="$url"
            unset HTTP_PROXY

            _log_success "enabled: $url"
            ;;

        off)
            (( $# == 1 )) || { _usage "$usage"; return }

            unset "${vars[@]}"
            _log_success "disabled"
            ;;

        toggle|status)
            (( $# == 1 )) || { _usage "$usage"; return }

            for v in "${vars[@]}"; do
                [[ -n ${(P)v} ]] && { active=1; break }
            done

            if [[ $action == status ]]; then
                if (( active )); then
                    _log_info 'proxy is enabled'
                    for v in "${vars[@]}"; do
                        [[ -n ${(P)v} ]] && print -ru2 -- "  $v=${(P)v}"
                    done
                else
                    _log_info 'proxy is disabled'
                fi
                return 0
            fi

            if (( active )); then
                unset "${vars[@]}"
                _log_success "disabled"
            else
                export http_proxy="$url"
                export https_proxy="$url"
                export all_proxy="$url"
                export HTTPS_PROXY="$url"
                export ALL_PROXY="$url"
                unset HTTP_PROXY

                _log_success "enabled: $url"
            fi
            ;;

        -h|--help|help)
            print -r -- "$usage"
            ;;

        *)
            _usage "$usage" "unknown action '$action'"
            return
            ;;
    esac
}
