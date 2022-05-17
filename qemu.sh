#!/usr/bin/zsh


echo 'Updating system...'
#sudo apt update && sudo apt full-upgrade -y && sudo apt install -y python3-venv seclists spice-vdagent
sudo apt update && sudo apt full-upgrade -y && sudo apt install -y python3-venv spice-vdagent


echo 'Adding user to autologin...'
sudo groupadd -r autologin
sudo gpasswd -a $USER autologin
sudo bash -c 'cat<<EOF >> /etc/lightdm/lightdm.conf

#
# Personal customization (lassi)
#
[Seat:*]
autologin-user=lassi
EOF'


echo 'Setting GRUB timeout to 0...'
sudo sed -i 's/GRUB_TIMEOUT=5/GRUB_TIMEOUT=0/g' /etc/default/grub && sudo update-grub


echo 'Customizing ZSH...'
cp ~/.zshrc ~/.zsrch.bak
sed -i 's/NEWLINE_BEFORE_PROMPT=yes/NEWLINE_BEFORE_PROMPT=no/g' ~/.zshrc 
sed -i 's/PROMPT_ALTERNATIVE=twoline/PROMPT_ALTERNATIVE=oneline/g' ~/.zshrc
cat <<EOF >> ~/.zshrc

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

# ---------------------------------- #
# -------- END CUSTOMIZATION ------- #
# ---------------------------------- #
EOF
source ~/.zshrc


echo 'Installing pip binaries...'

cd ~/.virtualenvs
python3 -m venv pwncat
source ./pwncat/bin/activate
pip install pwncat-cs
deactivate
cd
echo 'Pwncat installed!'
