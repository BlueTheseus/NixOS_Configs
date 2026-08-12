# - variables
# 	- hostname
# 	- hostID
# - imports
# - boot
# - users

# Filesystem Recommendations:
# 	- BTRFS
# 	- Separate root and home partitions
# Swap:
# 	- Recommended size: (amount of RAM) + sqrt(amount of RAM)
{ config, pkgs, lib, ... }:
let
	HOSTNAME = "Shelby";
	HOSTID = "a66e5646"; # needed for zfs. generate with: head -c4 /dev/urandom | od -A none -t x4
	USER = "Eden";
	TIMEZONE = "America/Los_Angeles";
in {

	# ----- POWER BUTTON -----
	services.logind.settings.Login = {
		HandlePowerKey = "poweroff";
		PowerKeyIgnoreInhibited = "yes";
	};

	# ----- GNOME DESKTOP -----
	programs.dconf.profiles = {
		gdm.databases = [{
			settings = {
				"org/gnome/settings-daemon/plugins/power" = {
					power-button-action = "poweroff";
				};
			};
		}];
		user.databases = [ {
			settings = {
				"org/gnome/settings-daemon/plugins/power" = {
					power-button-action = "nothing";
				};
				"org/gnome/desktop/input-sources" = {
					xkb-options = [ "caps:escape" ];
				};
			};
		} ];
	};

	# ----- MOBILE DEVICES / IOS -----
	services.usbmuxd = { # IOS device connectivity
		enable = false;
		#package = pkgs.usbmuxd2;
	};

	# ----- FONTS -----
	fonts.packages = with pkgs; [
		#google-fonts #...... Font files available from Google Fonts
		#noto-fonts #........ Beautiful and free fonts for many languages
		#nerd-fonts._0xproto
		#nerd-fonts.adwaita-mono
		#nerd-fonts.blex-mono
		#nerd-fonts.comic-shanns-mono
		#nerd-fonts.im-writing
		#nerd-fonts.intone-mono
		#nerd-fonts.iosevka
		#nerd-fonts.iosevka-term
	];

	# ----- EXTRA SYSTEM PACKAGES -----
	environment.systemPackages = with pkgs; [
		# ~ Desktop ~
		#bluez #....................................... official linux bluetooth protocol stack
		#brave #........................................ browser
		discord
		firefox #..................................... browser
		#foot #......................................... wayland terminal
		#kdePackages.kcharselect #...................... Tool to select and copy special characters from all installed fonts
		#libnotify #.................................... a library that sends desktop notifications to a notification daemon
		#libreoffice
		#mpv #.......................................... video and music player
		#obsidian #..................................... notes
		#obs-studio
		#telegram-desktop
		#virtualbox #.................................. virtual machines
		#vlc #.......................................... media player
		#zathura #...................................... pdf/epub viewer
	];

	# ----- GAMING -----
	nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
		"steam"
		"steam-original"
		"steam-run"
	];
	programs.steam = {
		enable = true;
		remotePlay.openFirewall = false; # Open ports in the firewall for Steam Remote Play
		dedicatedServer.openFirewall = false; # Open ports in the firewall for Source Dedicated Server
		extraCompatPackages = with pkgs; [
			proton-ge-bin
		];
	};
}
