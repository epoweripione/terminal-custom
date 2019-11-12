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


# socks5 proxy
# git
read -p "Use socks5 proxy for github,gitlab?[y/N]:" GIT_PROXY_CHOICE
if [[ "$GIT_PROXY_CHOICE" == 'y' || "$GIT_PROXY_CHOICE" == 'Y' ]]; then
    read -p "Socks5 proxy address?[127.0.0.1:55880]:" Sock5Address
    [[ -z "$Sock5Address" ]] && Sock5Address=127.0.0.1:55880
    
    # [[ -s "$HOME/cross_gfw_config.sh" ]] && source "$HOME/cross_gfw_config.sh"
    set_git_socks5_proxy github.com,gitlab.com ${Sock5Address}
fi

# curl
read -p "Use socks5 proxy for curl?[y/N]:" CURL_PROXY_CHOICE
if [[ "$CURL_PROXY_CHOICE" == 'y' || "$CURL_PROXY_CHOICE" == 'Y' ]]; then
    read -p "Socks5 proxy address?[127.0.0.1:55880]:" Sock5Address
    [[ -z "$Sock5Address" ]] && Sock5Address=127.0.0.1:55880
    echo "--socks5-hostname \"${Sock5Address}\"" >> $HOME/.curlrc
else
    sed -i "/^--socks5-hostname.*/d" $HOME/.curlrc
fi


# pacman
# Generate custom mirrorlist
read -p "Generate custom mirrorlist in China?[y/N]:" CHOICE
if [[ "$CHOICE" == 'y' || "$CHOICE" == 'Y' ]]
    sudo pacman-mirrors -i -c China -m rank
fi

# Show colorful output on the terminal
sudo sed -i 's|^#Color|Color|' /etc/pacman.conf

# Arch Linux Chinese Community Repository
# https://github.com/archlinuxcn/mirrorlist-repo
read -p "Add Arch Linux Chinese Community Repository?[y/N]:" CHOICE
# CHOICE=$(echo $CHOICE | sed 's/.*/\U&/')
if [[ "$CHOICE" == 'y' || "$CHOICE" == 'Y' ]]
    if [[ ! $(grep "archlinuxcn" /etc/pacman.conf) ]]; then
        echo "[archlinuxcn]" | sudo tee -a /etc/pacman.conf
        # echo "Server = https://repo.archlinuxcn.org/\$arch" | sudo tee -a /etc/pacman.conf
        echo "Server = Server = https://mirrors.tuna.tsinghua.edu.cn/archlinuxcn/\$arch" \
            | sudo tee -a /etc/pacman.conf
    fi
    sudo pacman --noconfirm -Syy && \
        sudo pacman --noconfirm -S archlinuxcn-keyring && \
        sudo pacman --noconfirm -S archlinuxcn-mirrorlist-git
fi

# Full update
sudo pacman --noconfirm -Syu


# Language packs
sudo pacman --noconfirm -S \
    firefox-i18n-zh-cn thunderbird-i18n-zh-cn gimp-help-zh_cn \
    libreoffice-still-zh-CN man-pages-zh_cn


# sshd
[[ $(systemctl is-enabled sshd 2>/dev/null) ]] || \
    { sudo systemctl enable sshd; sudo systemctl start sshd; }


# Virtualbox
# https://wiki.manjaro.org/index.php?title=VirtualBox
# virtualbox-guest-utils
read -p "Install virtualbox-guest-utils?[y/N]:" CHOICE
if [[ "$CHOICE" == 'y' || "$CHOICE" == 'Y' ]]
    sudo pacman --noconfirm -S virtualbox-guest-utils
    linux_ver=linux$(uname -r | cut -d'.' -f1-2 | sed 's/\.//')
    sudo pacman --noconfirm -S ${linux_ver}-virtualbox-guest-modules
fi


# winbind
read -p "Enable winbind?[y/N]:" CHOICE
if [[ "$CHOICE" == 'y' || "$CHOICE" == 'Y' ]]
    sudo pacman --noconfirm -S manjaro-settings-samba
    sudo usermod -a -G sambashare $(whoami)
    sudo systemctl enable winbind && sudo systemctl start winbind
