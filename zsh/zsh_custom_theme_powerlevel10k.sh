# https://github.com/romkatv/powerlevel10k

function set_zle_rprompt_indent() {
  local ostype=$(uname)
  local os_wsl=$(uname -r)

  # MSYS, MINGW, CYGWIN
  if [[ $ostype =~ "MSYS_NT" || $ostype =~ "MINGW" || $ostype =~ "CYGWIN_NT" ]]; then
    ZLE_RPROMPT_INDENT=6
  fi

  # WSL
  [[ "$os_wsl" =~ "Microsoft" ]] && ZLE_RPROMPT_INDENT=6
}

set_zle_rprompt_indent

# POWERLEVEL9K_TIME_FORMAT='%D{%H:%M}'