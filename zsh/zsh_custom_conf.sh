# Custom ZSH configuration

export MY_SHELL_SCRIPTS="${MY_SHELL_SCRIPTS:-$HOME/terminal-custom}"

OS_TYPE=$(uname)
OS_WSL=$(uname -r)

# custom PS2
# export PS2="> "


# fix duplicate environment variables "SHELL=/usr/bin/zsh"
if (( $(env | grep SHELL | wc -l) > 1 )); then
    unset SHELL
    export SHELL=$(which zsh)
fi


# compinit
# source "${MY_SHELL_SCRIPTS}/zsh/zsh_compinit.sh"

### Fix slowness of pastes with zsh-syntax-highlighting.zsh
### https://github.com/zsh-users/zsh-autosuggestions/issues/238#issuecomment-389324292
pasteinit() {
    OLD_SELF_INSERT=${${(s.:.)widgets[self-insert]}[2,3]}
    zle -N self-insert url-quote-magic # I wonder if you'd need `.url-quote-magic`?
}

pastefinish() {
    zle -N self-insert $OLD_SELF_INSERT
}
zstyle :bracketed-paste-magic paste-init pasteinit
zstyle :bracketed-paste-magic paste-finish pastefinish
### Fix slowness of pastes

# disable hosts auto completion
zstyle ':completion:*' hosts off

# custom bindkey
bindkey \^U backward-kill-line

# bind the Control-P/N keys for zsh-history-substring-search
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
bindkey -M emacs '^P' history-substring-search-up
bindkey -M emacs '^N' history-substring-search-down

# not confirm a rm *
setopt localoptions rmstarsilent

# # Colors
# autoload -U colors && colors
# export CLICOLOR=1
# export LSCOLORS='gxfxcxdxbxegedabagacad'
# export LS_COLORS="di=36:ln=35:so=32:pi=33:ex=31:bd=34;46:cd=34;43:su=30;41:sg=30;46:tw=30;42:ow=30;43"


# complete hard drives in MSYS2
if [[ "$OS_TYPE" =~ "MSYS_NT" || "$OS_TYPE" =~ "MINGW" || "$OS_TYPE" =~ "CYGWIN_NT" ]]; then
    drives=$(mount | sed -rn 's#^[A-Z]: on /([a-z]).*#\1#p' | tr '\n' ' ')
    zstyle ':completion:*' fake-files /: "/:$drives"
    unset drives
fi


# Load custom functions
if [[ -s "${MY_SHELL_SCRIPTS}/custom_functions.sh" ]]; then
    source "${MY_SHELL_SCRIPTS}/custom_functions.sh"

    # Use proxy or mirror when some sites were blocked or low speed
    set_proxy_mirrors_env

    # Check & set global proxy
    [[ -z "$GITHUB_NOT_USE_PROXY" ]] && check_set_global_proxy 7891 7890
fi


# aliases
alias zshconfig="nano ~/.zshrc"
alias ohmyzsh="nano ~/.oh-my-zsh"

alias cls='clear'
alias grep="grep --color=auto"

# most used history commands
alias histop="awk -F';' '{print $2}' ${HISTFILE} | sort | uniq -c | sort -rn"
alias histop20="awk -F';' '{print $2}' ${HISTFILE} | sort | uniq -c | sort -rn | head -n20"

# Auto files
# alias -s html='nano'
# alias -s php='nano'
# alias -s rb='nano'
# alias -s py='nano'
# alias -s js='nano'
# alias -s c='nano'
# alias -s java='nano'
# alias -s txt='nano'
# alias -s gz='tar -xzvf'
# alias -s tgz='tar -xzvf'
# alias -s zip='unzip'
# alias -s bz2='tar -xjvf'

