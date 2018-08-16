# export LANG="en_US.UTF-8"
# export LC_ALL="en_US.UTF-8"
# export LC_CTYPE="en_US.UTF-8"

terminal_colors=$(tput colors)
if [[ $terminal_colors -eq 256 ]]; then
  export TERM="xterm-256color"
  PROMPT_EOL_MARK=""
fi
