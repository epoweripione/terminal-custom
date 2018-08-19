# Installation
https://github.com/msys2/msys2/wiki/MSYS2-installation

# Reinstallation
https://github.com/msys2/msys2/wiki/MSYS2-reinstallation

# Updating packages
1. Run `pacman -Syuu`. Follow the instructions. 
2. Repeat Run `pacman -Syuu` until it says there are no packages to update.
3. Finally you can do an update of the remaining packages by issuing: `pacman -Suu`

# ConEmu: How to call msys2 as tab?
https://superuser.com/questions/1024301/conemu-how-to-call-msys2-as-tab

# msys2 profile
sed -i "/^  profile_d zsh/a\  SHELL=\"\$(which zsh)\"" /etc/profile
sed -i '$a\\nexport MSYS=\"winsymlinks:lnk\"' /etc/profile

# pacman colors
sed -i "s/#Color/Color/g" /etc/pacman.conf

# pacman mirrors in china
```
sed -i "1iServer = http://mirrors.ustc.edu.cn/msys2/mingw/i686" /etc/pacman.d/mirrorlist.mingw32 && \
  sed -i "1iServer = http://mirrors.ustc.edu.cn/msys2/mingw/x86_64" /etc/pacman.d/mirrorlist.mingw64 && \
  sed -i "1iServer = http://mirrors.ustc.edu.cn/msys2/msys/\$arch" /etc/pacman.d/mirrorlist.msys
```
# Install custom packages
`pacman -S ccache coreutils crypt curl gcc gnu-netcat inetutils iperf3 lftp make man-db man-pages-posix nano openssh p7zip python python3-pip rsync screenfetch unrar unzip upx util-linux whois winpty zip zsh`

# Install git
# `pacman -S git git-extra`

# Install oh-my-zsh
`sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"`