# docker aliases
if [[ -x "$(command -v docker)" ]]; then
    alias dockerpullall='docker images | grep -Ev "REPOSITORY|<none>" | awk '"'"'{print $1,$2}'"'"' OFS='"'"':'"'"' | xargs -L1 docker pull'
    alias dockerps='docker ps --format "table {{.ID}}\t{{.Image}}\t{{.Status}}\t{{.Names}}"'
    alias dockerpsall='docker ps --format "table {{.ID}}\t{{.Image}}\t{{.Status}}\t{{.Names}}\t{{.Ports}}\t{{.Networks}}\t{{.Command}}\t{{.Size}}"'
fi


# zsh-command-time
# If command execution time above min. time, plugins will not output time.
ZSH_COMMAND_TIME_MIN_SECONDS=3

# Message to display (set to "" for disable).
# → Execution time: ←
if [[ "$DISABLE_ZSH_COMMAND_TIME_MSG" == true ]]; then
    ZSH_COMMAND_TIME_MSG=""
else
    ZSH_COMMAND_TIME_MSG=" \u2192 Execution time: %s \u2190"

    # Message color.
    if [[ -n "$SSH_CLIENT" || -n "$SSH_TTY" ]]; then
        ZSH_COMMAND_TIME_COLOR="magenta"
    else
        if [[ $UID -eq 0 ]]; then
            ZSH_COMMAND_TIME_COLOR="red"
        else
            ZSH_COMMAND_TIME_COLOR="yellow"
        fi
    fi
fi


# rlwarp alias
if [[ -x "$(command -v telnet)" && -x "$(command -v rlwrap)" ]]; then
    alias telnet="rlwrap telnet"
fi


# macOS
if [[ "$OS_TYPE" == "Darwin" ]]; then
    if [[ -x "$(command -v greadlink)" ]]; then
        alias readlink=greadlink
    fi
fi


# Extend variable in MSYS2 to use node,npm,php,composer... with winpty
if [[ "$OS_TYPE" =~ "MSYS_NT" || "$OS_TYPE" =~ "MINGW" || "$OS_TYPE" =~ "CYGWIN_NT" ]]; then
    export PATH=$PATH:/c/nodejs:/c/Users/$USERNAME/AppData/Roaming/npm:/c/php/php7:/c/php/composer/vendor/bin

    # dotnet
    if [[ "$(command -v dotnet.exe)" ]]; then
        alias dotnet="winpty dotnet.exe"
    fi

    #java
    if [[ "$(command -v java.exe)" ]]; then
        alias java="winpty java.exe"
        alias java="winpty javac.exe"
    fi

    # node,npm
    if [[ "$(command -v node.exe)" ]]; then
        alias node="winpty node.exe"
        alias npm="winpty npm.cmd"
        alias electron="winpty electron.cmd"
        alias es-checker="winpty es-checker.cmd"
        alias eslint="winpty eslint.cmd"
        alias ionic="winpty ionic.cmd"
        alias jshint="winpty jshint.cmd"
        alias ng="winpty ng.cmd"
        alias npm-check="winpty npm-check.cmd"
        alias npx="winpty npx.cmd"
        alias nrm="winpty nrm.cmd"
        alias parcel="winpty parcel.cmd"
        alias schematics="winpty schematics.cmd"
        alias standard="winpty standard.cmd"
        alias tsc="winpty tsc.cmd"
        alias tslint="winpty tslint.cmd"
        alias tsserver="winpty tsserver.cmd"
    fi

    # php,composer
    if [[ "$(command -v php.exe)" ]]; then
        alias php="winpty php.exe"
        alias composer="winpty composer.bat"
        alias pear="winpty pear.bat"
        alias pear2="winpty pear2.bat"
        alias pecl="winpty pecl.bat"
        alias php-cs-fixer="winpty php-cs-fixer.bat"
        alias php-parse="winpty php-parse.bat"
        alias phpunit="winpty phpunit.bat"
        alias psysh="winpty psysh.bat"
        alias var-dump-server="winpty var-dump-server.bat"
    fi

    # Docker
    if [[ -n "$DOCKER_TOOLBOX_INSTALL_PATH" ]]; then
        alias dockertoolbox='exec "$DOCKER_TOOLBOX_INSTALL_PATH/start.sh"'
    fi

    if [[ "$(command -v docker.exe)" ]]; then
        alias docker="winpty docker.exe"
        alias docker-compose="winpty docker-compose.exe"
    fi

    if [[ "$(command -v docker-machine.exe)" ]]; then
        alias docker-machine="winpty docker-machine.exe"
    fi

    # other
    alias wmic="winpty wmic"
