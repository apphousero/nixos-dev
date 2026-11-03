#!/bin/sh

set -e

# Get current directory name
CWD=$(pwd)
CWD_NAME=$(basename "$CWD")
CWD_NAME=$(printf "%s" "$CWD_NAME" | cut -c1-16)
CWD_NAME=$(printf "%s" "$CWD_NAME" | tr -d '.:')

# Get hostname
HOST_NAME=$(hostname | tr -d '.:')

# Create session name in format "<cwd>(<hostname>)"
SESSION_NAME="${CWD_NAME}(${HOST_NAME})"

# Check if tmux session already exists
if ! tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
    # neovim window
    tmux new-session -d -s "$SESSION_NAME" -n "vi" -c "$CWD"
    tmux send-keys -t "$SESSION_NAME:1" "echo 'neovim here'" C-m
    # second neovim window
    tmux new-window -t "$SESSION_NAME:2" -n "vi2" -c "$CWD"
    tmux send-keys -t "$SESSION_NAME:2" "echo 'neovim 2nd here'" C-m
    # run window (split)
    tmux new-window -t "$SESSION_NAME:3" -n "run" -c "$CWD"
    tmux split-window -t "$SESSION_NAME:3" -h -c "$CWD"
    # nav window (split)
    tmux new-window -t "$SESSION_NAME:4" -n "nav" -c "$CWD"
    tmux split-window -t "$SESSION_NAME:4" -h -c "$CWD"
    # ssh window
    tmux new-window -t "$SESSION_NAME:5" -n "ssh" -c "$CWD"
    # claude window
    tmux new-window -t "$SESSION_NAME:6" -n "cld" -c "$CWD"
    # pi window
    tmux new-window -t "$SESSION_NAME:7" -n "pi" -c "$CWD"
    # mst window
    tmux new-window -t "$SESSION_NAME:8" -n "mst" -c "$CWD"
    # sys window
    tmux new-window -t "$SESSION_NAME:9" -n "sys" -c "$CWD"
    # Select window 1 (vi)
    tmux select-window -t "$SESSION_NAME:1"
fi

# Attach to session
if [ -n "$TMUX" ]; then
    exec tmux switch-client -t "$SESSION_NAME"
else
    exec tmux attach-session -t "$SESSION_NAME"
fi