fi


# pre-request packages
colorEcho ${BLUE} "Installing pre-request packages..."
sudo pacman --noconfirm -S git curl wget unzip


# iTerm2-Color-Schemes
# https://github.com/mbadolato/iTerm2-Color-Schemes
colorEcho ${BLUE} "Installing iTerm2-Color-Schemes..."
git clone --depth 1 https://github.com/mbadolato/iTerm2-Color-Schemes $HOME/iTerm2-Color-Schemes && \
    mkdir -p $HOME/.local/share/xfce4/terminal/colorschemes && \
    cp $HOME/iTerm2-Color-Schemes/xfce4terminal/colorschemes/*.theme $HOME/.local/share/xfce4/terminal/colorschemes


# yay
# https://github.com/Jguer/yay
# yay <Search Term>               Present package-installation selection menu.
# yay -Ps                         Print system statistics.
# yay -Yc                         Clean unneeded dependencies.
# yay -G <AUR Package>            Download PKGBUILD from ABS or AUR.
# yay -Y --gendb                  Generate development package database used for devel update.
# yay -Syu --devel --timeupdate   Perform system upgrade, but also check for development package updates and 
#                                     use PKGBUILD modification time (not version number) to determine update.
colorEcho ${BLUE} "Installing yay..."
if [[ -d $HOME/yay ]]; then
    cd $HOME/yay && git pull && makepkg -si
else
    git clone https://aur.archlinux.org/yay $HOME/yay && \
        cd $HOME/yay && \
        makepkg -si
fi

# AUR mirror in china
if ! check_webservice_up www.google.com; then
    # $HOME/.config/yay/config.json
    # yay -P -g
    [[ -x "$(command -v yay)" ]] && \
        yay --aururl "https://aur.tuna.tsinghua.edu.cn" --save
fi


# Fonts
sudo pacman --noconfirm -S powerline-fonts ttf-symbola ttf-fira-code ttf-sarasa-gothic

# FuraCode Nerd Font Complete Mono
read -p "Download URL for FuraCode-Mono?[Use github by default]" NerdFont_URL
[[ -z "$NerdFont_URL" ]] && \
    NerdFont_URL="https://github.com/epoweripione/terminal-custom/releases/download/v2.3.2/FuraCode-Mono-2.0.0.zip"

mkdir -p "$HOME/patched-fonts/FuraCode-Mono" && \
    curl -fSL -o "$HOME/patched-fonts/FuraCode-Mono.zip" ${NerdFont_URL} && \
    unzip -q "$HOME/patched-fonts/FuraCode-Mono.zip" -d "$HOME/patched-fonts/FuraCode-Mono" && \
    sudo mv -f "$HOME/patched-fonts/FuraCode-Mono/" "/usr/share/fonts/" && \
    sudo chmod -R 744 "/usr/share/fonts/FuraCode-Mono" && \
    sudo fc-cache -fv


# Fcitx input methods for Chinese Pinyin
yay --noconfirm -S qtwebkit-bin fcitx-qt4
yay --noconfirm -S fcitx fcitx-im fcitx-rime fcitx-configtool
yay --noconfirm -S fcitx-cloudpinyin fcitx-googlepinyin 
yay --noconfirm -S fcitx-skin-material
yay --noconfirm -S fcitx-sogoupinyin

cat >> $HOME/.pam_environment <<-EOF
# fcitx
GTK_IM_MODULE=fcitx
QT_IM_MODULE=fcitx
XMODIFIERS=@im=fcitx
EOF

# # Fcitx5 input methods for Chinese Pinyin
# # https://github.com/fcitx/fcitx5
# # https://blog.rasphino.cn/archive/a-taste-of-fcitx5-in-arch.html
# # https://a-wing.top/linux/2018/08/14/fcitx5.html
# # kcm-fcitx5-git 如果你用的是 KDE ，请装这个
# # fcitx5-rime-git 繁體中文輸入 RIME 中州韻輸入法引擎
# # fcitx5-anthy-git 日文输入法
# # fcitx5-mozc-git 日文输入法，使用 Google 引擎
# # yay --noconfirm -S fcitx5-git fcitx5-qt5-git fcitx5-gtk-git fcitx5-chinese-addons-git fcitx5-rime-git
# sudo pacman -S fcitx5 fcitx5-qt fcitx5-gtk fcitx5-chinese-addons

# # fcitx5 profile
# mkdir -p $HOME/.config/fcitx5/
# cat >> $HOME/.config/fcitx5/profile <<-EOF
# [Profile]
# # CurrentGroup
# CurrentGroup=Default

# [Profile/GroupOrder]
# 0=Default

# [Profile/Groups/0]
# # Default Input Method
# DefaultIM=pinyin
# # Layout
# Default Layout=us
# # Group Name
# Name=Default

# [Profile/Groups/0/Items/1]
# # Layout
# Layout=
# # Name
# Name=pinyin

# [Profile/Groups/0/Items/0]
# # Layout
# Layout=
# # Name
# Name=keyboard-us
# EOF

# # fcitx5 env
# cat >> $HOME/.pam_environment <<-EOF
# # fcitx5
# GTK_IM_MODULE=fcitx5
# QT_IM_MODULE=fcitx5
# XMODIFIERS=@im=fcitx
# EOF

# # auto start fcitx5
# echo 'fcitx5 &' >> $HOME/.xprofile

# # fcitx5 theme
# git clone https://github.com/iovxw/fcitx5-simple-theme $HOME/.local/share/fcitx5/themes/simple
# mkdir -p $HOME/.config/fcitx5/conf
# cat >> $HOME/.config/fcitx5/conf/classicui.conf <<-EOF
# # True, if you want a vertical candidate list
# Vertical Candidate List=False
# Theme=simple
# EOF


# RDP Server
# http://www.xrdp.org/
# https://wiki.archlinux.org/index.php/xrdp
sudo pacman --noconfirm -S xrdp
# yay --noconfirm -S xorgxrdp xrdp
echo 'allowed_users=anybody' | sudo tee -a /etc/X11/Xwrapper.config
sudo systemctl enable xrdp xrdp-sesman && \
    sudo systemctl start xrdp xrdp-sesman


# RDP Client
sudo pacman --noconfirm -S freerdp remmina


# # NoMachine
# # https://www.nomachine.com/DT02O00124
# wget -c -O nomachine_x86_64.tar.gz \
#     https://download.nomachine.com/download/6.8/Linux/nomachine_6.8.1_1_x86_64.tar.gz && \
#     sudo tar xzvf nomachine_x86_64.tar.gz -C /usr && \
#     sudo /usr/NX/nxserver --install

# # UPDATE
# cd /usr
# wget -c -O nomachine_x86_64.tar.gz \
#     https://download.nomachine.com/download/6.8/Linux/nomachine_6.8.1_1_x86_64.tar.gz && \
#     sudo tar xzvf nomachine_x86_64.tar.gz -C /usr && \
#     sudo /usr/NX/nxserver --update

# # UNINSTALL
# sudo /usr/NX/scripts/setup/nxserver --uninstall && sudo rm -rf /usr/NX


# # Conky
# sudo pacman --noconfirm -S conky
sudo pacman --noconfirm -S conky-lua-nv conky-manager jq lua-clock-manjaro

# conky-colors
# https://github.com/helmuthdu/conky_colors
# http://forum.ubuntu.org.cn/viewtopic.php?f=94&t=313031
# http://www.manongzj.com/blog/4-lhjnjqtantllpnj.html
yay --noconfirm -S conky-colors
curl -SL -o $HOME/conky-convert.lua \
    https://raw.githubusercontent.com/brndnmtthws/conky/master/extras/convert.lua
# conky-colors --help
conky-colors --theme=human --side=right --arch --cpu=2 --proc=5 \
    --swap --hd=mix --network --clock=modern --calendar
    # --weather=2161838 --bbcweather=1809858 --unit=C
# network interface
get_network_interface_default
[[ -n "${NETWORK_INTERFACE_DEFAULT}" ]] && \
    sed -i 's/ppp0/${NETWORK_INTERFACE_DEFAULT}/g' $HOME/.conkycolors/conkyrc
# display font
sed -i 's/font Liberation Sans/font Sarasa Term SC/g' $HOME/.conkycolors/conkyrc && \
    sed -i 's/font Liberation Mono/font Sarasa Mono SC/g' $HOME/.conkycolors/conkyrc && \
    sed -i 's/font ConkyColors/font Sarasa Term SC/g' $HOME/.conkycolors/conkyrc && \
    sed -i 's/font Sarasa Term SCLogos/font ConkyColorsLogos/g' $HOME/.conkycolors/conkyrc && \
    : && \
    lua $HOME/conky-convert.lua $HOME/.conkycolors/conkyrc
# conky -c $HOME/.conkycolors/conkyrc

# conky-weather
# https://github.com/kuiba1949/conky-weather
git clone --depth 1 https://github.com/kuiba1949/conky-weather $HOME/.conky/conky-weather && \
    sed -i 's/alignment top_right/alignment middle_middle/' $HOME/.conky/conky-weather/conkyrc_mini && \
    sed -i 's/WenQuanYi Zen Hei/font Sarasa Term SC/g' $HOME/.conky/conky-weather/conkyrc_mini && \
    sed -i 's/gap_y.*/gap_y 20/' $HOME/.conky/conky-weather/conkyrc_mini && \
    sed -i 's/draw_borders.*/draw_borders = false,/' $HOME/.conky/conky-weather/conkyrc_mini && \
    sed -i '/own_window_colour/,$d' $HOME/.conky/conky-weather/conkyrc_mini && \
    # sed -i '/提醒/,$d' $HOME/.conky/conky-weather/conkyrc_mini && \
    : && \
    lua $HOME/conky-convert.lua $HOME/.conky/conky-weather/conkyrc_mini && \
    : && \
    cd $HOME/.conky/conky-weather/bin && \
    chmod +x ./conky-weather-update &&\
    ./conky-weather-update && \
    : && \
    sed -i "s|Exec=.*|Exec=$HOME/.conky/conky-weather/bin/conky-weather-update|" \
        $HOME/.config/autostart/86conky-weather-update.desktop

