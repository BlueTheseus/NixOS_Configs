# https://wiki.nixos.org/wiki/COSMIC

{ pkgs, ... }:

{
	# ----- Cosmic -----
	services = {
		displayManager.cosmic-greeter.enable = true;
		desktopManager.cosmic.enable = true;
		system76-scheduler.enable = true;
	};
	
	
	# ----- QT CONFIGURATION -----
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
	environment.systemPackages = with pkgs; [
		#bemenu #............................. Dynamic menu library and client program inspired by dmenu
		#bemoji #............................. Emoji picker with support for bemenu/wofi/rofi/dmenu and wayland/X11
		qpwgraph #............................ QT-based pipewire manager
		#tofi #............................... Tiny dynamic menu for Wayland
	];
	
	# ~ Exclude Packages ~
	#environment.cosmic.excludePackages = with pkgs; [
	#	cosmic-edit
	#];
}
