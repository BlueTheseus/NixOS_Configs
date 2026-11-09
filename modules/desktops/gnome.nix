{ pkgs, ... }:

{
	# ----- X11 and Gnome -----
	#services.xserver.enable = true;
	services.displayManager.gdm = {
		enable = true;
		#autoSuspend = false; # Auto-suspend prevents connecting as a server
	};
	services.desktopManager.gnome.enable = true;

	# The following steps may also be required to fully disable auto-suspend:
	# dconf write /org/gnome/settings-daemon/plugins/power/sleep-inactive-ac-timeout 0
	# dconf write /org/gnome/settings-daemon/plugins/power/sleep-inactive-battery-timeout 0
	# restart gdm (kill process or reboot)


	#services.gnome = {
		#core-apps.enable = false;
		#core-developer-tools.enable = false;
		#games.enable = false;
	#};

	# ----- Remote Desktop -----
	#services.gnome.gnome-remote-desktop.enable = true;

	# Ensure service starts automatically at boot so the settings panel appears
	#systemd.services.gnome-remote-desktop = {
	#	wantedBy = [ "graphical.target" ];
	#};

	# Disable autologin to avoid session conflicts
	#services.displayManager.autoLogin.enable = false;
	#services.getty.autologinUser = null;

	# Prevent automatic suspend
	#systemd.targets.sleep.enable = false;
	#systemd.targets.suspend.enable = false;
	#systemd.targets.hibernate.enable = false;
	#systemd.targets.hybrid-sleep.enable = false;


	# ----- Extra Packages -----
	environment.systemPackages = with pkgs; [
		#helvum #............................. Graphical pipewire manager
		crosspipe #........................... Graphical pipewire manager
		gnome-solanum
		# Gnome-Specific
		gnomeExtensions.appindicator  #....... extension for system tray icons
		gnomeExtensions.pop-shell
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