# Custom Conky Themes for blackPanther OS
# https://github.com/blackPantherOS/Conky-themes
git clone --depth 1 https://github.com/blackPantherOS/Conky-themes $HOME/.conky/blackPantherOS

# # Aureola: A conky collection of great conky's following the lua syntax
# # https://github.com/erikdubois/Aureola
# git clone --depth 1 https://github.com/erikdubois/Aureola $HOME/conky-theme-aureola
# cd $HOME/conky-theme-aureola && ./get-aureola-from-github-to-local-drive-v1.sh
# cd $HOME/.aureola/lazuli && ./install-conky.sh

# # conky-ubuntu
# # https://fanqxu.com/2019/04/03/conky-ubuntu/
# # echo "$HOME/.config/conky/startconky.sh &" >> $HOME/.xprofile
# git clone https://github.com/FanqXu/conkyrc $HOME/.conky/conky-ubuntu && \
#     cd $HOME/.conky/conky-ubuntu && \
#     ./install.sh

# # Harmattan
# # https://github.com/zagortenay333/Harmattan
# git clone --depth=1 https://github.com/zagortenay333/Harmattan $HOME/Harmattan && \
#     cp -rf $HOME/Harmattan/.harmattan-assets $HOME
# # cd Harmattan && ./preview

# # set conky theme
# cp -f $HOME/Harmattan/.harmattan-themes/Numix/God-Mode/normal-mode/.conkyrc $HOME

