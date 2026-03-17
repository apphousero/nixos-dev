#!/bin/sh

set -e

# Get current directory name and parent directory name
CWD=$(pwd)
CWD_NAME=$(basename "$CWD")
CWD_NAME=$(printf "%s" "$CWD_NAME" | cut -c1-16)
CWD_NAME=$(echo "$CWD_NAME" | tr -d '.')
PARENT_CWD=$(dirname "$CWD")
PARENT_CWD_NAME=$(basename "$PARENT_CWD")
PARENT_CWD_NAME=$(printf "%s" "$PARENT_CWD_NAME" | cut -c1-16)
PARENT_CWD_NAME=$(echo "$PARENT_CWD_NAME" | tr -d '.')

# Get hostname
HOST_NAME=$(hostname)

# Create session name in format "cwd (parent-cwd)"
SESSION_NAME="${CWD_NAME} (${HOST_NAME})"

# Check if tmux session already exists
if ! tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
    # neovim window
    tmux new-session -d -s "$SESSION_NAME" -n "vi ($HOST_NAME)" -c "$CWD"
    tmux send-keys -t "$SESSION_NAME:1" "echo 'neovim here'" C-m
    # git window
    tmux new-window -t "$SESSION_NAME:2" -n "vi2 ($HOST_NAME)" -c "$CWD"
    tmux send-keys -t "$SESSION_NAME:2" "echo 'neovim 2nd here'" C-m
    # run window
    tmux new-window -t "$SESSION_NAME:3" -n "run ($HOST_NAME)" -c "$CWD"
    tmux send-keys -t "$SESSION_NAME:3" "echo 'run stuff here'" C-m
    # nav window
    tmux new-window -t "$SESSION_NAME:4" -n "nav ($HOST_NAME)" -c "$CWD"
    tmux send-keys -t "$SESSION_NAME:4" "echo 'do your tree here'" C-m
    # docker window
    tmux new-window -t "$SESSION_NAME:5" -n "ssh ($HOST_NAME)" -c "$CWD"
    # ssh window
    tmux new-window -t "$SESSION_NAME:6" -n "cld ($HOST_NAME)" -c "$CWD"
    # logs window
    tmux new-window -t "$SESSION_NAME:7" -n "gmn ($HOST_NAME)" -c "$CWD"
    # other windows
    tmux new-window -t "$SESSION_NAME:8" -n "logs ($HOST_NAME)" -c "$CWD"
    tmux new-window -t "$SESSION_NAME:9" -n "sys ($HOST_NAME)" -c "$CWD"
    # Select window 1 (vi)
    tmux select-window -t "$SESSION_NAME:1"
fi

# Attach to session
tmux attach-session -t "$SESSION_NAME"
