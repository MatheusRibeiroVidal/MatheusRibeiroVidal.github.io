import os
from pathlib import Path

# -----------------------------
# LOAD PATHS FROM CONFIG
# -----------------------------
CONFIG_FILE = Path(__file__).parent / "paths.config"

paths = {}
with open(CONFIG_FILE, "r", encoding="utf-8") as f:
    for line in f:
        line = line.strip()
        if not line or line.startswith("#"):
            continue
        if "=" in line:
            key, val = line.split("=", 1)
            paths[key.strip()] = val.strip()

CHARMERA_FOLDER = Path(paths.get("CHARMERA_GALLERY_FOLDER", ""))
INDEX_MD = Path(paths.get("CHARMERA_INDEX_MD", ""))

if not CHARMERA_FOLDER.exists():
    print(f"ERROR: Charmera folder not found at {CHARMERA_FOLDER}")
    exit(1)

if not INDEX_MD.parent.exists():
    INDEX_MD.parent.mkdir(parents=True, exist_ok=True)

# -----------------------------
# SCAN IMAGES
# -----------------------------
image_files = sorted([f for f in CHARMERA_FOLDER.iterdir() if f.suffix.lower() in [".jpg", ".jpeg", ".png", ".gif"]])
relative_paths = [f"/charmera/gallery/charmera/{f.name}" for f in image_files]

# -----------------------------
# WRITE _index.md
# -----------------------------
front_matter = [
    "+++",
    'title = "Charmera Gallery"',
    'description = "A selection of photos from my Kodak Charmera."',
    'template = "gallery.html"',
    "",
    "[extra]",
    "images = [",
]

for p in relative_paths:
    front_matter.append(f'    "{p}",')

front_matter.append("]")
front_matter.append("+++\n")

with open(INDEX_MD, "w", encoding="utf-8") as f:
    f.write("\n".join(front_matter))

print(f"_index.md updated with {len(relative_paths)} images at {INDEX_MD}")
