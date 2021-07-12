# export LANG="en_US.UTF-8"
# export LC_ALL="en_US.UTF-8"
# export LC_CTYPE="en_US.UTF-8"

# if infocmp xterm-256color >/dev/null 2>&1; then
#     export TERM="xterm-256color"
# elif infocmp screen-256color >/dev/null 2>&1; then
#     export TERM="screen-256color"
# fi

if [[ -z "$TERM" ]]; then
    terminal_colors=$(tput colors)
    if [[ $terminal_colors -eq 256 ]]; then
        export TERM="xterm-256color"
    fi
    unset terminal_colors
fi

# load-nvmrc: use specified node version for the current directory with .nvmrc
NVM_LOAD_NVMRC_IN_CURRENT_DIRECTORY=false

# https://superuser.com/questions/645599/why-is-a-percent-sign-appearing-before-each-prompt-on-zsh-in-windows/645612
export PROMPT_EOL_MARK=""