fi


# Oracle Instant Client
if [[ -d "/opt/oracle/instantclient_21_1" ]]; then
    export ORACLE_HOME="/opt/oracle/instantclient_21_1"
elif [[ -d "/opt/oracle/instantclient_19_10" ]]; then
    export ORACLE_HOME="/opt/oracle/instantclient_19_10"
elif [[ -d "/opt/oracle/instantclient_18_5" ]]; then
    export ORACLE_HOME="/opt/oracle/instantclient_18_5"
elif [[ -d "/opt/oracle/instantclient_18_3" ]]; then
    export ORACLE_HOME="/opt/oracle/instantclient_18_3"
elif [[ -d "/opt/oracle/instantclient_12_2" ]]; then
    export ORACLE_HOME="/opt/oracle/instantclient_12_2"
fi

if [[ -n "$ORACLE_HOME" ]]; then
    if [[ -z "$LD_LIBRARY_PATH" ]]; then
        export LD_LIBRARY_PATH=$ORACLE_HOME
    else
        export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$ORACLE_HOME
    fi

    export PATH=$PATH:$ORACLE_HOME

    if [[ -x "$(command -v rlwrap)" ]]; then
        alias sqlplus="rlwrap sqlplus"
        alias rman="rlwrap rman"
        alias asmcmd="rlwrap asmcmd"
        alias ggsci="rlwrap ggsci"
    fi
fi

# starship
if [[ -x "$(command -v starship)" ]]; then
    get_os_icon

    ICON_OS_SSH_SCREEN_TMUX="${OS_INFO_ICON}"
    [[ -n "$SSH_CLIENT" || -n "$SSH_TTY" ]] && ICON_OS_SSH_SCREEN_TMUX="${ICON_OS_SSH_SCREEN_TMUX} "
    [[ -n "$STY" ]] && ICON_OS_SSH_SCREEN_TMUX="${ICON_OS_SSH_SCREEN_TMUX} 🖵"
    [[ -n "$TMUX" ]] && ICON_OS_SSH_SCREEN_TMUX="${ICON_OS_SSH_SCREEN_TMUX}離"

    export ICON_OS_SSH_SCREEN_TMUX="${ICON_OS_SSH_SCREEN_TMUX}"

    if [[ ! -s "$HOME/.config/starship.toml" ]]; then
        cp -f "${MY_SHELL_SCRIPTS:-$HOME/terminal-custom}/zsh/themes/starship.toml" "$HOME/.config"
    fi
fi

# homebrew
if [[ -x "$(command -v brew)" ]]; then
    if [[ -z "$BREW_NOT_USE_PROXY" ]]; then
        export HOMEBREW_BOTTLE_DOMAIN=https://mirrors.ustc.edu.cn/homebrew-bottles
    fi
fi

# exa
if [[ -x "$(command -v exa)" ]]; then
    alias exal="exa -aghl --icons --git --time-style=long-iso"
    alias exaa="exa -abghHliS --icons --git --time-style=long-iso"
    alias exat="exa --tree --icons"
fi

# PHP
if [[ -x "$(command -v php)" ]]; then
    export PHP_INI_DIR=$(php --ini | grep "Scan for additional .ini files in" | cut -d':' -f2 | cut -d' ' -f2)
fi

if [[ -x "$(command -v php-config)" ]]; then
    export PHP_EXT_DIR=$(php-config --extension-dir)
fi

# composer
if [[ -x "$(command -v composer)" ]]; then
    export COMPOSER_ALLOW_SUPERUSER=1
    export COMPOSER_HOME=/usr/local/share/composer
    export PATH=$PATH:/usr/local/share/composer/vendor/bin
