# https://wiki.nixos.org/wiki/COSMIC

{ pkgs, ... }:

{
	# ----- Cosmic -----
	services = {
		displayManager.cosmic-greeter.enable = true;
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
		#bemenu #.......................................... Dynamic menu library and client program inspired by dmenu
		#bemoji #.......................................... Emoji picker with support for bemenu/wofi/rofi/dmenu and wayland/X11
		cosmic-ext-applet-caffeine #....................... Applet to prevent display from going to sleep
		cosmic-ext-applet-external-monitor-brightness #.... Applet to control the brightness of external monitors
		cosmic-ext-applet-privacy-indicator #.............. Detects Microphone and Camera usage, as well as Screen Sharing/Recording
		cosmic-ext-ctl #................................... CLI for COSMIC Desktop configuration management
		cosmic-ext-tweaks #................................ Tweaking tool for the COSMIC Desktop Environment
		#cosmic-reader #................................... PDF reader for the COSMIC Desktop Environment
		#cosmic-store #.................................... App Store for the COSMIC Desktop Environment
		qpwgraph #......................................... QT-based pipewire manager
		quick-webapps #.................................... Web App Manager for the COSMIC desktop
		#tasks #........................................... Simple task management application for the COSMIC desktop
		#tofi #............................................ Tiny dynamic menu for Wayland
		#wdisplays #....................................... Graphical application for configuring displays in Wayland compositors
		#wlr-randr #.......................................
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
