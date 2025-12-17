# Getting Started
This is just a small recommended process for quickly setting up a system and
getting things working. Check out the official NixOS installation guide on the
[wiki](https://nixos.wiki/wiki/NixOS_Installation_Guide).

First thing you need to do is connect to the internet. `nmtui` is pre-installed
on the graphical ISO and what I prefer. On the minimal ISO, you need to use
`wpa_supplicant`:
- Run `wpa_passphrase ESSID | sudo tee /etc/wpa_suppicant.conf` where `ESSID` is
  the WiFi name.
- Enter the password.
- Run `systemctl restart wpa_supplicant`

## Partition and Format Drives
I'll make the following assumptions:
- 256 GB Drive at `/dev/sdX`
- 16 GB RAM

I won't know the specific partition names (e.g. `/dev/sdX1` being `boot`), so
I'll replace any mentions of the partitions with `/dev/root-partition`, for
example. Be sure to replace these paths with their appropriate paths on your
system.

Note that to support hibernation, swap is generally recommended to have a size
according to `(RAM size) + sqrt(RAM size)`.

Hence we can partition like so:

Partition | Size   | Filesystem | Notes
----------|--------|------------|----------
 Boot     |   5 GB | EFI        |
 Root     | 128 GB | btrfs      |
 Home     | 108 GB | btrfs      |
 Swap     |  20 GB | swap       | Optional

Partition with `cgdisk` or `fdisk`. Remember to use GPT as the partition scheme.

Format partitions:
```
$ mkfs.fat -c -F 32 -n BOOT /dev/boot-partition
$ mkfs.btrfs --verbose --label ROOT --compress zstd /dev/root-partition
$ mkfs.btrfs --verbose --label HOME --compress zstd /dev/home-partition
$ mkswap --check --label SWAP /dev/swap-partition
```

## Install
Mount and create directories:
```
$ mount /dev/root-partition /mnt
$ cd /mnt
$ mkdir boot
$ mount /dev/boot-partition /mnt/boot
$ mkdir -p etc/nixos
$ mkdir home
$ swapon --verbose --all
```

Now create the NixOS config...
```
$ nixos-generate-config --root /mnt
$ git clone -C etc/nixos path/to/repo/NixOS_Configs.git NixOS_Configs.git
```

...and link it to the system's config you desire by including it's module inside
`etc/nixos/configuration.nix` while commenting out or deleting all other options:
```
...
    imports = [
        ./hardware-configuration.nix
        ./NixOS_Configs.git/systems/Familiar.nix
    ];
...
```

The only options which should be left or uncommented in `etc/nixos/configuration.nix`
are `imports` and `system.stateVersion`.

Now you're ready to install nixos:
```
$ nixos-install --verbose
```
