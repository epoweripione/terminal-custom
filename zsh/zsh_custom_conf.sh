# Custom ZSH configuration

ostype=$(uname)

# custom PS2
# export PS2="> "


# fix duplicate environment variables "SHELL=/usr/bin/zsh"
if (( $(env | grep SHELL | wc -l) > 1 )); then
    unset SHELL
    export SHELL=$(which zsh)
fi


# compinit
[[ ! -s "$HOME/.zcompdump" ]] && source "$HOME/zsh_compinit.sh"


# disable hosts auto completion
zstyle ':completion:*' hosts off

# custom bindkey
bindkey \^U backward-kill-line

# not confirm a rm *
setopt localoptions rmstarsilent

# # Colors
# autoload -U colors && colors
# export CLICOLOR=1
# export LSCOLORS='gxfxcxdxbxegedabagacad'
# export LS_COLORS="di=36:ln=35:so=32:pi=33:ex=31:bd=34;46:cd=34;43:su=30;41:sg=30;46:tw=30;42:ow=30;43"


# complete hard drives in MSYS2
if [[ $ostype =~ "MSYS_NT" || $ostype =~ "MINGW" || $ostype =~ "CYGWIN_NT" ]]; then
    drives=$(mount | sed -rn 's#^[A-Z]: on /([a-z]).*#\1#p' | tr '\n' ' ')
    zstyle ':completion:*' fake-files /: "/:$drives"
    unset drives
fi


# Load custom functions
if [[ -s "$HOME/custom_functions.sh" ]]; then
    source "$HOME/custom_functions.sh"

    # Set proxy or mirrors env in china
    set_proxy_mirrors_env
fi


# aliases
alias zshconfig="nano ~/.zshrc"
alias ohmyzsh="nano ~/.oh-my-zsh"

alias cls='clear'
alias grep="grep --color=auto"

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

# pip aliases
if [[ -x "$(command -v pip)" ]]; then
    alias pipupdateall='pip list -o | grep -E -v '"'"'^-|^Package '"'"' | cut -d '"'"' '"'"' -f 1 | xargs -n1 pip install -U'
fi

# if [[ -x "$(command -v pip3)" ]]; then
#     alias pip3updateall='pip3 list -o | grep -E -v '"'"'^-|^Package '"'"' | cut -d '"'"' '"'"' -f 1 | xargs -n1 pip3 install -U'
# fi

# docker aliases
if [[ -x "$(command -v docker)" ]]; then
    alias dockerpullall='docker images | grep -v REPOSITORY | awk '"'"'{print $1,$2}'"'"' OFS='"'"':'"'"' | xargs -L1 docker pull'
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
    if [[ -n "$SSH_CLIENT" ]] || [[ -n "$SSH_TTY" ]]; then
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
if [[ $ostype == "Darwin" ]]; then
    if [[ -x "$(command -v greadlink)" ]]; then
        alias readlink=greadlink
    fi
fi


# Extend variable in MSYS2 to use node,npm,php,composer... with winpty
if [[ $ostype =~ "MSYS_NT" || $ostype =~ "MINGW" || $ostype =~ "CYGWIN_NT" ]]; then
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
if [[ -d "/opt/oracle/instantclient_19_3" ]]; then
    export ORACLE_HOME="/opt/oracle/instantclient_19_3"
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
        if [[ -n "$CURRENT_VERSION" ]]; then
            gvm use $CURRENT_VERSION --default >/dev/null 2>&1
        fi
    fi

    if [[ -z "$GOBIN" && -n "$GOROOT" ]]; then
        export GOBIN=$GOROOT/bin
    fi
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

# anaconda3
if [[ -d "$HOME/anaconda3/bin" ]]; then
    export PATH=$PATH:$HOME/anaconda3/bin
fi


# miniconda3
if [[ -d "$HOME/miniconda3/bin" ]]; then
    export PATH=$PATH:$HOME/miniconda3/bin
    # source $HOME/miniconda3/bin/activate
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


# proxychains4 aliases
if [[ -x "$(command -v proxychains4)" ]]; then
    alias proxywan='proxychains4'
    alias proxylan='proxychains4 -f /etc/proxychains/proxychains_lan.conf'
fi


# multi-v2ray
if [[ -d "/usr/local/multi-v2ray" ]]; then
    if [[ -z "$PYTHONPATH" ]]; then
        export PYTHONPATH=/usr/local/multi-v2ray
    else
        export PYTHONPATH=$PYTHONPATH:/usr/local/multi-v2ray
    fi
    export PYTHONIOENCODING=utf-8
fi


# lazydocker aliases
if [[ -x "$(command -v lazydocker)" ]]; then
    alias lzd='lazydocker' 
fi


# WSL
if [[ $(uname -r) =~ "Microsoft" ]]; then
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


    # start services upon WSL launch
    if [[ $UID -eq 0 ]]; then
        # libnss-winbind
        if (( $(ps -ef | grep -v grep | grep winbind | wc -l) == 0 )); then
            if systemctl list-unit-files --type=service 2>&1 | grep winbind.service | grep enabled; then
                service winbind start
            fi
        fi
    fi
fi
