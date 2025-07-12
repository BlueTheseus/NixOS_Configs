{ config, pkgs, ... };
{
	# ----- PACKAGES -----
	nixpkgs.config.allowUnfree = true;
	environment.systemPackages = with pkgs; [
		# ~ Encryption ~
		#gpg-tui #.......... Terminal user interface for GnuPG

		# ~ Info ~
		#bunnyfetch
		exiftool #.......... file metadata
		fastfetch
		mediainfo
		#neofetch
		#starfetch
		#uwufetch

		# ~ Manuals and Documentation ~
		man-pages #......... Linux Man-Pages Project -- a set of documentation of the Linux programming API -- check section 3
		man-pages-posix

		# ~ Networking ~
		bluez #............. official linux bluetooth protocol stack
		cifs-utils #........ samba
		curl
		dnsutils
		#spotdl
		wget
		yt-dlp

                # ~ Utilities ~
		bat #............... pretty cat for the terminal
		#borgbackup #....... Deduplicating archiver with compression and encryption
		cbonsai #........... screensaver
		#cope #............. A colourful wrapper for terminal programs
		ffmpeg
		fzf
		#glow #............. cli markdown renderer
		libnotify #......... notify-send
		#mtm #.............. Perhaps the smallest useful terminal multiplexer in the world
		p7zip #............. zip utility
		#pistol #........... file previewer
		#qemu #.............. Generic and open source machine emulator and virtualizer
		rclone #............ Like rsync but for cloud storage services
		#restic #........... A backup program that is fast, efficient, and secure
		rsync
		trash-cli #......... trash can for the commandline. Don't accidentally rm something important ;)
		unipicker #......... CLI utility for searching unicode characters by description and optionally copying them to clipboard
		#ventoy #........... live-usb

                # ~ Productivity ~
		#abduco #........... Allows programs to be run independently from its controlling terminal
		#aerc #............. Email client for your terminal
		#dvtm #............. Dynamic virtual terminal manager
		lf #................ file manager
		#neomutt #.......... Small but very powerful text-based mail client
		#nnn #.............. minimal file manager
		tmux #.............. widely-used terminal multiplexer
		w3m #............... Text-mode web browser
		#xplr #............. Hackable, minimal, fast TUI file explore
		#zellij #........... user-friendly terminal multiplexer
	];

	# ----- MANUALS -----
	documentation
		dev.enable = true;
		#man = {
			# In order to enable to mandoc man-db has to be disabled.
			#man-db.enable = false;
			#mandoc.enable = true;
		#};
	};

	# ----- FONTS -----
	fonts.packages = with pkgs; [
		cozette #........... A bitmap programming font optimized for coziness
		dina-font #......... A monospace bitmap font aimed at programmers
		#google-fonts #...... Font files available from Google Fonts
		#noto-fonts #........ Beautiful and free fonts for many languages
		scientifica #....... Tall and condensed bitmap font for geeks
		siji #.............. An iconic bitmap font based on Stlarch with additional glyphs
		spleen #............ Monospaced bitmap fonts
		tamsyn #............ A monospace bitmap font aimed at programmers
		tamzen #............ Bitmapped programming font based on Tamsyn
		tewi-font #......... A nice bitmap font, readable even at small sizes
		ucs-fonts #......... Unicode bitmap fonts
		unifont #........... GNU's Unicode font for Base Multilingual Plane
		unscii #............ Bitmapped character-art-friendly Unicode fonts

		nerd-fonts._0xproto
		nerd-fonts.adwaita-mono
		nerd-fonts.blex-mono
		nerd-fonts.comic-shanns-mono
		nerd-fonts.im-writing
		nerd-fonts.intone-mono
		nerd-fonts.iosevka
		nerd-fonts.iosevka-term
	];
}
