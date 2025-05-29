{ config, pkgs, lib, ... }:

{
  environment.systemPackages = with pkgs; [
    anki #.................... flashcards
    #arduino #................ arduino IDE
    aseprite #................ pixelart and animation editor
    blender #................. 3d modeling
    brave #................... browser
    discord
    # firefox #............... browser
    #flatpak
    #floorp #................. firefox-based browser
    gimp
    jellyfin-media-player
    kdePackages.kcharselect #. Tool to select and copy special characters from all installed fonts
    kicad #................... open source electronics design automation suite
    libnotify #............... a library that sends desktop notifications to a notification daemon
    libreoffice
    mpv #..................... video and music player
    obsidian #................ notes
    obs-studio
    prismlauncher #........... minecraft
    #protonvpn-gui
    slack
    telegram-desktop
   #tg #...................... terminal client for telegram
    (tic-80.override { withPro = true; } )
    #thunderbird #............. email client
    #tor-browser-bundle-bin
    #virtualbox #.............. virtual machines
    vlc #..................... media player
    wezterm #................. terminal emulator
    zathura #................. pdf/epub viewer
  ];

  # ----- GAMING -----
  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
    "steam"
    "steam-original"
    "steam-run"
    (retroarch.override {
      cores = with libretro; [
        melonds
	mgba
      ];
    })
  ];
  programs.steam = {
  	enable = true;
	remotePlay.openFirewall = false; # Open ports in the firewall for Steam Remote Play
	dedicatedServer.openFirewall = false; # Open ports in the firewall for Source Dedicated Server
  };

  # ----- VirtualBox -----
  virtualisation.virtualbox = {
    host = {
      enable = true;
      enableExtensionPack = true;
    };
    #guest = {
      #enable = true;
      #dragAndDrop = true;
    #};
  };
  users.extraGroups.vboxusers.members = [ "Xenia" ];

  # ----- Sound -----
  # ALSA
  #sound.enable = false;
  hardware.pulseaudio.enable = false;
  # Pipewire
  #security.rkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  # ----- Automatic Login -----
  # services.xserver.displayManager.autoLogin.enable = true;
  # services.xserver.displayManager.autoLogin.user = "account";
  # Auto-Login workaround as of 2023:
  # systemd.services."getty@tty1".enable = false;
  # systemd.services."autovt@tty1".enable = false;


  # ----- Touchpad -----
  # Enable touchpad support (enabled default in most desktopManager).
  services.libinput.enable = true;


  # ----- Printing -----
  # Enable CUPS to print documents.
  services.printing.enable = true;
}
