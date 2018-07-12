#!/bin/bash


execute () {
	echo "$ $*"
	OUTPUT=$($@ 2>&1)
	if [ $? -ne 0 ]; then
        echo "$OUTPUT"
        echo ""
        echo "Failed to Execute $*" >&2
        exit 1
    fi
}

execute sudo apt-get install libboost-all-dev curl -y

# Install code editor of your choice
if [[ ! -n $CIINSTALL ]]; then
    read -p "Download and Install VS Code / Atom / Sublime. Press q to skip this. Default is VS Code [v/a/s/q]: " tempvar
fi
tempvar=${tempvar:-v}

if [ "$tempvar" = "v" ]; then
    sudo sh -c 'echo "deb [arch=amd64] http://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'
    curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
    execute sudo mv microsoft.gpg /etc/apt/trusted.gpg.d/microsoft.gpg
    execute sudo apt-get update
    execute sudo apt-get install code -y # or code-insiders
elif [ "$tempvar" = "a" ]; then
    execute sudo add-apt-repository ppa:webupd8team/atom
    execute sudo apt update; execute sudo apt install atom -y
elif [ "$tempvar" = "s" ]; then
    execute sudo add-apt-repository ppa:webupd8team/sublime-text-3
    execute sudo apt-get update
    execute sudo apt-get install sublime-text-installer -y
elif [ "$tempvar" = "q" ];then
    echo "Skipping this step"
fi

# Recommended libraries for Nvidia CUDA
execute sudo apt-get install libglu1-mesa libxi-dev libxmu-dev libglu1-mesa-dev libx11-dev -y


# General Software from now on

if which nautilus > /dev/null; then
    execute sudo apt-get install nautilus-dropbox -y
elif which caja > /dev/null; then
    execute sudo apt-get install caja-dropbox -y
fi

# TLP manager 
execute sudo add-apt-repository ppa:linrunner/tlp -y
execute sudo apt-get update
execute sudo apt-get install tlp tlp-rdw -y
sudo tlp start

# Multiload and other sensor applets
execute sudo apt-get install lm-sensors
execute sudo apt-add-repository ppa:sneetsher/copies -y
execute sudo apt update 
execute sudo apt install indicator-sensors indicator-multiload -y
execute sudo apt-add-repository -r ppa:sneetsher/copies -y
execute sudo apt update

execute sudo apt-get install redshift redshift-gtk shutter -y

mkdir -p ~/.config/autostart 
cp ./config_files/indicator-multiload.desktop ~/.config/autostart
cp ./config_files/indicator-sensors.desktop ~/.config/autostart
cp ./config_files/tilda.desktop ~/.config/autostart
cp ./config_files/redshift-gtk.desktop ~/.config/autostart

execute sudo apt-get install htop gparted task expect -y

# Boot repair
execute sudo add-apt-repository ppa:yannubuntu/boot-repair -y
execute sudo apt-get update
execute sudo apt-get install -y boot-repair

# Installation of Docker Community Edition
execute wget get.docker.com -O dockerInstall.sh
execute chmod +x dockerInstall.sh
execute ./dockerInstall.sh
execute rm dockerInstall.sh
# Adds user to the `docker` group so that docker commands can be run without sudo
execute sudo usermod -aG docker ${USER}

# Grub customization
execute sudo add-apt-repository ppa:danielrichter2007/grub-customizer -y
execute sudo apt-get update
execute sudo apt-get install grub-customizer -y

# Keepass 2
execute sudo apt-add-repository ppa:jtaylor/keepass -y
execute sudo apt-get update -y
execute sudo apt-get install xdotool keepass2 -y

# Skype
execute wget https://go.skype.com/skypeforlinux-64.deb
execute sudo dpkg -i skypeforlinux-64.deb
execute rm skypeforlinux-64.deb

execute sudo apt-get install vlc -y

# Browsers
wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add - 
sudo sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list'
execute sudo apt-get update  -y
execute sudo apt-get install google-chrome-stable -y
#execute sudo apt-get install chromium-browser -y
execute sudo apt-get install adobe-flashplugin -y
execute sudo apt-get install firefox -y
# Install tor
execute sudo add-apt-repository ppa:webupd8team/tor-browser -y
execute sudo apt-get update -y
execute sudo apt-get install tor-browser -y
# Install I2P
execute sudo apt-add-repository ppa:i2p-maintainers/i2p -y
execute sudo apt-get update -y
execute sudo apt-get install i2p -y

# Franz
franz_base_web=https://github.com/meetfranz/franz/releases/
latest_franz=$(wget -q -O - $franz_base_web index.html | grep ".deb" | head -n 1 | cut -d \" -f 2)
execute wget https://github.com/$latest_franz
execute sudo apt-get install gnome-keyring
sudo dpkg -i *.deb
execute sudo apt-get install -f
execute rm -rf *.deb

echo "Script finished"
if [[ ! -n $CIINSTALL ]]; then
    su - ${USER}  # For docker
fi