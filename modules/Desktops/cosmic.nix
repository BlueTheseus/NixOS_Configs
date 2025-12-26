# https://wiki.nixos.org/wiki/COSMIC

{ config, pkgs, ... }:

let
	unstableTarball = fetchTarball https://github.com/NixOS/nixpkgs/archive/nixos-unstable.tar.gz;
in
{
	# ----- NixOS Unstable -----
	# Disable the stable channel version
	# https://github.com/NixOS/nixpkgs/tree/master/nixos/modules/services
	disabledModules = [
		"services/display-managers/cosmic-greeter.nix"
		"services/desktop-managers/cosmic.nix"
		"services/desktops/system76-scheduler.nix"
	];

	# Import from unstable
	imports = [
		(unstableTarball + "/nixos/modules/services/display-managers/cosmic-greeter.nix")
		(unstableTarball + "/nixos/modules/services/desktop-managers/cosmic.nix")
		(unstableTarball + "/nixos/modules/services/desktops/system76-scheduler.nix")
	];

	# Use packages from unstable
	nixpkgs.config = {
		packageOverrides = pkgs: {
			unstable = import unstableTarball {
				config = config.nixpkgs.config;
			};
		};
	};

	# ----- Cosmic -----
	services = {
		displayManager.cosmic-greeter = {
			enable = true;
			package = pkgs.unstable.cosmic-greeter;
		};
		desktopManager.cosmic.enable = true;
		system76-scheduler.enable = true;
	};
	
	
	# ----- QT Configuration -----
	#qt = {
	#	enable = true;
		#platformTheme = "gnome";
		#style = "adwaita-dark";
	#};
	
	# ----- PACKAGES -----
	#nixpkgs.config.packageOverrides = pkgs: { # Enable the Nix Users Repository
	#	nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/main.tar.gz") {
	#		inherit pkgs;
	#	};
	#};

	# ~ Extra Packages ~
	# Want the cosmic clipboard applet to become packaged
	environment.systemPackages = with pkgs; [
		# ~ System ~
		#unstable.cosmic-bg
		#unstable.cosmic-osd
		#unstable.cosmic-term
		#unstable.cosmic-idle
		#unstable.cosmic-edit
		#unstable.cosmic-comp
		#unstable.cosmic-randr
		#unstable.cosmic-panel
		#unstable.cosmic-icons
		#unstable.cosmic-files
		#unstable.cosmic-reader
		#unstable.cosmic-player
		#unstable.cosmic-session
		#unstable.cosmic-applets
		#unstable.cosmic-settings
		#unstable.cosmic-launcher
		#unstable.cosmic-protocols
		#unstable.cosmic-wallpapers
		#unstable.cosmic-screenshot
		#unstable.cosmic-notifications
		#unstable.cosmic-initial-setup
		#unstable.cosmic-settings-daemon
		#unstable.cosmic-workspaces-epoch
		#unstable.xdg-desktop-portal-cosmic

		# ~ Apps ~
		#bemenu #................................................... Dynamic menu library and client program inspired by dmenu
		#bemoji #................................................... Emoji picker with support for bemenu/wofi/rofi/dmenu and wayland/X11
		unstable.cosmic-ext-applet-caffeine #....................... Applet to prevent display from going to sleep
		unstable.cosmic-ext-applet-external-monitor-brightness #.... Applet to control the brightness of external monitors
		unstable.cosmic-ext-applet-privacy-indicator #.............. Detects Microphone and Camera usage, as well as Screen Sharing/Recording
		unstable.cosmic-ext-applet-weather #........................ Simple weather info applet for COSMIC
		unstable.cosmic-ext-ctl #................................... CLI for COSMIC Desktop configuration management
		unstable.cosmic-ext-tweaks #................................ Tweaking tool for the COSMIC Desktop Environment
		#cosmic-reader #............................................ PDF reader for the COSMIC Desktop Environment
		#cosmic-store #............................................. App Store for the COSMIC Desktop Environment
		qpwgraph #.................................................. QT-based pipewire manager
		unstable.quick-webapps #.................................... Web App Manager for the COSMIC desktop
		#tasks #.................................................... Simple task management application for the COSMIC desktop
		#tofi #..................................................... Tiny dynamic menu for Wayland
		#wdisplays #................................................ Graphical application for configuring displays in Wayland compositors
		#wlr-randr #................................................
	];
	
	# ~ Exclude Packages ~
	#environment.cosmic.excludePackages = with pkgs; [
	#	cosmic-edit
	#];

	# ----- Flatpak -----
	#services.flatpak.enable = true;
	#systemd.services.flatpak-repo = {
	#	wantedBy = [ "multi-user.target" ];
	#	path = [ pkgs.flatpak ];
	#	script = ''
	#		flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
	#		flatpak remote-add --if-not-exists --user cosmic https://apt.pop-os.org/cosmic/cosmic.flatpakrepo
	#	'';
	#};
}
