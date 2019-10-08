# https://github.com/romkatv/powerlevel10k

ostype=$(uname)


# POWERLEVEL9K_TIME_FORMAT='%D{%H:%M}'

if [[ $ostype =~ "MSYS_NT" || $ostype =~ "MINGW" || $ostype =~ "CYGWIN_NT" ]]; then
  ZLE_RPROMPT_INDENT=6
fi