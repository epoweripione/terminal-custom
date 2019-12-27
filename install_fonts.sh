#!/bin/bash

# Load custom functions
if type 'colorEcho' 2>/dev/null | grep -q 'function'; then
    :
else
    if [[ -s "$HOME/custom_functions.sh" ]]; then
        source "$HOME/custom_functions.sh"
    else
        echo "$HOME/custom_functions.sh not exist!"
        exit 0
    fi
fi

# Get ostype
get_os_type

if [[ "$ostype" != "windows" && $UID -ne 0 ]]; then
    echo "Please run this script as root user!"
    exit 0
fi

## Visual Studio Code Settings
## "editor.fontFamily": "'FuraCode Nerd Font Mono', 'Fira Code Retina', 'FiraCode-Retina', 'Iosevka Nerd Font Mono', 'Iosevka Term SS05', 'Sarasa Term SC', '更纱黑体 SC'",
# "editor.fontFamily": "'FuraCode Nerd Font Mono', 'Fira Code Retina', 'FiraCode-Retina', 'Sarasa Term SC'",
# "editor.fontLigatures": true


# Install Nerd fonts
# https://github.com/ryanoasis/nerd-fonts
if [[ ! -x "$(command -v fontforge)" ]]; then
	# # http://designwithfontforge.com/en-US/Installing_Fontforge.html
	colorEcho ${BLUE} "Installing fontforge..."
	if check_release_package_manager packageManager apt; then
		apt-get install -y software-properties-common && \
			add-apt-repository ppa:fontforge/fontforge && \
			apt-get update
	fi

	if [[ -x "$(command -v pacapt)" || -x "$(command -v pacman)" ]]; then
		pacman --noconfirm -S unzip fontforge
	else
		if check_release_package_manager packageManager yum; then
			yum update -y && yum -y -q install unzip fontforge
		elif check_release_package_manager packageManager apt; then
			apt-get -y install unzip fontforge
		elif check_release_package_manager packageManager pacman; then
			pacman -Sy && pacman --noconfirm -S unzip fontforge
		fi
	fi

	# colorEcho ${BLUE} "Installing fontforge dependencies..."
	# apt-get install -y libjpeg-dev libtiff5-dev libpng-dev libfreetype6-dev libgif-dev \
	# 	libgtk-3-dev libxml2-dev libpango1.0-dev libcairo2-dev python3-dev \
	# 	ninja-build cmake build-essential
	
	# colorEcho ${BLUE} "Cloning fontforge repositories..."
	# cd ~ \
	# 	&& git clone https://github.com/fontforge/fontforge --depth 1 && \
	# 	git clone https://github.com/fontforge/libspiro --depth 1 && \
	# 	git clone https://github.com/fontforge/libuninameslist --depth 1
	
	# colorEcho ${BLUE} "Building libspiro..."
	# cd ~/libspiro && autoreconf -i && automake --foreign -Wall && \
	# 	./configure && make && make check && make install
	
	# colorEcho ${BLUE} "Building libuninameslist..."
	# cd ~/libuninameslist && autoreconf -i && automake && \
	# 	./configure && make && make install
	
	# colorEcho ${BLUE} "Building fontforge..."
	# cd ~/fontforge && mkdir -p build && cd build && \
	# 	cmake -GNinja .. && ninja && ninja install && \
	# 	ldconfig && \
	# 	cd ~
fi


# if [[ ! -d "~/nerd-fonts" ]]; then
# 	colorEcho ${BLUE} "Cloning nerd-fonts repository..."
# 	# Download font-patcher
# 	cd ~ && \
# 		git clone https://github.com/ryanoasis/nerd-fonts --depth 1 && \
# 		rm -rf ~/nerd-fonts/patched-fonts
# 	# font-patcher
# 	cd ~/nerd-fonts && ./font-patcher --version && cd ~
# fi

