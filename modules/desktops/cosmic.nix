# https://wiki.nixos.org/wiki/COSMIC

{ config, pkgs, ... }:

{
	# ----- Cosmic -----
	services = {
		displayManager.cosmic-greeter.enable = true;
		desktopManager.cosmic.enable = true;
		system76-scheduler.enable = true;
	};
	
	
	# ~ Extra Packages ~
	# Want the cosmic clipboard applet to become packaged
	environment.systemPackages = with pkgs; [
		# ~ Apps ~
		#bemenu #................................................... Dynamic menu library and client program inspired by dmenu
		#bemoji #................................................... Emoji picker with support for bemenu/wofi/rofi/dmenu and wayland/X11
		cosmic-ext-applet-caffeine #................................ Applet to prevent display from going to sleep
		cosmic-ext-applet-external-monitor-brightness #............. Applet to control the brightness of external monitors
		cosmic-ext-applet-privacy-indicator #....................... Detects Microphone and Camera usage, as well as Screen Sharing/Recording
		cosmic-ext-applet-weather #................................. Simple weather info applet for COSMIC
		cosmic-ext-ctl #............................................ CLI for COSMIC Desktop configuration management
		cosmic-ext-tweaks #......................................... Tweaking tool for the COSMIC Desktop Environment
		cosmic-reader #............................................. PDF reader for the COSMIC Desktop Environment
		#cosmic-store #............................................. App Store for the COSMIC Desktop Environment
		qpwgraph #.................................................. QT-based pipewire manager
		quick-webapps #............................................. Web App Manager for the COSMIC desktop
		tasks #..................................................... Simple task management application for the COSMIC desktop
		#tofi #..................................................... Tiny dynamic menu for Wayland
		#wdisplays #................................................ Graphical application for configuring displays in Wayland compositors
		#wlr-randr #................................................
	];
}
