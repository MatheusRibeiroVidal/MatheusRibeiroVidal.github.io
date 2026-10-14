#!/bin/zsh
# Build engine: orchestrates syncs, builds and commits.
#   ./builderserver.zsh -serve   Sync, build and start the local preview server
#   ./builderserver.zsh -build   Sync, build and open GitHub Desktop for a manual commit
#   ./builderserver.zsh -auto    Sync, build, auto-commit and push

source "${0:A:h}/load_paths.zsh" || exit 1

# Go to the root of the repo
cd "$SCRIPT_DIR" || exit 1

ZOLA_PATH="$SCRIPT_DIR/zola"
DOCS_PATH="$SCRIPT_DIR/docs"
PUBLIC_PATH="$ZOLA_PATH/public"
CONFIG_TOML="$ZOLA_PATH/config.toml"

# ============================================================================
# HELPER FUNCTIONS
# ============================================================================

# Copy the CV from CV_SOURCE into zola/static/cv/
sync_cv_file() {
    if [[ -z "$CV_SOURCE" ]]; then
        echo "Warning: CV_SOURCE not found in paths.config"
        return
    fi

    local cv_dest_dir="$ZOLA_PATH/static/cv"
    if [[ -f "$CV_SOURCE" ]]; then
        mkdir -p "$cv_dest_dir"
        cp -f "$CV_SOURCE" "$cv_dest_dir/CV_MatheusRibeiroVidal.pdf"
        echo "[CV] Synced to website"
    else
        echo "Warning: CV file not found at $CV_SOURCE"
    fi
}

sync_charmera() {
    if ! "$SCRIPT_DIR/sync_from_charmera.zsh"; then
        echo "Error: Sync from Charmera failed!"
        exit 1
    fi
}

sync_obsidian() {
    if ! "$SCRIPT_DIR/sync_from_obsidian.zsh" "$@"; then
        echo "Error: Sync from Obsidian failed!"
        exit 1
    fi
}

# Set last_update_to_site in config.toml, but only if .md files changed
update_timestamp() {
    git add .

    if git diff --cached --name-only | grep -q '\.md$'; then
        if [[ -f "$CONFIG_TOML" ]]; then
            local ts="$(date '+%Y-%m-%dT%H:%M:%S')"
            sed -i '' -E "s|^last_update_to_site[[:space:]]*=[[:space:]]*\".*\"|last_update_to_site = \"$ts\"|" "$CONFIG_TOML"
            echo "Updated last_update_to_site in config.toml to $ts"
        else
            echo "config.toml not found at $CONFIG_TOML"
        fi
    else
        echo "No staged .md file changes detected. Skipping timestamp update."
    fi
}

build_site() {
    if ! (cd "$ZOLA_PATH" && zola build); then
        echo "Error: zola build failed!"
        exit 1
    fi
}

# Copy the built site from zola/public to docs
copy_public_to_docs() {
    if [[ ! -d "$PUBLIC_PATH" ]]; then
        echo "Error: public folder not found in $ZOLA_PATH!"
        exit 1
    fi

    if [[ ! -d "$DOCS_PATH" ]]; then
        echo "Error: docs folder not found!"
        exit 1
    fi

    cp -R "$PUBLIC_PATH/." "$DOCS_PATH/"
}

# ============================================================================
# ARGUMENTS
# ============================================================================
if (( $# == 0 )); then
    echo "Error: Please specify a mode: -serve, -build, or -auto"
    exit 1
fi
if (( $# > 1 )); then
    echo "Error: Please specify only one mode"
    exit 1
fi

MODE="${1#-}"
MODE="${MODE#-}"

if [[ "$MODE" != (serve|build|auto) ]]; then
    echo "Error: Unknown mode '$1'. Use -serve, -build, or -auto"
    exit 1
fi

if [[ ! -d "$ZOLA_PATH" ]]; then
    echo "Error: zola folder not found!"
    exit 1
fi

check_zola || exit 1

# ============================================================================
# SERVE MODE
# ============================================================================
if [[ "$MODE" == "serve" ]]; then
    echo "Running in SERVE mode..."

    sync_charmera
    sync_obsidian
    build_site
    sync_cv_file

    # Start the Zola server and open the browser (Ctrl+C to stop)
    echo "Starting Zola server. Opening browser..."
    cd "$ZOLA_PATH" && exec zola serve --drafts --open
fi

# ============================================================================
# BUILD MODE
# ============================================================================
if [[ "$MODE" == "build" ]]; then
    echo "Running in BUILD mode..."

    sync_charmera
    sync_obsidian
    sync_cv_file
    update_timestamp
    build_site
    copy_public_to_docs

    # Open GitHub Desktop to review and commit the changes
    if command -v github >/dev/null; then
        github "$SCRIPT_DIR"
    else
        open -a "GitHub Desktop" "$SCRIPT_DIR"
    fi

    echo "Build complete. Changes ready to commit."
fi

# ============================================================================
# AUTO MODE (Auto-commit with changelog)
# ============================================================================
if [[ "$MODE" == "auto" ]]; then
    echo "Running in AUTO mode..."

    # Check if now.md changed BEFORE syncing
    OBSIDIAN_NOW="$OBSIDIAN_CONTENT_FOLDER/now.md"
    REPO_NOW="$ZOLA_PATH/content/now.md"
    NOW_MD_CHANGED=0
    if [[ -n "$OBSIDIAN_CONTENT_FOLDER" && -f "$OBSIDIAN_NOW" ]]; then
        # A missing repo file also counts as changed
        if ! cmp -s "$OBSIDIAN_NOW" "$REPO_NOW"; then
            NOW_MD_CHANGED=1
            echo "now.md content has changed"
        fi
    fi

    sync_charmera

    # Sync changes from Obsidian (archiving now.md first if it changed)
    if (( NOW_MD_CHANGED )); then
        echo "Updating date on now.md and archiving to then.md"
        sync_obsidian --update_now
    else
        echo "No updates found on now.md"
        sync_obsidian
    fi

    sync_cv_file
    update_timestamp
    build_site
    copy_public_to_docs

    # Number the commit after the existing "Auto - Content Update" commits
    COMMIT_COUNT=$(git log --oneline --grep="^Auto - Content Update" | wc -l)
    COMMIT_TITLE="Auto - Content Update $(( COMMIT_COUNT + 1 ))"

    # Stage all changes
    git add -A

    # List the added, modified and removed .md files in the commit body
    UPDATED_MD_FILES="$(git diff --cached --name-status | grep -E '^[ADM].*\.md')"

    if git diff --cached --quiet; then
        echo "No changes to commit. Working tree clean."
    else
        if [[ -n "$UPDATED_MD_FILES" ]]; then
            git commit -m "$COMMIT_TITLE" -m "Updated .md files:"$'\n'"$UPDATED_MD_FILES" || exit 1
        else
            git commit -m "$COMMIT_TITLE" || exit 1
        fi

        if ! git push; then
            echo "Error: git push failed! The commit '$COMMIT_TITLE' is local only."
            exit 1
        fi

        echo "Changes have been committed and pushed successfully with message:"
        echo "$COMMIT_TITLE"
        [[ -n "$UPDATED_MD_FILES" ]] && echo "\nUpdated .md files:\n$UPDATED_MD_FILES"
    fi
fi

exit 0
