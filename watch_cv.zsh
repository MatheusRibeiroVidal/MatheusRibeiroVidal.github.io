#!/bin/zsh
# CV File Watcher
# Monitors the CV file for changes and syncs it to zola/static/cv/
# Run this script in a separate terminal while developing

source "${0:A:h}/load_paths.zsh" || exit 1

if [[ -z "$CV_SOURCE" ]]; then
    echo "ERROR: CV_SOURCE not found in paths.config"
    exit 1
fi

if [[ ! -f "$CV_SOURCE" ]]; then
    echo "ERROR: CV file not found at $CV_SOURCE"
    exit 1
fi

CV_DEST_DIR="$REPO_FOLDER/zola/static/cv"
CV_DEST_FILE="$CV_DEST_DIR/CV_MatheusRibeiroVidal.pdf"

# Create destination directory if it doesn't exist
if [[ ! -d "$CV_DEST_DIR" ]]; then
    mkdir -p "$CV_DEST_DIR"
    echo "Created directory: $CV_DEST_DIR"
fi

# Initial sync if destination doesn't exist
if [[ ! -f "$CV_DEST_FILE" ]]; then
    cp -f "$CV_SOURCE" "$CV_DEST_FILE"
    echo "Initial sync: CV copied to $CV_DEST_FILE"
fi

echo "CV File Watcher started"
echo "Watching: $CV_SOURCE"
echo "Syncing to: $CV_DEST_FILE"
echo "Press Ctrl+C to stop."

# Poll the modification time; sync whenever the source is saved again
last_mtime="$(stat -f %m "$CV_SOURCE")"
while true; do
    sleep 1
    mtime="$(stat -f %m "$CV_SOURCE" 2>/dev/null)" || continue
    if [[ "$mtime" != "$last_mtime" ]]; then
        # Small delay to ensure the file is fully written
        sleep 0.5
        if cp -f "$CV_SOURCE" "$CV_DEST_FILE"; then
            last_mtime="$(stat -f %m "$CV_SOURCE")"
            echo "[$(date '+%Y-%m-%d %H:%M:%S')] CV synced: $CV_DEST_FILE"
        fi
    fi
done
