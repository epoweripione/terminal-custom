#!/usr/bin/env bash

if [[ "${OS_INFO_TYPE}" != "windows" && $UID -ne 0 ]]; then
    echo "Please run this script as root user!"
    exit 0
fi

trap 'rm -rf "$WORKDIR"' EXIT

[[ -z "$WORKDIR" ]] && WORKDIR="$(mktemp -d)"
[[ -z "$CURRENT_DIR" ]] && CURRENT_DIR=$(pwd)

# Load custom functions
if type 'colorEcho' 2>/dev/null | grep -q 'function'; then
    :
else
    if [[ -s "${MY_SHELL_SCRIPTS:-$HOME/terminal-custom}/custom_functions.sh" ]]; then
        source "${MY_SHELL_SCRIPTS:-$HOME/terminal-custom}/custom_functions.sh"
    else
        echo "${MY_SHELL_SCRIPTS:-$HOME/terminal-custom}/custom_functions.sh not exist!"
        exit 0
    fi
fi

[[ -n "${INSTALLER_CHECK_CURL_OPTION}" ]] && curl_check_opts=(`echo ${INSTALLER_CHECK_CURL_OPTION}`) || curl_check_opts=(-fsL)
[[ -n "${INSTALLER_DOWNLOAD_CURL_OPTION}" ]] && curl_download_opts=(`echo ${INSTALLER_DOWNLOAD_CURL_OPTION}`) || curl_download_opts=(-fSL)

# Get OS type
get_os_type

## Visual Studio Code Settings
# "editor.fontFamily": "'FiraCode Nerd Font Mono', 'Fira Code Retina', 'Sarasa Term SC', '更纱黑体 SC'"
# "editor.fontLigatures": true

# Install Nerd fonts
# https://github.com/ryanoasis/nerd-fonts

# http://designwithfontforge.com/en-US/Installing_Fontforge.html
if [[ -x "$(command -v pacman)" ]]; then
    PackagesList=(
        unzip
		python-pip
		fontforge
    )
    for TargetPackage in "${PackagesList[@]}"; do
        if checkPackageNeedInstall "${TargetPackage}"; then
            colorEcho "${BLUE}  Installing ${FUCHSIA}${TargetPackage}${BLUE}..."
            sudo pacman --noconfirm -S "${TargetPackage}"
        fi
    done
fi

colorEcho "${BLUE}Downloading ${FUCHSIA}nerd-fonts & font-patcher${BLUE}..."
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
# 	# 	curl "${curl_download_opts[@]}" -o ~/nerd-fonts/font-patcher \
# 	# 		https://github.com/ryanoasis/nerd-fonts/raw/3241ea6e44191ec89c0260f51112dec691363ebd/font-patcher
# 	# : && \
# 	rm -f /srv/web/www/default/nerd-fonts.zip || true && \
# 	cd ~ && zip -qr /srv/web/www/default/nerd-fonts.zip ./nerd-fonts

## cd ~/nerd-fonts && ./font-patcher --version

# Download from remote server
echo "Download URL for nerd-fonts repository?"
read -p "[Use git clone if empty] " NerdFont_URL
if [[ -z "$NerdFont_URL" ]]; then
	if [[ -d "$HOME/nerd-fonts" ]]; then
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
	[[ -d "$HOME/nerd-fonts" ]] && rm -rf ~/nerd-fonts
	wget -c -O ~/nerd-fonts.zip "$NerdFont_URL" && \
		unzip -q nerd-fonts.zip -d ~
fi


colorEcho "${BLUE}Downloading ${FUCHSIA}Nerd fonts${BLUE}..."
mkdir -p ~/patched-fonts

# echo "Downloading ${FUCHSIA}SourceCodePro${BLUE}..."
# curl "${curl_download_opts[@]}" https://github.com/ryanoasis/nerd-fonts/releases/download/v2.0.0/SourceCodePro.zip -o ~/patched-fonts/SourceCodePro.zip
# mkdir -p ~/patched-fonts/SourceCodePro && \
#   unzip -q ~/patched-fonts/SourceCodePro.zip -d ~/patched-fonts/SourceCodePro && \
#   rm -f ~/patched-fonts/SourceCodePro.zip

# colorEcho "${BLUE}Downloading ${FUCHSIA}FiraCode${BLUE}..."
# curl "${curl_download_opts[@]}" https://github.com/ryanoasis/nerd-fonts/releases/download/v2.0.0/FiraCode.zip -o ~/patched-fonts/FiraCode.zip
# mkdir -p ~/patched-fonts/FiraCode && \
#   unzip -q ~/patched-fonts/FiraCode.zip -d ~/patched-fonts/FiraCode && \
#   rm -f ~/patched-fonts/FiraCode.zip

