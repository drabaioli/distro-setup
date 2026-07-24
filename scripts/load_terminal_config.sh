#!/bin/bash

# Move to the dir where this script is
base_path=$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")
cd "$base_path"

cat ../data/gnome-terminal-config.dconf | dconf load /org/gnome/terminal/

cp ../data/ps1 ~/.ps1

cat <<EOT >> ~/.bashrc

# DIEGO

# Customize prompt
source ~/.ps1

# Use Vim as editor in git
export VISUAL=vim
export EDITOR="$VISUAL"
EOT

# Auto-start tmux for interactive terminals (quoted heredoc: keep $vars literal)
cat <<'TMUX_EOT' >> ~/.bashrc

# --- Auto-start tmux (managed by distro-setup) BEGIN ---
# Launch tmux for interactive gnome-terminal shells. Each terminal window gets
# its own independent session. Escape hatch: run `NO_TMUX=1 <terminal>` or set
# NO_TMUX=1 to get a plain bash shell without tmux.
if command -v tmux &>/dev/null && [ -z "$TMUX" ] && [ -n "$PS1" ] && [ -z "$NO_TMUX" ]; then
    exec tmux new-session
fi
# --- Auto-start tmux END ---
TMUX_EOT

echo "Terminal configuration loaded successfully!"