# # postions
# sed -i 's/--alignment="middle_middle",/alignment="top_right",/' $HOME/.conkyrc && \
#     sed -i 's/gap_x.*/gap_x=10,/' $HOME/.conkyrc && \
#     sed -i 's/gap_y.*/gap_y=100,/' $HOME/.conkyrc

# # settings
# get_network_interface_default

# read -p "OpenWeatherMap Api Key?" OpenWeatherMap_Key
# read -p "OpenWeatherMap City ID?" OpenWeatherMap_CityID
# read -p "OpenWeatherMap LANG?[zh_cn]" OpenWeatherMap_LANG
# [[ -z "$OpenWeatherMap_LANG" ]] && OpenWeatherMap_LANG="zh_cn"

# sed -i 's/template6=\"\"/template6=\"${OpenWeatherMap_Key}\"/g' $HOME/.conkyrc && \
#     sed -i 's/template7=\"\"/template7=\"${OpenWeatherMap_CityID}\"/g' $HOME/.conkyrc && \
#     sed -i 's/ppp0/${NETWORK_INTERFACE_DEFAULT}/g' $HOME/.conkyrc

# # star script
# cat > $HOME/.conky/start.sh <<-EOF
# #!/bin/bash
# killall conky
# apiKey=${OpenWeatherMap_Key}
# cityId=${OpenWeatherMap_CityID}
# unit=metric
# lang=${OpenWeatherMap_LANG}
# curl -s "api.openweathermap.org/data/2.5/forecast?id=\${cityId}&cnt=5&units=\${unit}&appid=\${apiKey}&lang=\${lang}" -o $HOME/.cache/harmattan-conky/forecast.json
# curl -s "api.openweathermap.org/data/2.5/weather?id=\${cityId}&cnt=5&units=\${unit}&appid=\${apiKey}&lang=\${lang}" -o $HOME/.cache/harmattan-conky/weather.json
# sleep 2
# conky 2>/dev/null &
# EOF

