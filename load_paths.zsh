# Shared setup for the macOS scripts. Source it, don't run it:
#   source "${0:A:h}/load_paths.zsh"
#
# Sets SCRIPT_DIR and REPO_FOLDER, loads paths.config and provides the helpers
# used by the sync and build scripts.

SCRIPT_DIR="${${(%):-%x}:A:h}"

# Zola version this site is built with (keep in sync with .github/workflows/)
ZOLA_VERSION="0.22.0"

# launchd/cron start with a minimal PATH, so add the usual install locations
path=("$HOME/.local/bin" /opt/homebrew/bin /usr/local/bin $path)

CONFIG_FILE="$SCRIPT_DIR/paths.config"

if [[ ! -f "$CONFIG_FILE" ]]; then
    echo "ERROR: paths.config file not found at $CONFIG_FILE"
    echo "Copy paths.config.example to paths.config and edit the paths."
    return 1
fi

# Load KEY=VALUE pairs, skipping comments and empty lines.
# Tolerates a UTF-8 BOM and CRLF line endings (file may come from Windows).
load_paths_config() {
    setopt localoptions extendedglob
    local line key value
    while IFS= read -r line || [[ -n "$line" ]]; do
        line="${line#$'\xEF\xBB\xBF'}"
        line="${line%$'\r'}"
        [[ -z "$line" || "$line" == \#* || "$line" != *=* ]] && continue
        key="${line%%=*}"
        value="${line#*=}"
        # Trim surrounding whitespace and expand a leading ~
        key="${${key##[[:space:]]#}%%[[:space:]]#}"
        value="${${value##[[:space:]]#}%%[[:space:]]#}"
        value="${value/#\~/$HOME}"
        [[ "$key" == [A-Za-z_][A-Za-z0-9_]# ]] || continue
        typeset -g "$key=$value"
    done < "$CONFIG_FILE"
}
load_paths_config

# The repo is wherever these scripts live
REPO_FOLDER="$SCRIPT_DIR"

# One-way copy of a folder's contents (the robocopy /E equivalent): files
# missing from the source are NOT deleted from the destination. Compares by
# checksum so unchanged files are left alone even when timestamps differ.
sync_folder() {
    rsync -rtc --exclude '.DS_Store' "$1/" "$2/"
}

# Warn when the installed Zola differs from the pinned version
check_zola() {
    if ! command -v zola >/dev/null; then
        echo "ERROR: zola not found. Install Zola $ZOLA_VERSION (https://www.getzola.org/)."
        return 1
    fi
    local installed="${$(zola --version)##* }"
    if [[ "$installed" != "$ZOLA_VERSION" ]]; then
        echo "Warning: zola $installed is installed, but this site expects $ZOLA_VERSION"
    fi
}
