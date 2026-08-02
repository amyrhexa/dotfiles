# ===================================================================
# Standardized CLI Logging API
# ===================================================================
_log_info()    { printf '\033[1;34m==>\033[0m %s\n' "$*" }
_log_success() { printf '\033[1;32m ✔ \033[0m %s\n' "$*" }
_log_warn()    { printf '\033[1;33m ⚠ \033[0m %s\n' "$*" >&2 }
_log_error()   { printf '\033[1;31m ✖ \033[0m %s\n' "$*" >&2 }

# ===================================================================
# Directory Navigation
# ===================================================================
mkcd() {
    emulate -L zsh

    if (( $# != 1 )); then
        _log_error "Usage: mkcd <directory>"
        return 1
    fi

    mkdir -p -- "$1" && cd -- "$1"
}

# ===================================================================
# Python & Environment Management
# ===================================================================
vscode_env() {
    emulate -L zsh

    if (( $# != 1 )); then
        _log_error "Usage: vscode_env <env_name>"
        return 1
    fi

    local env_name="$1"
    local mamba_root="${MAMBA_ROOT_PREFIX:-$HOME/.micromamba}"
    local env_path="$mamba_root/envs/$env_name"
    local py_bin="$env_path/bin/python"

    if [[ ! -d "$env_path" ]]; then
        _log_error "Environment '$env_name' does not exist at $env_path"
        return 1
    fi

    if [[ ! -x "$py_bin" ]]; then
        _log_error "Python binary not found at $py_bin"
        return 1
    fi

    _log_info "Checking ipykernel in '$env_name'..."
    if ! "$py_bin" -c "import ipykernel" &>/dev/null; then
        _log_error "'ipykernel' is not installed in '$env_name'"
        _log_info "Install with: micromamba install -n \"$env_name\" ipykernel"
        return 1
    fi

    if "$py_bin" -m ipykernel install --user --name "$env_name" --display-name "Python ($env_name)" &>/dev/null; then
        _log_success "Jupyter kernel '$env_name' registered"
    else
        _log_error "Failed to register Jupyter kernel"
        return 1
    fi

    # Configure VS Code workspace interpreter if in a project root
    if [[ -d .git || -d .vscode ]]; then
        local vscode_dir=".vscode"
        local settings="$vscode_dir/settings.json"
        mkdir -p "$vscode_dir"
        if [[ ! -f "$settings" ]]; then
            printf '{\n  "python.defaultInterpreterPath": "%s"\n}\n' "$py_bin" > "$settings"
            _log_info "Configured default interpreter in .vscode/settings.json"
        fi
    fi
}
