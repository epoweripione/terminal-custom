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
# "editor.fontFamily": "'FiraCode Nerd Font Mono', 'Fira Code Retina', 'Sarasa Term SC', '更纱黑体 SC'"
# "editor.fontLigatures": true

# Install Nerd fonts
# https://github.com/ryanoasis/nerd-fonts
if [[ ! -x "$(command -v fontforge)" ]]; then
	## http://designwithfontforge.com/en-US/Installing_Fontforge.html
	colorEcho ${BLUE} "Installing fontforge..."
	# if check_release_package_manager packageManager apt; then
	# 	sudo apt-get install -y software-properties-common && \
	# 		sudo add-apt-repository ppa:fontforge/fontforge && \
	# 		sudo apt-get update
	# fi

	if [[ -x "$(command -v pacman)" ]]; then
		sudo pacman --noconfirm -S unzip python-pip fontforge
	else
		if check_release_package_manager packageManager yum; then
			sudo yum update -y && sudo yum -y -q install unzip python-pip fontforge
		elif check_release_package_manager packageManager apt; then
			sudo apt-get -y install unzip python-pip fontforge
		elif check_release_package_manager packageManager pacman; then
			sudo pacman -Sy && pacman --noconfirm -S unzip fontforge
		fi
	fi
fi

colorEcho ${BLUE} "Downloading nerd-fonts & font-patcher..."
## Use remote server to reduce `git clone` network traffic in local machine
## git clone --depth=1 --no-checkout --filter=blob:limit=1m \
# git clone --depth=1 --no-checkout --filter=blob:none \
# 		https://github.com/ryanoasis/nerd-fonts ~/nerd-fonts && \
# 	cd ~/nerd-fonts/ && \
# 	echo '/*\n!/patched-fonts/' >> .git/info/sparse-checkout && \
# 	git config core.sparsecheckout true && \
# 	git checkout master && \
# 	rm -rf ~/nerd-fonts/patched-fonts ~/nerd-fonts/.git && \
# 	# : && \
# 	# fix latest version issue patch char i,j not correct
# 	# rm -f ~/nerd-fonts/font-patcher && \
# 	# 	curl -SL -o ~/nerd-fonts/font-patcher \
# 	# 		https://github.com/ryanoasis/nerd-fonts/raw/3241ea6e44191ec89c0260f51112dec691363ebd/font-patcher
# 	# : && \
# 	rm -f /srv/web/www/default/nerd-fonts.zip || true && \
# 	cd ~ && zip -qr /srv/web/www/default/nerd-fonts.zip ./nerd-fonts

## cd ~/nerd-fonts && ./font-patcher --version

# Download from remote server
echo "Download URL for nerd-fonts repository?"
read -p "[Use git clone if empty] " NerdFont_URL
if [[ -z "$NerdFont_URL" ]]; then
	if [[ -d "~/nerd-fonts" ]]; then
		cd ~/nerd-fonts && git pull
	else
		git clone --depth=1 --no-checkout --filter=blob:none \
			https://github.com/ryanoasis/nerd-fonts ~/nerd-fonts && \
		cd ~/nerd-fonts/ && \
		echo '/*\n!/patched-fonts/' >> .git/info/sparse-checkout && \
		git config core.sparsecheckout true && \
		git checkout master
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

colorEcho ${BLUE} "Downloading FiraCode Nerd Font Complete Mono..."
# https://github.com/tonsky/FiraCode
## Patch fonts
# cd ~/nerd-fonts && for font in /c/DevWorkSpaces/nerd-fonts/Fira_Code_v5.2/ttf/*.ttf; do fontforge -script font-patcher -out /c/DevWorkSpaces/nerd-fonts/patched --quiet --careful --complete --mono --adjust-line-height "$font"; done && cd /c/DevWorkSpaces/nerd-fonts/patched && zip -r /c/DevWorkSpaces/nerd-fonts/FiraCode-Mono.zip . -i "Fira Code*.ttf"
curl -fSL https://github.com/epoweripione/terminal-custom/releases/download/v5.2.0/FiraCode-Mono.zip -o ~/patched-fonts/FiraCode-Mono.zip
mkdir -p ~/patched-fonts/FiraCode-Mono && \
	unzip -q ~/patched-fonts/FiraCode-Mono.zip -d ~/patched-fonts/FiraCode-Mono && \
	rm -f ~/patched-fonts/FiraCode-Mono.zip

colorEcho ${BLUE} "Downloading Iosevka Term SS05 Nerd Font Complete Mono..."
# https://github.com/be5invis/Iosevka
# ## Patch fonts
# # cd ~/nerd-fonts && for font in /c/DevWorkSpaces/nerd-fonts/ttf-iosevka-term-ss05-3.2.2/ttf/*.ttf; do fontforge -script font-patcher -out /c/DevWorkSpaces/nerd-fonts/patched --quiet --careful --complete --mono --adjust-line-height "$font"; done && cd /c/DevWorkSpaces/nerd-fonts/patched && zip -r /c/DevWorkSpaces/nerd-fonts/iosevka-term-ss05-Mono.zip . -i "Iosevka Term SS05*.ttf"
# curl -fSL https://github.com/epoweripione/terminal-custom/releases/download/v5.2.0/iosevka-term-ss05-Mono.zip -o ~/patched-fonts/iosevka-term-ss05-Mono.zip
# mkdir -p ~/patched-fonts/iosevka-term-ss05-Mono && \
# 	unzip -q ~/patched-fonts/iosevka-term-ss05-Mono.zip -d ~/patched-fonts/iosevka-term-ss05-Mono && \
# 	rm -f ~/patched-fonts/iosevka-term-ss05-Mono.zip

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