fi

# gvm
if [[ -d "$HOME/.gvm" ]]; then
    ENV_PATH_OLD=$PATH

    if type 'gvm' 2>/dev/null | grep -q 'function'; then
        :
    else
        [[ -s "$HOME/.gvm/scripts/gvm" ]] && source "$HOME/.gvm/scripts/gvm"
    fi

    if [[ "$(gvm list | grep 'go1.4')" ]]; then
        CURRENT_VERSION=$(gvm list | grep '=>' | cut -d' ' -f2)

        # Set GOROOT_BOOTSTRAP to compile Go 1.5+
        gvm use go1.4 >/dev/null 2>&1
        export GOROOT_BOOTSTRAP=$GOROOT

        # Set default go version
        [[ -n "$CURRENT_VERSION" ]] && gvm use $CURRENT_VERSION --default >/dev/null 2>&1
    fi

    # fix (maybe) break PATH
    ENV_PATH_GO=$PATH
    export PATH=${ENV_PATH_OLD}
    if [[ ":$ENV_PATH_GO:" != *":$ENV_PATH_OLD:"* ]]; then
        ENV_PATH_GO=$(echo "$ENV_PATH_GO" | sed 's/:$//')
        [[ -n "${ENV_PATH_GO}" ]] && export PATH=${ENV_PATH_GO}:${ENV_PATH_OLD}
    fi

    # GOBIN
    [[ -z "$GOBIN" && -n "$GOROOT" ]] && export GOBIN=$GOROOT/bin

    unset ENV_PATH_GO
    unset ENV_PATH_OLD
fi

# goup
if [[ -d "$HOME/.go" ]]; then
    if [[ -z "$GO_INSTALLER_NOT_USE_PROXY" ]]; then
        export GOUP_GO_HOST=golang.google.cn
        alias goupInstall='http_proxy=${http_proxy/socks5h/socks5} \
                            https_proxy=${https_proxy/socks5h/socks5} \
                            ftp_proxy=${ftp_proxy/socks5h/socks5} \
                            all_proxy=${all_proxy/socks5h/socks5} \
                            HTTP_PROXY=${HTTP_PROXY/socks5h/socks5} \
                            HTTPS_PROXY=${HTTPS_PROXY/socks5h/socks5} \
                            FTP_PROXY=${FTP_PROXY/socks5h/socks5} \
                            ALL_PROXY=${ALL_PROXY/socks5h/socks5} \
                            goup install'
        alias goupUpgrade='http_proxy=${http_proxy/socks5h/socks5} \
                            https_proxy=${https_proxy/socks5h/socks5} \
                            ftp_proxy=${ftp_proxy/socks5h/socks5} \
                            all_proxy=${all_proxy/socks5h/socks5} \
                            HTTP_PROXY=${HTTP_PROXY/socks5h/socks5} \
                            HTTPS_PROXY=${HTTPS_PROXY/socks5h/socks5} \
                            FTP_PROXY=${FTP_PROXY/socks5h/socks5} \
                            ALL_PROXY=${ALL_PROXY/socks5h/socks5} \
                            goup upgrade'
    else
        alias goupInstall='goup install'
        alias goupUpgrade='goup upgrade'
    fi

    [[ ":$PATH:" != *":$HOME/.go/bin:"* ]] && export PATH=$PATH:$HOME/.go/bin:$HOME/.go/current/bin
fi

# go
if [[ -x "$(command -v go)" ]]; then
    [[ -z "$GOBIN" && -n "$GOROOT" ]] && export GOBIN=$GOROOT/bin
    # go module
    GO_VERSION=$(go version | cut -d' ' -f3)
    if version_ge $GO_VERSION 'go1.13'; then
        go env -w GO111MODULE=on
        [[ -z "$GO_INSTALLER_NOT_USE_PROXY" ]] && go env -w GOPROXY="https://goproxy.io,direct"
    else
        export GO111MODULE=on
        [[ -z "$GO_INSTALLER_NOT_USE_PROXY" ]] && export GOPROXY="https://goproxy.io"
    fi
