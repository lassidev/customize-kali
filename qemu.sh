#!/usr/bin/zsh

if [ "$EUID" == 0 ]
  then echo "Please don't run me as root"
  exit 1
fi

cat << "EOF"

oooo                               o8o         .oooooo.       oooo                  oooo   o8o  
`888                               `"'        d'     `b       `888                  `888   `"'  
 888   .oooo.    .oooo.o  .oooo.o oooo       d' .d"bd  8       888  oooo   .oooo.    888  oooo  
 888  `P  )88b  d88(  "8 d88(  "8 `888       8  8. 8  .d       888 .8P'   `P  )88b   888  `888  
 888   .oP"888  `"Y88b.  `"Y88b.   888       Y.  YoP"b'        888888.     .oP"888   888   888  
 888  d8(  888  o.  )88b o.  )88b  888        8.      .8       888 `88b.  d8(  888   888   888  
o888o `Y888""8o 8""888P' 8""888P' o888o        YooooooP       o888o o888o `Y888""8o o888o o888o 
                                                                                                
                                                                                                                                                                                      
EOF

echo 'Stupid GUIs!'

echo 'Set the power management as you like and close the window'
xfce4-power-manager-settings 2>/dev/null

echo 'Set Window Buttons as you like and close the window'
xfce4-panel -p


echo 'Opening Firefox, please install the plugins in tabs and close them'
firefox -new-tab -url https://addons.mozilla.org/fi/firefox/addon/pwnfox/ -new-tab -url https://addons.mozilla.org/fi/firefox/addon/wappalyzer/ 2>/dev/null

echo 'Installing Brave Browser. Dont forget to harden!'
sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
sudo tee /etc/apt/sources.list.d/brave-browser-release.list << EOF >/dev/null
deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg arch=amd64] https://brave-browser-apt-release.s3.brave.com/ stable main
EOF


echo 'Updating system and installing programs...'
#add seclists below when done testing
sudo apt -qq update -y && sudo apt -qq full-upgrade -y && sudo apt -qq install -y python3-venv spice-vdagent terminator brave-browser


# Autologin
sudo groupadd -r autologin
sudo gpasswd -a $USER autologin
sudo tee -a /etc/lightdm/lightdm.conf << EOF >/dev/null

#
# Personal customization ($USER)
#
[Seat:*]
autologin-user=$USER
EOF


echo 'Setting GRUB timeout to 0...'
sudo sed -i 's/GRUB_TIMEOUT=5/GRUB_TIMEOUT=0/g' /etc/default/grub && sudo update-grub &>/dev/null


echo 'Customizing ZSH...'
cp ~/.zshrc ~/.zsrch.bak
sed -i 's/PROMPT_ALTERNATIVE=twoline/PROMPT_ALTERNATIVE=oneline/g' ~/.zshrc
sed -i 's/NEWLINE_BEFORE_PROMPT=yes/NEWLINE_BEFORE_PROMPT=no/g' ~/.zshrc 
sudo tee -a ~/.zshrc << EOF >/dev/null 

# ---------------------------------- #
# --------- CUSTOMIZATION ---------- #
# ---------------------------------- #

# Hello world!

# ---------- QEMU/SPICE ------------ #

# Set randr resize on boot
xrandr --output Virtual-1 --auto

# Xrandr alias
alias rs='xrandr --output Virtual-1 --auto'

# --------- HACKING LAB PROVIDERS ------------- #

# Upgrade and connect to TryHackMe
alias THM='sudo apt update && sudo apt full-upgrade -y && sudo -b openvpn /home/lassi/Documents/tryhackme/lassi.ovpn'

# Upgrade and connect to OSCP labs
alias OSCP='sudo apt update && sudo apt full-upgrade -y && sudo -b openvpn /home/lassi/Documents/OSCP/pwk2.ovpn'

# Upgrade and connect to HTB
alias HTB='echo TODO'

# ------- PIP PROGRAMS -------- #
# TODO make a more extensible wrapper for both creating and launching virtualenv binaries

pwncat () {
source ~/.virtualenvs/pwncat/bin/activate && pwncat-cs "\$@" && deactivate
}

# ------- PENTEST ALIASES -----#
# TODO make something more reliable

# Copy common files to current dir
alias cplinpeas='wget -q https://github.com/carlospolop/PEASS-ng/releases/latest/download/linpeas.sh; echo "Lol script kiddie!"'
alias cpwinpeas='wget -q https://github.com/carlospolop/PEASS-ng/releases/latest/download/winPEAS.bat; echo "Lol script kiddie!"'

# ---------- MISC ------------- #

# Fuck M\$ spying
export DOTNET_CLI_TELEMETRY_OPTOUT=1

# EDITOR
export EDITOR=vim

# Stupid power management
xset s off -dpms

# ---------------------------------- #
# -------- END CUSTOMIZATION ------- #
# ---------------------------------- #
EOF

echo 'Installing pip binaries...'

mkdir ~/.virtualenvs && cd ~/.virtualenvs
python3 -m venv pwncat
source ./pwncat/bin/activate
pip install -q pwncat-cs
deactivate
cd
echo 'Pwncat installed!'

echo 'Installing startup programs...'
mkdir -p ~/.config/autostart
for program in kali-burpsuite terminator firefox-esr brave-browser; do
  cp /usr/share/applications/$program.desktop ~/.config/autostart/;
done


echo 'Everything done. You might want to do additional customizations, such as the top bar, yourself.'
echo 'TODO Obsidian, tmux, so much else'

read -r -p "Reboot? [y/N] " response
case "$response" in
    [yY][eE][sS]|[yY]) 
        sudo reboot now
        ;;
    *)
        exit 1
        ;;
esac
