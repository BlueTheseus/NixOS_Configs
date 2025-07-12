# NixOS Configurations
Here are the configurations I use for NixOS on my various machines.

The main files for any given system live here in this directory. I like being able to make any system do anything else
if needed, so services, desktops, and such are their own modules able to be included with any config.

# Use
My current workflow is cloning this repo to have a local copy, and then copying the files I use for the system to
`/etc/nixos/` and including them inside `configuration.nix`. This way I can `git pull` changes to the local repo and
only copy whatever changes I need over without hassling with git conflicts for different machines.

# Organization
- `systems/`: configuration files for specific systems
- `modules/`: template configuration files
- `hardware/`: hardware configurations for various machines
