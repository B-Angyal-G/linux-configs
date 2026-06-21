#!/bin/bash

# Csomagkezelő lekérdezése
pkg_manager=""
for pkg in zypper dnf apt pacman; do
    if type -p "$pkg" >/dev/null; then
		pkg_manager="$pkg"
		break
    fi
done

if [ -z "$pkg_manager" ]; then
    echo "Nincs felismerhető telepítőcsomag"
    exit 1
fi
echo "Felismert csomagkezelő: $pkg_manager"




# Eszenciális programok telepítése
echo "<=== Eszenciális csomagok telepítése (rendszerspecifikusan) ===>"
if [ "$pkg_manager" == "apt" ]; then
    # DEBIAN
    sudo apt update
    sudo apt install -y git vim ranger flatpak build-essential gdb cmake python3-pip python3-dev
    if apt-cache show python3-venv >/dev/null 2>&1; then
        sudo apt install -y python3-venv
    fi

elif [ "$pkg_manager" == "dnf" ]; then
    # FEDORA
    sudo dnf install -y git vim ranger flatpak gcc-c++ make cmake gdb python3-pip python3-devel

elif [ "$pkg_manager" == "zypper" ]; then
    # OPENSUSE
    sudo zypper install -y git-core vim ranger flatpak gcc-c++ make glibc-devel gdb cmake python3-pip python3-devel python3-virtualenv

elif [ "$pkg_manager" == "pacman" ]; then
    # CACHYOS (Arch Linux alapok)
    sudo pacman -Sy --noconfirm
    sudo pacman -S --noconfirm git vim ranger flatpak base-devel cmake gdb python-pip
fi




# Config file-ok beállítása
echo "<=== Saját konfigurációs file-ok letöltése és beállítása ===>"
echo "<=== Letöltés ===>"
mkdir -p ~/dat/linux
cd ~/dat/linux
if [[ -d "linux-configs" ]]; then
	mv linux-configs linux-configs-bak
fi
git clone https://github.com/B-Angyal-G/linux-configs

echo "<=== Beállítás ===>"
cp ~/dat/linux/linux-configs/bashrc.txt ~/.bashrc
cp ~/dat/linux/linux-configs/vimrc.txt ~/.vimrc
cp ~/dat/linux/linux-configs/inputrc ~/.inputrc
cp ~/dat/linux/linux-configs/dircolors.txt ~/.dircolors
cp ~/dat/linux/linux-configs/scripts/* ~/.scripts




# Egyéb programok telepítése egyesével
# --- Előkészület a Flatpak parancsokhoz
echo "<=== Flathub hozzáadása a flatpakhoz ===>"
sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

# --- Segédfüggvény
ask_and_install_flatpak() {
    local app_name="$1"
    local flatpak_id="$2"
    local confirm=""

    while [[ "${confirm,,}" != "n" && "${confirm,,}" != "y" ]]; do
        read -p "---> $app_name (y/n): " confirm
    done

    if [[ "${confirm,,}" == "y" ]]; then
        sudo flatpak install -y flathub "$flatpak_id"
    fi
}

echo "<=== Programok telepítése ===>"
ask_and_install_flatpak "Brave Browser" "com.brave.Browser"
ask_and_install_flatpak "OnlyOffice" "org.onlyoffice.desktopeditors"
ask_and_install_flatpak "VLC Media Player" "org.videolan.VLC"
ask_and_install_flatpak "Android Studio" "com.google.AndroidStudio"
ask_and_install_flatpak "Godot Engine" "org.godotengine.Godot"
ask_and_install_flatpak "Rider" "com.jetbrains.Rider"




gitmail=""
gitcomment=""
# Git beállítása
echo "<=== Git Configurálása ===>"
	git config --global user.name "B-Angyal-G"
	read -p "---> Git email cím: " gitmail
	git config --global user.email "$gitmail"

	read -p "---> Git kulcs komment: " gitcomment
	ssh-keygen -t ed25519 -C "$gitcomment" -f ~/.ssh/id_ed25519

	echo -e "\n\e[32m######################################################################\e[0m"
	echo -e "\e[32m### Az alábbi kulcs hozzáadása szükséges a GitHub-hoz (Settings) ###\e[0m"
	echo -e "\e[32m######################################################################\e[0m\n"
	cat ~/.ssh/id_ed25519.pub
	echo -e "\n\e[32m######################################################################\e[0m\n"

	cd ~/dat/linux/linux-configs
	git remote set-url origin git@github.com:B-Angyal-G/linux-configs.git
	cd - > /dev/null




#Lenovo "í" gomb
confirm=""
while [[ "${confirm,,}" != "n" && "${confirm,,}" != "y" ]]; do
	read -p "<=== LENOVO 'í' gomb engedélyezése (y/n): " confirm

	if [[ "${confirm,,}" == "y" ]]; then
		if [[ "$pkg_manager" == "dnf" ]]; then
			sudo dnf copr enable alternateved/keyd
		fi
		sudo $pkg_manager install -y keyd

		sudo mkdir -p /etc/keyd
		if [[ -f /etc/keyd/default.conf ]]; then
			if ! sudo grep -q "rightcontrol" /etc/keyd/default.conf; then
				sudo bash -c 'echo -e "[ids]\n0001:0001\n\n[main]\nrightcontrol = 102nd\n\n[altgr]\nrightcontrol =" >> /etc/keyd/default.conf'
			fi
		else
			sudo bash -c 'echo -e "[ids]\n0001:0001\n\n[main]\nrightcontrol = 102nd\n\n[altgr]\nrightcontrol =" > /etc/keyd/default.conf'
		fi
		sudo systemctl enable keyd --now
	fi
done
