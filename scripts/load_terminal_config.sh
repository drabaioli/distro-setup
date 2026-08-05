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

# Auto-start tmux for interactive terminals (quoted heredoc: keep $vars literal).
# Skip if the block is already there, so re-running this script does not stack up
# copies in ~/.bashrc.
if grep -q "Auto-start tmux (managed by distro-setup) BEGIN" ~/.bashrc 2>/dev/null; then
    echo "Tmux auto-start already present in ~/.bashrc, skipping."
else
cat <<'TMUX_EOT' >> ~/.bashrc

# --- Auto-start tmux (managed by distro-setup) BEGIN ---
# Launch tmux for interactive gnome-terminal shells. Each terminal window gets
# its own independent session. Escape hatch: run `NO_TMUX=1 <terminal>` or set
# NO_TMUX=1 to get a plain bash shell without tmux.
#
# `&& exit` rather than `exec tmux`: if tmux fails to start (broken ~/.tmux.conf,
# snap mid-refresh) exec would already have replaced this shell, so the window
# would just close with no shell left to fix it from. This way a failure drops
# through to a plain bash prompt instead.
if command -v tmux &>/dev/null && [ -z "$TMUX" ] && [ -n "$PS1" ] && [ -z "$NO_TMUX" ]; then
    tmux new-session && exit
fi
# --- Auto-start tmux END ---
TMUX_EOT
fi

echo "Terminal configuration loaded successfully!"
