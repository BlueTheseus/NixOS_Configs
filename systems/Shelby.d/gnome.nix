{ pkgs, ... }:

{
	# ----- Gnome -----
	services.displayManager.gdm = {
		enable = true;
		autoSuspend = false; # Auto-suspend prevents connecting as a server
	};
	services.desktopManager.gnome.enable = true;

	# ----- Extra Packages -----
	environment.systemPackages = with pkgs; [
		#helvum #............................. Graphical pipewire manager
		crosspipe #........................... Graphical pipewire manager
		gnome-solanum
		# Gnome-Specific
		gnomeExtensions.appindicator  #....... extension for system tray icons
		#gnomeExtensions.pop-shell
		gnomeExtensions.tailscale-status
	];

	# Exclude select default Gnome applications
	environment.gnome.excludePackages = (with pkgs; [
		#gnome-connections
		#gnome-photos
		gnome-tour
		gedit  # graphical text editor
	]) ++ (with pkgs; [ #pkgs.gnome
		cheese  # webcam tool
		gnome-calculator
		gnome-calendar
		gnome-characters
		gnome-clocks
		gnome-contacts
		gnome-maps
		gnome-music
		gnome-system-monitor
		gnome-terminal
		gnome-weather
		epiphany  # web browser
		geary  # email reader
		evince  # document viewer
		totem  # video player
		simple-scan  # document scanner utility
		tali  # poker game
		iagno  # go game
		hitori  # sudoku game
		atomix  # puzzle game
	]);
		# text editor
		# help
		# disk usage analyzer
		# disks
		# image viewer
		# archive manager
		# passwords and keys
		# logs
		# fonts
		# console

	# ----- QT Applications -----
	qt = {
		enable = true;
		platformTheme = "gnome";
		style = "adwaita-dark";
	};

	# ----- Gnome Extensions -----
	services.udev.packages = with pkgs; [
		gnome-settings-daemon  # used for system tray icons #gnome.gnome-settings-daemon
	];
}
