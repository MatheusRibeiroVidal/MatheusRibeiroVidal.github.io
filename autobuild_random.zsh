#!/bin/zsh
# Runs the auto-build once a day at a random time.
# launchd calls this every 15 minutes (see
# ~/Library/LaunchAgents/com.ribeirovidal.mrv-autobuild.plist). The first call
# of each day picks a random time inside the window; the first call after that
# time runs the auto-build. If the Mac was asleep, it runs on the next wake.

# Window for the random time, in hours (24h clock): start <= time < end
WINDOW_START=8
WINDOW_END=22

SCRIPT_DIR="${0:A:h}"
STATE_DIR="$HOME/.local/state/mrv-autobuild"
STATE_FILE="$STATE_DIR/state"

log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" }

mkdir -p "$STATE_DIR"

today="$(date +%F)"
now_min=$(( 10#$(date +%H) * 60 + 10#$(date +%M) ))

# State file holds: <date> <target minute of day> <done 0|1>
state_date="" target=0 done=0
[[ -f "$STATE_FILE" ]] && read -r state_date target done < "$STATE_FILE"

# New day: pick a random time inside the window
if [[ "$state_date" != "$today" ]]; then
    target=$(( WINDOW_START * 60 + RANDOM % ((WINDOW_END - WINDOW_START) * 60) ))
    done=0
    echo "$today $target $done" > "$STATE_FILE"
    log "Today's auto-build is scheduled for $(printf '%02d:%02d' $(( target / 60 )) $(( target % 60 )))"
fi

(( done )) && exit 0
(( now_min < target )) && exit 0

# Mark as done first, so a failing build isn't retried every 15 minutes
echo "$today $target 1" > "$STATE_FILE"
log "Starting auto-build"
exec "$SCRIPT_DIR/runwebsite.zsh" auto