# auto start conky
cat > $HOME/.conky/autostart.sh <<-EOF
#!/bin/bash

killall conky

# time (in s) for the DE to start; use ~20 for Gnome or KDE, less for Xfce/LXDE etc
sleep 10

# the main conky
# /usr/share/conkycolors/bin/conkyStart
conky -c $HOME/.conkycolors/conkyrc --daemonize --quiet

# time for the main conky to start
# needed so that the smaller ones draw above not below 
# probably can be lower, but we still have to wait 5s for the rings to avoid segfaults
sleep 5

conky -c $HOME/.conky/conky-weather/conkyrc_mini --daemonize --quiet
EOF

chmod +x $HOME/.conky/autostart.sh
if [[ ! $(grep "autostart.sh" $HOME/.xprofile) ]]; then
    # echo "$HOME/.conky/autostart.sh &" >> $HOME/.xprofile
    echo "$HOME/.conky/autostart.sh >/dev/null 2>&1 & disown" >> $HOME/.xprofile
fi

# mkdir -p $HOME/.config/autostart
# cat > $HOME/.config/autostart/conky-colors.desktop <<-EOF
# [Desktop Entry]
# Name=conky-colors
# Exec=/usr/share/conkycolors/bin/conkyStart
# Type=Application
# Terminal=false
# Hidden=false
# NoDisplay=false
# StartupNotify=false
# EOF

# cat > $HOME/.config/autostart/conky-weather.desktop <<-EOF
# [Desktop Entry]
# Name=conky-weather
# Exec=conky -c $HOME/.conky/conky-weather/conkyrc_mini --daemonize --quiet
# Type=Application
# Terminal=false
# Hidden=false
# NoDisplay=false
# StartupNotify=false
# EOF


# # Desktop
sudo pacman --noconfirm -S dmenu

# compton: X compositor that may fix tearing issues
# feh: Fast and light imlib2-based image viewer
# inkscape: Professional vector graphics editor
# mate-power-manager: Power management tool for the MATE desktop
# mpd: Flexible, powerful, server-side application for playing music
# ncmpcpp: Fully featured MPD client using ncurses
# polybar: A fast and easy-to-use status bar
# scrot: command-line screenshot utility for X
# xcompmgr: Composite Window-effects manager for X.org
sudo pacman --noconfirm -S compton feh inkscape mate-power-manager mpd ncmpcpp polybar scrot

# # xmonad https://xmonad.org/
# # sudo pacman --noconfirm -S xmonad xmonad-contrib xmonad-utils slock xmobar

