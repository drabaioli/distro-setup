# Distro Setup

Scripts and config required for setting up my workspace. It's a combination of gnome-terminal and vim configuration and basic apt packages.

# Run

Launch the `./setup.sh` script as your user, not root. This will setup (my):
- basic apt packages
- gnome terminal shortcuts
- gnome terminal colors
- terminal prompt
- vim configuration

# Generate terminal configuration

On a pre-configured gnome-terminal you can use the `./scripts/generate_terminal_config.sh` script to generate a dump of the configuration to be imported into another machine.
