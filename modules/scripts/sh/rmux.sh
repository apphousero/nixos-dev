set -e

if tmux ls >/dev/null 2>&1; then
    exec tmux a
fi

tmux new-session -d
tmux run-shell "$RESTORE_SCRIPT"
exec tmux attach
