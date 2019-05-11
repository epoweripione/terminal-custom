#!/bin/bash

#######color code########
RED="31m"      # Error message
GREEN="32m"    # Success message
YELLOW="33m"   # Warning message
BLUE="36m"     # Info message

colorEcho() {
	COLOR=$1
	echo -e "\033[${COLOR}${@:2}\033[0m"
}

ostype=$(uname)


# # Install Powerline fonts
# echo "Downloading Powerline fonts..."
# git clone https://github.com/powerline/fonts.git --depth=1 ~/powerline-fonts

# if [[ $ostype =~ "MSYS_NT" ]] || [[ $ostype =~ "CYGWIN_NT" ]]; then
#   echo "Please use install.ps1 in PowerShell to install Powerline fonts."
# else
#   echo "Installing Powerline fonts..."
#   cd ~/powerline-fonts && ./install.sh
#   # rm -rf ~/powerline-fonts
# fi


# Install Nerd fonts
# https://github.com/ryanoasis/nerd-fonts

if [[ ! -n $(which unzip) ]]; then
	colorEcho ${RED} "Please install unzip first!"
	exit 0
fi

if [[ $ostype =~ "MSYS_NT" || $ostype =~ "MINGW" || $ostype =~ "CYGWIN_NT" ]]; then
	:
else
	# if ((${EUID:-0} || "$(id -u)")); then
	if [[ $UID -ne 0 ]]; then
		colorEcho ${RED} "Please run this script as root user!"
		exit 0
	fi
fi


colorEcho ${BLUE} "Downloading Nerd fonts..."
mkdir -p ~/patched-fonts

# echo "Downloading SourceCodePro..."
# curl -fSL https://github.com/ryanoasis/nerd-fonts/releases/download/v2.0.0/SourceCodePro.zip -o ~/patched-fonts/SourceCodePro.zip
# mkdir -p ~/patched-fonts/SourceCodePro && \
#   unzip -q ~/patched-fonts/SourceCodePro.zip -d ~/patched-fonts/SourceCodePro && \
#   rm -f ~/patched-fonts/SourceCodePro.zip

# colorEcho ${BLUE} "Downloading FiraCode..."
# curl -fSL https://github.com/ryanoasis/nerd-fonts/releases/download/v2.0.0/FiraCode.zip -o ~/patched-fonts/FiraCode.zip
# mkdir -p ~/patched-fonts/FiraCode && \
#   unzip -q ~/patched-fonts/FiraCode.zip -d ~/patched-fonts/FiraCode && \
#   rm -f ~/patched-fonts/FiraCode.zip

# colorEcho ${BLUE} "Downloading FiraMono..."
# curl -fSL https://github.com/ryanoasis/nerd-fonts/releases/download/v2.0.0/FiraMono.zip -o ~/patched-fonts/FiraMono.zip
# mkdir -p ~/patched-fonts/FiraMono && \
#   unzip -q ~/patched-fonts/FiraMono.zip -d ~/patched-fonts/FiraMono && \
#   rm -f ~/patched-fonts/FiraMono.zip

# colorEcho ${BLUE} "Downloading Iosevka..."
# curl -fSL https://github.com/ryanoasis/nerd-fonts/releases/download/v2.0.0/Iosevka.zip -o ~/patched-fonts/Iosevka.zip
# mkdir -p ~/patched-fonts/Iosevka && \
#   unzip -q ~/patched-fonts/Iosevka.zip -d ~/patched-fonts/Iosevka && \
#   rm -f ~/patched-fonts/Iosevka.zip

colorEcho ${BLUE} "Downloading Iosevka Term SS05 Nerd Font Complete Mono 2.2.1..."
# cd ~/nerd-fonts
# for font in /e/VSCodeProjects/nerd-fonts/Iosevka/*.ttf; do fontforge -script font-patcher -out /e/VSCodeProjects/nerd-fonts/patched --quiet --careful --complete --mono --adjust-line-height "$font"; done
# cd /e/VSCodeProjects/nerd-fonts/patched && zip -r /e/VSCodeProjects/nerd-fonts/iosevka-term-ss05-nerd-2.2.1.zip *.ttf
curl -fSL https://github.com/epoweripione/terminal-custom/releases/download/v2.2.1/iosevka-term-ss05-nerd-2.2.1.zip -o ~/patched-fonts/iosevka-term-ss05-nerd.zip
mkdir -p ~/patched-fonts/iosevka-term-ss05-nerd && \
	unzip -q ~/patched-fonts/iosevka-term-ss05-nerd.zip -d ~/patched-fonts/iosevka-term-ss05-nerd && \
	rm -f ~/patched-fonts/iosevka-term-ss05-nerd.zip

# Install Script
curl -fSL https://github.com/ryanoasis/nerd-fonts/raw/master/install.sh -o ~/nerdfonts_installer.sh && chmod +x ~/nerdfonts_installer.sh

colorEcho ${BLUE} "Installing Nerd fonts..."
if [[ $ostype =~ "MSYS_NT" || $ostype =~ "MINGW" || $ostype =~ "CYGWIN_NT" ]]; then
	cd ~ && ./nerdfonts_installer.sh --quiet --clean --use-single-width-glyphs --install-to-user-path
	colorEcho ${BLUE} "Please manual install fonts from $HOME/.local/share/fonts"
else
	cd ~ && ./nerdfonts_installer.sh --quiet --clean --use-single-width-glyphs --install-to-system-path
	colorEcho ${GREEN} "Nerd fonts install complete!"
fi
