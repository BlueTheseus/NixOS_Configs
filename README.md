# NixOS Configurations
Here are the configurations I use for NixOS on my various machines.

The main files for any given system live their respective directory. I like
being able to make any system do anything else if needed, so services, desktops,
hardware, and such are their own nix modules able to be included with or used as
a template for any config.

# Use
As root, clone the repo to `/etc/nixos/`. This way the system configuration can
only be managed as root and pulls from upstream rather than trusting any users.

In `/etc/nixos/configuration.nix`, import the respective configuration from
`systems/` you wish to use.

# Organization
- `systems/`: Configuration files for specific systems.
- `modules/`: General configuration files for services and desktops.
- `hardware/`: Hardware configurations for various machines.

Note that the hardware configurations are kept separate from the system
configurations so that any system can be easily paired with any hardware.

# Getting Started
You can read `Getting_Started.md` for a small guide to quickly get a system up
and running. Be sure to consult the official NixOS wiki too though.
