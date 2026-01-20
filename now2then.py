import os
import shutil
import sys
from datetime import datetime

def load_config():
    """Load paths from paths.config file"""
    script_dir = os.path.dirname(os.path.abspath(__file__))
    config_path = os.path.join(script_dir, "paths.config")
    
    if not os.path.exists(config_path):
        print(f"ERROR: paths.config not found at {config_path}")
        sys.exit(1)
    
    config = {}
    with open(config_path, 'r', encoding='utf-8') as f:
        for line in f:
            line = line.strip()
            # Skip comments and empty lines
            if line.startswith('#') or not line or '=' not in line:
                continue
            key, value = line.split('=', 1)
            config[key.strip()] = value.strip()
    
    # Validate required keys
    if 'OBSIDIAN_CONTENT_FOLDER' not in config:
        print("ERROR: OBSIDIAN_CONTENT_FOLDER not defined in paths.config")
        sys.exit(1)
    
    return config

# Load configuration
config = load_config()
obsidian_content_folder = config['OBSIDIAN_CONTENT_FOLDER']

# Define the paths for now.md and then.md
now_file = os.path.join(obsidian_content_folder, "now.md")
then_file = os.path.join(obsidian_content_folder, "then.md")

# Validate paths exist
if not os.path.exists(obsidian_content_folder):
    print(f"ERROR: Obsidian content folder not found at {obsidian_content_folder}")
    sys.exit(1)

if not os.path.exists(now_file):
    print(f"ERROR: now.md not found at {now_file}")
    sys.exit(1)

# Define the location for the human-readable heading (defaults to empty)
location = ""

try:
    # Read the content of now.md
    with open(now_file, "r", encoding="utf-8") as f:
        now_content = f.readlines()

    # Extract the frontmatter and the "place" variable (if present)
    in_frontmatter = True
    frontmatter_start = 0
    for i, line in enumerate(now_content):
        if line.strip() == "+++":  # This marks the start of frontmatter
            if frontmatter_start == 0:
                frontmatter_start = i + 1
            else:
                in_frontmatter = False
                break
        if in_frontmatter and line.strip().startswith("place ="):
            location = line.split("=")[1].strip().strip('"')

    # If "place" is not found, default to a fallback location
    if not location:
        location = "Hiding"

    # Get the current timestamp
    timestamp = datetime.now().strftime("%Y-%m-%d|%H:%M:%S")
    current_date = datetime.now().strftime("%Y-%m-%d")

    # Define the backup file path (only one backup file)
    backup_file = os.path.join(obsidian_content_folder, "now_backup.md")

    # Make a backup of now.md before making any changes
    shutil.copy(now_file, backup_file)
    print(f"Backup created at {backup_file}")

    # Open then.md, or create it if it doesn't exist
    if os.path.exists(then_file):
        with open(then_file, "r", encoding="utf-8") as f:
            then_content = f.readlines()
    else:
        then_content = []
        print(f"Creating new then.md at {then_file}")

    # Separate the front matter from the content of then.md
    frontmatter_end = 0
    frontmatter_count = 0
    then_log_position = 0
    for i, line in enumerate(then_content):
        if line.strip() == "+++":  # This marks the start of frontmatter
            frontmatter_count += 1
        if frontmatter_count == 2:  # We've found both "+++" markers
            frontmatter_end = i + 1
        if line.strip() == "---":
            then_log_position += 1
        if then_log_position == 1:
            break

    # Add a human-readable heading for the changes section
    history_entry = f"# <time>{timestamp}</time> in <place>{location}</place>\n"
    history_entry += "Back then, I was:\n"

    # Capture bullet points while preserving indentation
    for line in now_content:
        stripped = line.strip()
        # Check if line contains a bullet point (with or without indentation)
        if stripped.startswith("-"):
            # Preserve the original indentation
            if line.endswith("\n"):
                history_entry += line
            else:
                history_entry += line + "\n"

    history_entry += "\n"

    # Insert the new history entry after the front matter
    then_content.insert(frontmatter_end, history_entry)

    # Write updated content back to then.md
    with open(then_file, "w", encoding="utf-8") as f:
        f.writelines(then_content)

    print(f"Successfully updated {then_file} with changes from {current_date}")
    sys.exit(0)

except Exception as e:
    print(f"ERROR: Failed to process files: {e}")
    sys.exit(1)