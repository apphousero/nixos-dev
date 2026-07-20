#!/bin/sh

cd "$(dirname "$0")"
echo "Running update-pi.sh..."
./update-pi.sh
echo "Running update-pi-acp.sh..."
./update-pi-acp.sh
echo "Running update-claude-agent-acp.sh..."
./update-claude-agent-acp.sh