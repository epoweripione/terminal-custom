#!/usr/bin/env bash

OS_TYPE=$(uname)
DOWNLOAD_URL=https://raw.githubusercontent.com/googlehosts/hosts/master/hosts-files/hosts

[ -e ~/hosts ] && rm -f ~/hosts

[[ -n "${INSTALLER_CHECK_CURL_OPTION}" ]] && curl_check_opts=(`echo ${INSTALLER_CHECK_CURL_OPTION}`) || curl_check_opts=(-fsL)
[[ -n "${INSTALLER_DOWNLOAD_CURL_OPTION}" ]] && curl_download_opts=(`echo ${INSTALLER_DOWNLOAD_CURL_OPTION}`) || curl_download_opts=(-fSL)

if [[ $OS_TYPE == "Darwin" ]]; then
	curl "${curl_download_opts[@]}" $DOWNLOAD_URL -o ~/hosts && \
		[ -e /private/etc/hosts.orig ] || cp /private/etc/hosts /private/etc/hosts.orig && \
		cp /private/etc/hosts /etc/hosts.bak && \
		cp hosts /private/etc/hosts && \
		echo "hosts is up to date!"
elif [[ $OS_TYPE =~ "MSYS_NT" || $OS_TYPE =~ "MINGW" || $OS_TYPE =~ "CYGWIN_NT" ]]; then
	curl "${curl_download_opts[@]}" $DOWNLOAD_URL -o ~/hosts && \
		cp /c/Windows/System32/drivers/etc/hosts /c/Windows/System32/drivers/etc/hosts.bak && \
		rm -f /c/Windows/System32/drivers/etc/hosts && \
		cp ~/hosts /c/Windows/System32/drivers/etc/hosts && \
		winpty ipconfig -flushdns && \
		echo "hosts is up to date!"
else
	curl "${curl_download_opts[@]}" $DOWNLOAD_URL -o ~/hosts && \
		[ -e /etc/hosts.orig ] || cp /etc/hosts /etc/hosts.orig && \
		cp /etc/hosts /etc/hosts.bak && \
		cp hosts /etc/hosts && \
		echo "hosts is up to date!"
fi
