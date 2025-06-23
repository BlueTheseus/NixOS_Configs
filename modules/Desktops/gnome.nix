{ pkgs, ... }:

{
	imports = [ ./desktop-packages.nix ];

	# ----- X11 and Gnome -----
	services.xserver.enable = true;
	services.xserver.displayManager.gdm.enable = true;
	#services.xserver.displayManager.gdm.autoSuspend = false;  # Auto-suspend prevents connecting as a server
	services.xserver.desktopManager.gnome.enable = true;
	# The following steps may also be required to fully disable auto-suspend:
	# dconf write /org/gnome/settings-daemon/plugins/power/sleep-inactive-ac-timeout 0
	# dconf write /org/gnome/settings-daemon/plugins/power/sleep-inactive-battery-timeout 0
	# restart gdm (kill process or reboot)


	# ----- Extra Packages -----
	environment.systemPackages = with pkgs; [
		helvum #.... Graphical pipewire manager
		gnome-solanum
		# Gnome-Specific
		gnomeExtensions.appindicator  # extension for system tray icons
		gnomeExtensions.pop-shell
		gnomeExtensions.tailscale-status
	];

	# Exclude select default Gnome applications
	environment.gnome.excludePackages = (with pkgs; [
		gnome-connections
		#gnome-photos
		gnome-tour
		gedit  # graphical text editor
	]) ++ (with pkgs; [ #pkgs.gnome
		cheese  # webcam tool
		# gnome-calculator
		# gnome-calendar
		# gnome-characters
		# gnome-clocks
		# gnome-contacts
		# gnome-maps
		# gnome-music
		# gnome-system-monitor
		# gnome-terminal
		# gnome-weather
		epiphany  # web browser
		geary  # email reader
		# evince  # document viewer
		# totem  # video player
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
