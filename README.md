# Distro Setup

Scripts and config required for setting up my workspace. It's a combination of gnome-terminal and vim configuration and basic apt packages.
Taking inspiration from [pixegami/terminal-profile](https://github.com/pixegami/terminal-profile)

## Terminal

![term](./img/terminal.png)

## Vim

![vim](./img/vim_statusline.png)

# Run

Launch the `./setup.sh` script as your user, not root. This will setup (my):
- basic apt packages
- gnome terminal shortcuts
- gnome terminal colors
- bash prompt
- vim configuration

# Online execution

Since the setup is happening on a clean machine (where git is not installed), you can run the following command to have it all done in one line:

```
bash <(wget -qO- https://raw.githubusercontent.com/drabaioli/distro-setup/main/online_setup.sh)
```

# Generate terminal configuration

On a pre-configured gnome-terminal you can use the `./scripts/generate_terminal_config.sh` script to generate a dump of the configuration to be imported into another machine.

# Vim statusline and bash prompt

This is achieved thgough some simple confivuration. Powerline was not used.
