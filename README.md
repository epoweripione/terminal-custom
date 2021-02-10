# terminal-custom
custom scripts for zsh, msys2, powershell, wsl, etc.


## How to custom ZSH
[zsh official website](http://zsh.sourceforge.net)  
[zsh install guide](https://github.com/robbyrussell/oh-my-zsh/wiki/Installing-ZSH)  
[oh-my-zsh](https://ohmyz.sh/)

### 1. Install `curl`

### 2. Clone repo
`source <(curl -fsSL https://git.io/fNpeJ)`

### 3. Install ZSH & Oh My ZSH (debian/ubuntu/redhat/centos/archlinux)
`$HOME/terminal-custom/zsh/zsh_installer.sh`

### 4. Change default shell to zsh
`chsh -s $(which zsh)`
### 5. Init
`$HOME/terminal-custom/zsh/zsh_upgrade_all_packages.sh && $HOME/terminal-custom/zsh/zsh_init.sh`

## Update
`source <(curl -fsSL https://git.io/fNpeJ) && $HOME/terminal-custom/zsh/zsh_upgrade_all_packages.sh`
