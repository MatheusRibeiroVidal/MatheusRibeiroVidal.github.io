#!/bin/zsh
# Interactive launcher for all website operations.
#   ./runwebsite.zsh        Show the menu
#   ./runwebsite.zsh auto   Scheduler shortcut: run the auto-build directly

SCRIPT_DIR="${0:A:h}"
BUILDER="$SCRIPT_DIR/builderserver.zsh"

# ===== Scheduler shortcut =====
if [[ "$1" == "auto" ]]; then
    exec "$BUILDER" -auto
fi

while true; do
    clear
    echo "================================"
    echo "   Personal Website Launcher"
    echo "================================"
    echo
    echo "1. Serve (local preview)"
    echo "2. Build (build + manual commit in Github Desktop)"
    echo "3. Auto-build (build + auto-commit)"
    echo
    echo "0. Exit"
    echo
    read "choice?Choose an option: "

    case "$choice" in
        1) exec "$BUILDER" -serve ;;
        2) exec "$BUILDER" -build ;;
        3) exec "$BUILDER" -auto ;;
        0) exit 0 ;;
        *)
            echo "Invalid choice. Press any key to try again..."
            read -k 1 -s
            ;;
    esac
done
