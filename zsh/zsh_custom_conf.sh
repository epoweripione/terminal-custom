# Custom ZSH configuration

ostype=$(uname)

# custom PS2
# export PS2="> "


# disable hosts auto completion
zstyle ':completion:*' hosts off


# complete hard drives in MSYS2
if [[ $ostype =~ "MSYS_NT" || $ostype =~ "MINGW" || $ostype =~ "CYGWIN_NT" ]]; then
  drives=$(mount | sed -rn 's#^[A-Z]: on /([a-z]).*#\1#p' | tr '\n' ' ')
  zstyle ':completion:*' fake-files /: "/:$drives"
  unset drives
fi


# aliases
alias zshconfig="nano ~/.zshrc"
alias ohmyzsh="nano ~/.oh-my-zsh"

alias cls='clear'
alias grep="grep --color=auto"
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
alias pipupdateall='pip list -o | grep -E -v '"'"'^-|^Package '"'"' | cut -d '"'"' '"'"' -f 1 | xargs -n1 pip install -U'
alias pip3updateall='pip3 list -o | grep -E -v '"'"'^-|^Package '"'"' | cut -d '"'"' '"'"' -f 1 | xargs -n1 pip3 install -U'

# docker aliases
alias dockerpullall='docker images | grep -v REPOSITORY | awk '"'"'{print $1,$2}'"'"' OFS='"'"':'"'"' | xargs -L1 docker pull'
alias dockerps='docker ps --format "table {{.ID}}\t{{.Image}}\t{{.Status}}\t{{.Names}}"'
alias dockerpsall='docker ps --format "table {{.ID}}\t{{.Image}}\t{{.Status}}\t{{.Names}}\t{{.Ports}}\t{{.Networks}}\t{{.Command}}\t{{.Size}}"'


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


# Extend variable in MSYS2 to use node,npm,php,composer... with winpty
if [[ $ostype =~ "MSYS_NT" || $ostype =~ "MINGW" || $ostype =~ "CYGWIN_NT" ]]; then
  export PATH=$PATH:/c/nodejs:/c/Users/$USERNAME/AppData/Roaming/npm:/c/php/php7:/c/php/composer/vendor/bin

  # node,npm
  alias node="winpty node"
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

  # php,composer
  alias php="winpty php"
  alias composer="winpty composer.bat"
  alias pear="winpty pear.bat"
  alias pear2="winpty pear2.bat"
  alias pecl="winpty pecl.bat"
  alias php-cs-fixer="winpty php-cs-fixer.bat"
  alias php-parse="winpty php-parse.bat"
  alias phpunit="winpty phpunit.bat"
  alias psysh="winpty psysh.bat"
  alias var-dump-server="winpty var-dump-server.bat"

  # Docker
  alias dockertoolbox='exec "$DOCKER_TOOLBOX_INSTALL_PATH/start.sh"'
  alias docker="winpty docker.exe"
  alias docker-machine="winpty docker-machine.exe"
  alias docker-compose="winpty docker-compose.exe"

  # other
  alias wmic="winpty wmic"
fi

# WSL
if [[ $(uname -r) =~ "Microsoft" ]]; then
  # Docker
  if [[ -d "/c/Program Files/Docker Toolbox" ]]; then
    # export PATH="$PATH:/c/Program\ Files/Docker\ Toolbox"
    export DOCKER_TOOLBOX_INSTALL_PATH='/c/Program\ Files/Docker\ Toolbox'

    export WINDOWS_USER=$(/c/Windows/System32/cmd.exe /c 'echo %USERNAME%' | sed -e 's/\r//g')
    export DOCKER_TLS_VERIFY=1
    export DOCKER_HOST=tcp://192.168.99.100:2376
    export DOCKER_CERT_PATH=/c/Users/$WINDOWS_USER/.docker/machine/certs

    alias docker-machine="$DOCKER_TOOLBOX_INSTALL_PATH/docker-machine.exe"
  else
    # export PATH="$PATH:/mnt/c/Program\ Files/Docker/Docker/resources/bin"

    export DOCKER_HOST=tcp://127.0.0.1:2375

    alias docker-machine="/c/Program\ Files/Docker/Docker/resources/bin/docker-machine.exe"
  fi

  # start services upon WSL launch
  if [[ $UID -eq 0 ]]; then
    # libnss-winbind
    if (( $(ps -ef | grep -v grep | grep winbind | wc -l) == 0 )); then
      service winbind start
    fi
  fi
fi