fi

# rustup
if [[ -z "$RUST_NOT_USE_PROXY" && -x "$(command -v rustup)" ]]; then
    export RUSTUP_DIST_SERVER=https://mirrors.tuna.tsinghua.edu.cn/rustup
fi

# jabba
if [[ -d "$HOME/.jabba" ]]; then
    if type 'jabba' 2>/dev/null | grep -q 'function'; then
        :
    else
        [[ -s "$HOME/.jabba/jabba.sh" ]] && source "$HOME/.jabba/jabba.sh"
    fi
fi

# java
if [[ -x "$(command -v java)" ]]; then
    if [[ -z "$JAVA_HOME" ]]; then
        export JAVA_HOME=$(readlink -f $(which java) | sed "s:/jre/bin/java::" | sed "s:/bin/java::")
        if [[ -d "$JAVA_HOME/jre" ]]; then
            export JRE_HOME=$JAVA_HOME/jre
        fi
        export CLASSPATH=$JAVA_HOME/lib
        export PATH=$PATH:$JAVA_HOME/bin
    else
        if [[ -z "$CLASSPATH" ]]; then
            export CLASSPATH=$JAVA_HOME/lib
        fi
    fi
fi

# # anaconda3
# if [[ -d "$HOME/anaconda3/bin" ]]; then
#     export PATH=$PATH:$HOME/anaconda3/condabin
# fi

# # miniconda3
# if [[ -d "$HOME/miniconda3/bin" ]]; then
#     export PATH=$PATH:$HOME/miniconda3/condabin
#     # source $HOME/miniconda3/bin/activate
# fi

# pip local install
if [[ -d "$HOME/.local/bin" ]]; then
    export PATH=$PATH:$HOME/.local/bin
fi

# pip aliases
if [[ -x "$(command -v pip)" ]]; then
    alias pipupdateall='pip list -o | grep -Ev "^-|^Package" | cut -d" " -f1 | xargs -n1 pip install -U'
    # alias pipupdateall='pip list -o | grep -Ev '"'"'^-|^Package '"'"' | cut -d '"'"' '"'"' -f1 | xargs -n1 pip install -U'
fi

# nvs
if [[ -d "$HOME/.nvs" ]]; then
    if type 'nvs' 2>/dev/null | grep -q 'function'; then
        :
    else
        export NVS_HOME="$HOME/.nvs"
        [ -s "$NVS_HOME/nvs.sh" ] && . "$NVS_HOME/nvs.sh"
    fi

    # if [[ -z "$NVS_INSTALLER_NOT_USE_MIRROR" ]]; then
    #     nvs remote node https://npm.taobao.org/mirrors/node/
    # fi
fi

# nvm
if [[ -d "$HOME/.nvm" ]]; then
    if type 'nvm' 2>/dev/null | grep -q 'function'; then
        :
    else
        export NVM_DIR="$HOME/.nvm"
        source "$NVM_DIR/nvm.sh"
        # export NVM_DIR="${XDG_CONFIG_HOME:-$HOME}/.nvm"
        # [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    fi

    if [[ -z "$NVM_INSTALLER_NOT_USE_MIRROR" ]]; then
        export NVM_NODEJS_ORG_MIRROR=https://npm.taobao.org/mirrors/node
    fi

    if [[ "$NVM_LOAD_NVMRC_IN_CURRENT_DIRECTORY" == true ]]; then
        # use specified node version for the current directory with .nvmrc
        # echo "lts/*" > .nvmrc # to default to the latest LTS version
        # echo "node" > .nvmrc # to default to the latest version
        autoload -U add-zsh-hook
        load-nvmrc() {
                local node_version="$(nvm version)"
                local nvmrc_path="$(nvm_find_nvmrc)"

                if [[ -n "$nvmrc_path" ]]; then
                        local nvmrc_node_version=$(nvm version "$(cat "${nvmrc_path}")")

                        if [[ "$nvmrc_node_version" == "N/A" ]]; then
                                nvm install
                        elif [[ "$nvmrc_node_version" != "$node_version" ]]; then
                                nvm use
                        fi
                elif [[ "$node_version" != "$(nvm version default)" ]]; then
                        # echo "Reverting to nvm default version"
                        nvm use default
                fi
        }
        add-zsh-hook chpwd load-nvmrc
        load-nvmrc
    fi
