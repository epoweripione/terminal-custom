#!/bin/bash

ostype=$(uname)

if [[ $ostype == "Darwin" ]]; then
  [ -e ~/hosts ] && rm -f ~/hosts
  curl -fSL https://raw.githubusercontent.com/googlehosts/hosts/master/hosts-files/hosts -o ~/hosts
  [ -e /private/etc/hosts.orig ] || cp /private/etc/hosts /private/etc/hosts.orig && \
  cp /private/etc/hosts /etc/hosts.bak && \
  cp hosts /private/etc/hosts && \
  echo "hosts is up to date!"
elif [[ $ostype =~ "MSYS_NT" || $ostype =~ "MINGW" || $ostype =~ "CYGWIN_NT" ]]; then
  [ -e ~/hosts ] && rm -f ~/hosts
  curl -fSL https://raw.githubusercontent.com/googlehosts/hosts/master/hosts-files/hosts -o ~/hosts
  cp /c/Windows/System32/drivers/etc/hosts /c/Windows/System32/drivers/etc/hosts.bak && \
  rm -f /c/Windows/System32/drivers/etc/hosts && \
  cp ~/hosts /c/Windows/System32/drivers/etc/hosts && \
  winpty ipconfig -flushdns && \
  echo "hosts is up to date!"
else
  [ -e ~/hosts ] && rm -f ~/hosts
  curl -fSL https://raw.githubusercontent.com/googlehosts/hosts/master/hosts-files/hosts -o ~/hosts
  [ -e /etc/hosts.orig ] || cp /etc/hosts /etc/hosts.orig && \
  cp /etc/hosts /etc/hosts.bak && \
  cp hosts /etc/hosts && \
  echo "hosts is up to date!"
fi