# colorEcho "${BLUE}Downloading ${FUCHSIA}FiraMono${BLUE}..."
# curl "${curl_download_opts[@]}" https://github.com/ryanoasis/nerd-fonts/releases/download/v2.0.0/FiraMono.zip -o ~/patched-fonts/FiraMono.zip
# mkdir -p ~/patched-fonts/FiraMono && \
#   unzip -q ~/patched-fonts/FiraMono.zip -d ~/patched-fonts/FiraMono && \
#   rm -f ~/patched-fonts/FiraMono.zip

# colorEcho "${BLUE}Downloading ${FUCHSIA}Iosevka${BLUE}..."
# curl "${curl_download_opts[@]}" https://github.com/ryanoasis/nerd-fonts/releases/download/v2.0.0/Iosevka.zip -o ~/patched-fonts/Iosevka.zip
# mkdir -p ~/patched-fonts/Iosevka && \
#   unzip -q ~/patched-fonts/Iosevka.zip -d ~/patched-fonts/Iosevka && \
#   rm -f ~/patched-fonts/Iosevka.zip

colorEcho "${BLUE}Downloading ${FUCHSIA}FiraCode Nerd Font Complete Mono${BLUE}..."
# https://github.com/tonsky/FiraCode
## Patch fonts
# cd ~/nerd-fonts && for font in /c/DevWorkSpaces/nerd-fonts/Fira_Code_v5.2/ttf/*.ttf; do fontforge -script font-patcher -out /c/DevWorkSpaces/nerd-fonts/patched --quiet --careful --complete --mono --adjust-line-height "$font"; done && cd /c/DevWorkSpaces/nerd-fonts/patched && zip -r /c/DevWorkSpaces/nerd-fonts/FiraCode-Mono.zip . -i "Fira Code*.ttf"
curl "${curl_download_opts[@]}" https://github.com/epoweripione/terminal-custom/releases/download/v5.2.0/FiraCode-Mono.zip -o ~/patched-fonts/FiraCode-Mono.zip
mkdir -p ~/patched-fonts/FiraCode-Mono && \
	unzip -q ~/patched-fonts/FiraCode-Mono.zip -d ~/patched-fonts/FiraCode-Mono && \
	rm -f ~/patched-fonts/FiraCode-Mono.zip

colorEcho "${BLUE}Downloading ${FUCHSIA}Iosevka Term SS05 Nerd Font Complete Mono${BLUE}..."
# https://github.com/be5invis/Iosevka
# ## Patch fonts
# # cd ~/nerd-fonts && for font in /c/DevWorkSpaces/nerd-fonts/ttf-iosevka-term-ss05-4.0.3/ttf/*.ttf; do fontforge -script font-patcher -out /c/DevWorkSpaces/nerd-fonts/patched --quiet --careful --complete --mono --adjust-line-height "$font"; done && cd /c/DevWorkSpaces/nerd-fonts/patched && zip -r /c/DevWorkSpaces/nerd-fonts/iosevka-term-ss05-Mono.zip . -i "Iosevka Term SS05*.ttf"
# curl "${curl_download_opts[@]}" https://github.com/epoweripione/terminal-custom/releases/download/v5.2.0/iosevka-term-ss05-Mono.zip -o ~/patched-fonts/iosevka-term-ss05-Mono.zip
# mkdir -p ~/patched-fonts/iosevka-term-ss05-Mono && \
# 	unzip -q ~/patched-fonts/iosevka-term-ss05-Mono.zip -d ~/patched-fonts/iosevka-term-ss05-Mono && \
# 	rm -f ~/patched-fonts/iosevka-term-ss05-Mono.zip

# Install Script
curl "${curl_download_opts[@]}" https://github.com/ryanoasis/nerd-fonts/raw/master/install.sh -o ~/nerdfonts_installer.sh && chmod +x ~/nerdfonts_installer.sh

colorEcho "${BLUE}Installing ${FUCHSIA}Nerd fonts${BLUE}..."
if [[ "${OS_INFO_TYPE}" == "windows" ]]; then
	cd ~ && ./nerdfonts_installer.sh --quiet --clean --use-single-width-glyphs --install-to-user-path
	colorEcho "${BLUE}Please manual install fonts from $HOME/.local/share/fonts"
else
	cd ~ && ./nerdfonts_installer.sh --quiet --clean --use-single-width-glyphs --install-to-system-path
	colorEcho "${GREEN}Nerd fonts install complete!"
fi

cd "${CURRENT_DIR}"