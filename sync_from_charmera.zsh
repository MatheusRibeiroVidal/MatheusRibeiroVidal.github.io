#!/bin/zsh
# Sync Kodak Charmera photos into the site and regenerate the gallery index.

source "${0:A:h}/load_paths.zsh" || exit 1

echo "Syncing Charmera gallery..."

# Validate Charmera folder
if [[ -z "$CHARMERA_GALLERY_FOLDER" ]]; then
    echo "ERROR: CHARMERA_GALLERY_FOLDER not defined in paths.config"
    exit 1
fi

if [[ ! -d "$CHARMERA_GALLERY_FOLDER" ]]; then
    echo "ERROR: Charmera folder not found at $CHARMERA_GALLERY_FOLDER"
    exit 1
fi

# Set Zola static folder and make sure it exists
REPO_STATIC_FOLDER="$REPO_FOLDER/zola/static/charmera"
mkdir -p "$REPO_STATIC_FOLDER"

# Copy Charmera images
if ! sync_folder "$CHARMERA_GALLERY_FOLDER" "$REPO_STATIC_FOLDER"; then
    echo "ERROR: Charmera sync failed"
    exit 1
fi

# Run Python script to update _index.md
echo "Updating _index.md..."
if ! python3 "$SCRIPT_DIR/update_charmera_index.py"; then
    echo "ERROR: Failed to update _index.md"
    exit 1
fi

echo "Charmera gallery sync complete."