colorEcho ${BLUE} "Downloading nerd-fonts & font-patcher..."
## Use remote server to reduce `git clone` network traffic in local machine
# git clone --depth 1 https://github.com/ryanoasis/nerd-fonts ~/nerd-fonts && \
# 	rm -rf ~/nerd-fonts/patched-fonts ~/nerd-fonts/.git && \
# 	: && \
# 	# fix latest version issue patch char i,j not correct
# 	# rm -f ~/nerd-fonts/font-patcher && \
# 	# 	curl -SL -o ~/nerd-fonts/font-patcher \
# 	# 		https://github.com/ryanoasis/nerd-fonts/raw/3241ea6e44191ec89c0260f51112dec691363ebd/font-patcher
# 	# : && \
# 	cd ~ && zip -q -r nerd-fonts.zip ./nerd-fonts && \
# 	mv ~/nerd-fonts.zip /srv/web/www/default

# Download from remote server
echo "Download URL for nerd-fonts repository?"
read -p "[Use git clone if empty] " NerdFont_URL
if [[ -z "$NerdFont_URL" ]]; then
	if [[ -d "~/nerd-fonts" ]]; then
		cd ~/nerd-fonts && git pull
	else
		git clone --depth 1 https://github.com/ryanoasis/nerd-fonts ~/nerd-fonts
	fi
else
	[[ -d "~/nerd-fonts" ]] && rm -rf ~/nerd-fonts
	wget -c -O ~/nerd-fonts.zip "$NerdFont_URL" && \
		unzip -q nerd-fonts.zip -d ~
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

colorEcho ${BLUE} "Downloading FiraCode Nerd Font Complete Mono 2.0.0..."
# https://github.com/tonsky/FiraCode
## Patch fonts
# cd ~/nerd-fonts
# for font in /e/VSCodeProjects/nerd-fonts/FiraCode_2/*.ttf; do fontforge -script font-patcher -out /e/VSCodeProjects/nerd-fonts/patched --quiet --careful --complete --mono --adjust-line-height "$font"; done
# cd /e/VSCodeProjects/nerd-fonts/patched && zip -r /e/VSCodeProjects/nerd-fonts/FiraCode-Mono-2.0.0.zip . -i "Fira Code*.ttf"
curl -fSL https://github.com/epoweripione/terminal-custom/releases/download/v2.3.3/FiraCode-Mono-2.0.0.zip -o ~/patched-fonts/FiraCode-Mono.zip
mkdir -p ~/patched-fonts/FiraCode-Mono && \
	unzip -q ~/patched-fonts/FiraCode-Mono.zip -d ~/patched-fonts/FiraCode-Mono && \
	rm -f ~/patched-fonts/FiraCode-Mono.zip

colorEcho ${BLUE} "Downloading Iosevka Term SS05 Nerd Font Complete Mono 2.3.3..."
# https://github.com/be5invis/Iosevka
## Patch fonts
# cd ~/nerd-fonts
# for font in /e/VSCodeProjects/nerd-fonts/Iosevka/*.ttf; do fontforge -script font-patcher -out /e/VSCodeProjects/nerd-fonts/patched --quiet --careful --complete --mono --adjust-line-height "$font"; done
# cd /e/VSCodeProjects/nerd-fonts/patched && zip -r /e/VSCodeProjects/nerd-fonts/iosevka-term-ss05-Mono-2.3.3.zip . -i "Iosevka Term SS05*.ttf"
curl -fSL https://github.com/epoweripione/terminal-custom/releases/download/v2.3.3/iosevka-term-ss05-Mono-2.3.3.zip -o ~/patched-fonts/iosevka-term-ss05-Mono.zip
mkdir -p ~/patched-fonts/iosevka-term-ss05-Mono && \
	unzip -q ~/patched-fonts/iosevka-term-ss05-Mono.zip -d ~/patched-fonts/iosevka-term-ss05-Mono && \
	rm -f ~/patched-fonts/iosevka-term-ss05-Mono.zip

# Install Script
curl -fSL https://github.com/ryanoasis/nerd-fonts/raw/master/install.sh -o ~/nerdfonts_installer.sh && chmod +x ~/nerdfonts_installer.sh

colorEcho ${BLUE} "Installing Nerd fonts..."
if [[ "$ostype" == "windows" ]]; then
	cd ~ && ./nerdfonts_installer.sh --quiet --clean --use-single-width-glyphs --install-to-user-path
	colorEcho ${BLUE} "Please manual install fonts from $HOME/.local/share/fonts"
else
	cd ~ && ./nerdfonts_installer.sh --quiet --clean --use-single-width-glyphs --install-to-system-path
	colorEcho ${GREEN} "Nerd fonts install complete!"
fi
