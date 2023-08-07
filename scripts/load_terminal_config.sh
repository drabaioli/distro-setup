#!/bin/bash

cat ../scripts/gnome-terminal-config.dconf | dconf load /org/gnome/terminal/

cat <<EOT >> ~/.bashrc

### Diego
# Git branch on prompt
parse_git_branch() {
     git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1) /'
}
export PS1='\${debian_chroot:+(\$debian_chroot)}\[\e[00;31m\]\u@\h\[\e[00m\] : \[\e[01;34m\]\w\[\e[00m\] \[\e[00;31m\]\$(parse_git_branch)\[\e[00m\]\$ '
EOT
