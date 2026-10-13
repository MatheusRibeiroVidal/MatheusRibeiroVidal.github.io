#!/bin/zsh
# One-way sync from the Obsidian vault to the repository.
#   ./sync_from_obsidian.zsh               Basic sync
#   ./sync_from_obsidian.zsh --update_now  Archive now.md into then.md, then sync

source "${0:A:h}/load_paths.zsh" || exit 1

# Check for --update_now flag
UPDATE_NOW=0
for arg in "$@"; do
    [[ "$arg" == "--update_now" ]] && UPDATE_NOW=1
done

# Derived folders
REPO_STATIC_FOLDER="$REPO_FOLDER/zola/static"
REPO_CONTENT_FOLDER="$REPO_FOLDER/zola/content"
REPO_PUBLIC_FOLDER="$REPO_FOLDER/zola/public"

# Ensure source folders exist
if [[ ! -d "$OBSIDIAN_STATIC_FOLDER" ]]; then
    echo "ERROR: Obsidian static folder not found at:"
    echo "$OBSIDIAN_STATIC_FOLDER"
    exit 1
fi

if [[ ! -d "$OBSIDIAN_CONTENT_FOLDER" ]]; then
    echo "ERROR: Obsidian content folder not found at:"
    echo "$OBSIDIAN_CONTENT_FOLDER"
    exit 1
fi

# Ensure public folder exists
mkdir -p "$REPO_PUBLIC_FOLDER"

# If --update_now flag is set, run now2then.py BEFORE syncing.
# This archives now.md into then.md inside Obsidian first,
# so the sync below picks up the updated then.md.
if (( UPDATE_NOW )); then
    echo "Running now2then.py to archive now.md into then.md..."
    if ! python3 "$SCRIPT_DIR/now2then.py"; then
        echo "ERROR: now2then.py failed"
        exit 1
    fi
fi

# Sync static folder
echo "Syncing static folder from Obsidian..."
if ! sync_folder "$OBSIDIAN_STATIC_FOLDER" "$REPO_STATIC_FOLDER"; then
    echo "ERROR: Static sync failed"
    exit 1
fi

# Sync content folder
echo "Syncing content folder from Obsidian..."
if ! sync_folder "$OBSIDIAN_CONTENT_FOLDER" "$REPO_CONTENT_FOLDER"; then
    echo "ERROR: Content sync failed"
    exit 1
fi

echo "Sync complete successfully."
