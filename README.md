# OI-Lab Lite

Extra configuration files for school labs in Mogi das Cruzes, SP, Brazil (including ProInfo multi-seat workstations)

# System requirements

* Separate 1GB partition for /boot, formatted with ext2 filesystem.
* bindfs
* curl
* hxtools
* numlockx (for LightDM only)
* pam_mount (Debian package: libpam-mount)
* xdg-user-dirs-gtk
* xf86-video-siliconmotion (Debian package: xserver-xorg-video-siliconmotion)

# Installation steps

1. Clone this repository.
2. Run `sudo install.sh`.
3. If you want to create freeze users, run `sudo oi-lab-lite-freeze-create-users`.
4. If you have trouble with "rainbow bug" in your SM501 video card, run `sudo userful-rescue-enable`.
