#!/bin/sh
set -eu

cd "$(dirname "$0")"
echo "Running update-pi-acp.sh..."
./update-pi-acp.sh
echo "Running update-claude-agent-acp.sh..."
./update-claude-agent-acp.sh
echo "Running update-aoaoe.sh..."
./update-aoaoe.sh
