#!/usr/bin/env bash

firstUser=$(grep "1000" /etc/passwd | cut -f 1 -d :)
flaggie sys-apps/busybox -static
flaggie virtual/imagemagick-0 +png

echo "[dantrell-gnome]

# Dantrell B.'s Gentoo Overlay for GNOME (generic)
# Maintainer: Dantrell B. (email: see CONTRIBUTING.md in main GitHub project)
# Homepage: https://github.com/dantrell/gentoo-project-gnome-without-systemd

location = /usr/local/portage/dantrell-gnome
sync-type = git
sync-uri = https://github.com/dantrell/gentoo-overlay-dantrell-gnome.git
priority = 150
auto-sync = yes" > /etc/portage/repos.conf/dantrell-gnome.conf

isInstalled "dev-vcs/git"

emaint sync -a

# Profile selection
printf "\n"
printf "* Listing profiles... \n"
eselect profile list
printf "\n"
printf "Which profile would you like? Type a number: \n"
read -r inputNumber
eselect profile set "$inputNumber"
env-update && source /etc/profile && export PS1="(chroot) $PS1" 

printf "\n"
echo "* Setting global USE flags in make.conf"
echo " " >> /etc/portage/make.conf
echo "# Global USE flag declaration" >> /etc/portage/make.conf
echo "USE=\"X dbus jpeg lock session startup-notification udev gnome -systemd -minimal alsa pam tcpd ssl\"" >> /etc/portage/make.conf

printf "\n"
echo "* Installing Gnome desktop environment.."
emerge --deep --with-bdeps=y --changed-use --update -q --verbose @world
emerge -q --keep-going gnome-base/gnome

printf "\n"
echo "* Changing default display manager to GDM"
sed -i 's/xdm/gdm/g' /etc/conf.d/xdm

printf "\n"
printf "* Adding startup items to OpenRC for boot.. \n"
rc-update add acpid default
rc-update add NetworkManager default
rc-update del dhcpcd default

usermod -aG plugdev "$firstUser"