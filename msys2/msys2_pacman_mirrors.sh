#!/bin/bash

sed -i "1iServer = http://mirrors.ustc.edu.cn/msys2/mingw/i686" /etc/pacman.d/mirrorlist.mingw32
sed -i "1iServer = http://mirrors.ustc.edu.cn/msys2/mingw/x86_64" /etc/pacman.d/mirrorlist.mingw64
sed -i "1iServer = http://mirrors.ustc.edu.cn/msys2/msys/\$arch" /etc/pacman.d/mirrorlist.msys