fi

# npm global
if [[ -d "$HOME/.npm-global" ]]; then
    export PATH=$HOME/.npm-global/bin:$PATH
fi

# sdkman
if [[ -d "$HOME/.sdkman" ]]; then
    if type 'sdk' 2>/dev/null | grep -q 'function'; then
        :
    else
        export SDKMAN_DIR="$HOME/.sdkman"
        [[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
    fi
fi

# lazydocker aliases
if [[ -x "$(command -v lazydocker)" ]]; then
    alias lzd='lazydocker' 
fi

# navi
if [[ -x "$(command -v navi)" ]]; then
    source "$(navi widget zsh)"
fi

# URL encode/decode
# https://love2dev.com/blog/whats-the-difference-between-encodeuri-and-encodeuricomponent/
# usage
# echo -n "https://www.google.com/search?q=网址转中文" | encodeURI
# echo -n "https://www.google.com/search?q=%E7%BD%91%E5%9D%80%E8%BD%AC%E4%B8%AD%E6%96%87" | decodeURI
# echo -n "网址转中文" | encodeURIComponent
# echo -n "https://www.google.com/search?q=%E7%BD%91%E5%9D%80%E8%BD%AC%E4%B8%AD%E6%96%87" | decodeURIComponent
if [[ -x "$(command -v node)" ]]; then
    alias encodeURI="node -e \"process.stdin.on('data', data => process.stdout.write(encodeURI(data.toString())))\""
    alias decodeURI="node -e \"process.stdin.on('data', data => process.stdout.write(decodeURI(data.toString())))\""
    alias encodeURIComponent="node -e \"process.stdin.on('data', data => process.stdout.write(encodeURIComponent(data.toString())))\""
    alias decodeURIComponent="node -e \"process.stdin.on('data', data => process.stdout.write(decodeURIComponent(data.toString())))\""
else
    alias encodeURIComponent="xxd -p | tr -d '\n' | sed 's/\(..\)/%\1/g'"
    alias decodeURIComponent="sed 's/%/\\\\x/g' | xargs -0 printf '%b'"
fi

# WSL1
if [[ "$OS_WSL" =~ "Microsoft" ]]; then
    # Docker
    if [[ -d "/c/Program Files/Docker Toolbox" ]]; then
        # export PATH="$PATH:/c/Program\ Files/Docker\ Toolbox"
        export DOCKER_TOOLBOX_INSTALL_PATH='/c/Program\ Files/Docker\ Toolbox'

        export WINDOWS_USER=$(/c/Windows/System32/cmd.exe /c 'echo %USERNAME%' | sed -e 's/\r//g')
        # export WINDOWS_USER=$(/c/Windows/System32/cmd.exe /c "whoami" | sed -E s/'^.+\\([^\\]*)$'/'\1'/)
        export DOCKER_TLS_VERIFY=1
        export DOCKER_HOST=tcp://192.168.99.100:2376
        export DOCKER_CERT_PATH=/c/Users/$WINDOWS_USER/.docker/machine/certs

        alias docker-machine="$DOCKER_TOOLBOX_INSTALL_PATH/docker-machine.exe"
    elif [[ -d "/c/Program Files/Docker/Docker" ]]; then
        # export PATH="$PATH:/mnt/c/Program\ Files/Docker/Docker/resources/bin"
        export DOCKER_INSTALL_PATH='/c/Program\ Files/Docker/Docker'

        export DOCKER_HOST=tcp://127.0.0.1:2375

        alias docker-machine="$DOCKER_INSTALL_PATH/resources/bin/docker-machine.exe"
    fi
fi

# WSL1 & WSL2
if [[ "$OS_WSL" =~ "Microsoft" || "$OS_WSL" =~ "microsoft" ]]; then
    ## start services upon WSL launch: libnss-winbind
    # if (( $(ps -ef | grep -v grep | grep winbind | wc -l) == 0 )); then
    #     [[ $(systemctl is-enabled winbind 2>/dev/null) ]] && \
    #         sudo service winbind start
    #     # if systemctl list-unit-files --type=service | grep "winbind.service" | grep "enabled" >/dev/null 2>&1; then
    #     #     service winbind start
    #     # fi
    # fi

    ## fast-syntax-highlighting: fix Segmentation fault (core dumped) when input char -
    ## https://github.com/zdharma/fast-syntax-highlighting/issues/108
    # FAST_HIGHLIGHT[chroma-git]="chroma/-ogit.ch"

    # get local weather
    get_weather_custom
fi

# fzf
if [[ -x "$(command -v fzf)" ]]; then
    # use fd to generate input for fzf
    if [[ -x "$(command -v fd)" ]]; then
        # export FZF_DEFAULT_COMMAND='fd --type file'
        export FZF_DEFAULT_COMMAND="fd --type file --color=always"
        export FZF_DEFAULT_OPTS="--ansi"
        export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
    fi

    # fzf-tab-completion
    # https://github.com/lincheney/fzf-tab-completion
    if [[ -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/fzf-tab-completion" ]]; then
        source "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/fzf-tab-completion/zsh/fzf-zsh-completion.sh"
        bindkey '^I' fzf_completion
    fi

    # Utility tool for using git interactively
    # https://github.com/wfxr/forgit
    if [[ -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/forgit" ]]; then
        forgit_log=fzf-glo
        forgit_diff=fzf-gd
        forgit_add=fzf-ga
        forgit_reset_head=fzf-grh
        forgit_ignore=fzf-gi
        forgit_checkout_file=fzf-gcf
        forgit_checkout_branch=fzf-gcb
        forgit_checkout_commit=fzf-gco
        forgit_clean=fzf-gclean
        forgit_stash_show=fzf-gss
        forgit_cherry_pick=fzf-gcp
        forgit_rebase=fzf-grb
        forgit_fixup=fzf-gfu

        source "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/forgit/forgit.plugin.zsh"
    fi

    # Better git diffs with FZF
    # https://medium.com/@GroundControl/better-git-diffs-with-fzf-89083739a9cb
    function fzf-git-diff() {
        ## only work from the root of your git project
        ## comparing your current branch to master
        # fzf-git-diff master...
        ## comparing the changes between two commits
        #fzf-git-diff 4c674950..6d88a7bfd8
        local preview="git diff $@ --color=always -- {-1}"
        git diff $@ --name-only | fzf -m --preview $preview
    }

    # fzf alias
    alias fzf-cat='fzf --height 50% --layout=reverse --preview-window=right,70% --preview "cat {}"'

    alias fzf-file='fzf --height 50% --layout reverse --info inline --border \
                    --preview "file {}" --preview-window up,1,border-horizontal \
                    --color "fg:#bbccdd,fg+:#ddeeff,bg:#334455,preview-bg:#223344,border:#778899"'

    if [[ -x "$(command -v bat)" ]]; then
        alias bat-themes='bat --list-themes | fzf --preview="bat --theme={} --color=always ${ZSH}/oh-my-zsh.sh"'
        alias fzf-bat='fzf --height 50% --layout=reverse --preview-window=right,70% \
                        --preview "bat --theme=TwoDark --style=numbers --color=always --line-range :500 {}"'
    fi
fi

# Autostart Tmux/screen Session On Remote System When Logging In Via SSH
if [[ -n "$SSH_CLIENT" || -n "$SSH_TTY" ]]; then
    if [[ "$(command -v tmux)" ]]; then
        newTmuxSession
    elif [[ -x "$(command -v screen)" ]]; then
        newScreenSession
    fi
fi