# # i3 https://i3wm.org/
# # https://www.zhihu.com/question/62251457
# # https://github.com/levinit/i3wm-config
# # https://github.com/Karmenzind/dotfiles-and-scripts/
# # i3-gaps i3-wm i3blocks i3lock i3status
# sudo pacman --noconfirm -S i3
# sudo pacman --noconfirm -S i3-scrot i3lock-color betterlockscreen
# sudo pacman --noconfirm -S i3-scripts i3-theme-dark i3-theme-dust i3-wallpapers
# # artwork-i3 conky-i3 dmenu-manjaro i3-default-artwork i3-help
# # i3exit i3status-manjaro manjaro-i3-settings manjaro-i3-settings-bldbk
# sudo pacman --noconfirm -S i3-manjaro

# # powerline: Statusline plugin for vim, and provides statuslines and prompts for several other applications, 
# # including zsh, bash, tmux, IPython, Awesome, i3 and Qtile
# sudo pacman --noconfirm -S powerline


# Apps
# Broswer
sudo pacman --noconfirm -S google-chrome chromium

# Clipborad
sudo pacman --noconfirm -S copyq

# Develop
sudo pacman --noconfirm -S visual-studio-code-bin dbeaver wireshark-qt

# Dictionary
sudo pacman --noconfirm -S goldendict

# Download & Upload
sudo pacman --noconfirm -S uget filezilla

# Docker
sudo pacman --noconfirm -S docker docker-compose
# yay -S kitematic

# File & dir compare
sudo pacman --noconfirm -S meld

# Free disk space and maintain privacy
sudo pacman --noconfirm -S bleachbit

# IM
yay --noconfirm -S qq-linux
sudo pacman --noconfirm -S electronic-wechat telegram-desktop
# yay --noconfirm -S eepin.com.qq.im deepin.com.qq.office
# yay --noconfirm -S deepin-wine-wechat deepin-wine-tim deepin-wine-qq electronic-wechat-bin

# Markdown
sudo pacman --noconfirm -S vnote-git
# sudo pacman --noconfirm -S typora

# Note
sudo pacman --noconfirm -S leanote
# sudo pacman --noconfirm -S wiznote
# yay --noconfirm -S cherrytree

# Password manager
sudo pacman --noconfirm -S enpass-bin

# PDF Reader
sudo pacman --noconfirm -S evince foxitreader

# Player
sudo pacman --noconfirm -S netease-cloud-music
# sudo pacman --noconfirm -S smplayer smplayer-skins smplayer-themes

# Proxy
# sudo pacman --noconfirm -S proxychains-ng v2ray

# Screenshot
sudo pacman --noconfirm -S deepin-screenshot
# sudo pacman --noconfirm -S xfce4-screenshooter

# Search
sudo pacman --noconfirm -S albert synapse

# System
sudo pacman --noconfirm -S filelight gotop easystroke peek redshift

# Terminal
sudo pacman --noconfirm -S konsole

# # eDEX-UI
# # https://github.com/GitSquared/edex-ui
# # yay --noconfirm -S edex-ui-git
# CHECK_URL="https://api.github.com/repos/GitSquared/edex-ui/releases/latest"
# REMOTE_VERSION=$(wget -qO- $CHECK_URL | grep 'tag_name' | cut -d\" -f4)
# wget -c -O eDEX-UI.AppImage \
#     https://github.com/GitSquared/edex-ui/releases/download/${REMOTE_VERSION}/eDEX-UI.Linux.x86_64.AppImage


# Clean jobs
# sudo pacman -Rns $(pacman -Qtdq)
yay -Yc


# Auto shutdown at 20:00
# (crontab -l 2>/dev/null || true; echo "0 20 * * * sync && shutdown -h now") | crontab -


# Reset curl proxy
if [[ "$CURL_PROXY_CHOICE" == 'y' || "$CURL_PROXY_CHOICE" == 'Y' ]]; then
    read -p "Reset curl socks5 proxy?[Y/n]:" CHOICE
    [[ -z "$CHOICE" ]] && CHOICE=Y
    if [[ "$CHOICE" == 'y' || "$CHOICE" == 'Y' ]]
        sed -i "/^--socks5-hostname.*/d" $HOME/.curlrc
    fi
fi
