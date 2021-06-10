#!/usr/bin/env bash

# Load custom functions
if type 'colorEcho' 2>/dev/null | grep -q 'function'; then
    :
else
    if [[ -s "${MY_SHELL_SCRIPTS:-$HOME/terminal-custom}/custom_functions.sh" ]]; then
        source "${MY_SHELL_SCRIPTS:-$HOME/terminal-custom}/custom_functions.sh"
    else
        echo "${MY_SHELL_SCRIPTS:-$HOME/terminal-custom}/custom_functions.sh not exist!"
        exit 0
    fi
fi


## shell-safe-rm
## https://github.com/kaelzhang/shell-safe-rm
## rm_is_safe
## https://github.com/malongshuai/rm_is_safe
function install_shell-safe-rm() {
    SHELL_SAFE_RM="$HOME/.shell-safe-rm"
    [[ ! -s "${SHELL_SAFE_RM}/bin/rm.sh" ]] && Git_Clone_Update "kaelzhang/shell-safe-rm" "${SHELL_SAFE_RM}"

    if [[ -s "${SHELL_SAFE_RM}/bin/rm.sh" ]]; then
        sudo /bin/cp -f "${SHELL_SAFE_RM}/bin/rm.sh" "/bin/rm.sh" && sudo chmod +x "/bin/rm.sh"
        # alias rm='/bin/rm.sh'
    fi

    if [[ -s "/bin/rm.sh" ]]; then
        # bash
        # BASH_ENV
        # https://stackoverflow.com/a/20713296
        BASHENV_FILE="/etc/bashenv"
        if ! grep -q 'shopt -s expand_aliases extglob xpg_echo' "${BASHENV_FILE}" >/dev/null 2>&1; then
            echo -e '\n# == Setup for all shells ==' | sudo tee -a "${BASHENV_FILE}" >/dev/null
            echo '# This is executed for all interactive and for non-interactive shells (e.g. scripts)' | sudo tee -a "${BASHENV_FILE}" >/dev/null
            echo 'shopt -s expand_aliases extglob xpg_echo' | sudo tee -a "${BASHENV_FILE}" >/dev/null
            echo -e '\n# == General aliases ==' | sudo tee -a "${BASHENV_FILE}" >/dev/null
            echo "[[ -s \"/bin/rm.sh\" ]] && alias rm='/bin/rm.sh'" | sudo tee -a "${BASHENV_FILE}" >/dev/null
        fi

        BASHENV_SH_FILE="/etc/profile"
        if ! grep -q 'export BASH_ENV' "${BASHENV_SH_FILE}" >/dev/null 2>&1; then
            echo -e '\n# == Environment for all shells ==' | sudo tee -a "${BASHENV_SH_FILE}" >/dev/null
            echo "[[ -s \"${BASHENV_FILE}\" ]] && export BASH_ENV=${BASHENV_FILE} && . \$BASH_ENV" | sudo tee -a "${BASHENV_SH_FILE}" >/dev/null
        fi

        # zsh
        [[ -d "/etc/zsh" ]] && ZSHENV_FILE="/etc/zsh/zshenv" || ZSHENV_FILE="/etc/zshenv"
        if [[ -s "${ZSHENV_FILE}" ]]; then
            if ! grep -q '/bin/rm.sh' "${ZSHENV_FILE}" >/dev/null 2>&1; then
                echo -e '\n# shell-safe-rm' | sudo tee -a "${ZSHENV_FILE}" >/dev/null
                echo "[[ -s \"/bin/rm.sh\" ]] && alias rm='/bin/rm.sh'" | sudo tee -a "${ZSHENV_FILE}" >/dev/null

                echo -e '\n# BASH_ENV' | sudo tee -a "${ZSHENV_FILE}" >/dev/null
                echo "[[ -s \"${BASHENV_FILE}\" ]] && export BASH_ENV=${BASHENV_FILE}" | sudo tee -a "${ZSHENV_FILE}" >/dev/null
            fi
        fi
    fi
}


## Safe-rm
## https://launchpad.net/safe-rm
## /etc/safe-rm.conf
## /usr/local/etc/safe-rm.conf
## ~/.config/safe-rm
# Git_Clone_Update "safe-rm" "$HOME/safe-rm" "git://git.launchpad.net/safe-rm"

## fork: https://github.com/epoweripione/safe-rm
## /etc/safe-rm.toml
## SAFE_RM_REAL_RM_BINARY
APP_INSTALL_NAME="safe-rm"
GITHUB_REPO_NAME="epoweripione/safe-rm"

ARCHIVE_EXT="tar.gz"
ARCHIVE_EXEC_DIR="safe-rm-*"
ARCHIVE_EXEC_NAME="safe-rm"

EXEC_INSTALL_PATH="/usr/local/bin"
EXEC_INSTALL_NAME="safe-rm"

[[ -z "${ARCHIVE_EXEC_NAME}" ]] && ARCHIVE_EXEC_NAME="${EXEC_INSTALL_NAME}"

DOWNLOAD_FILENAME="${WORKDIR}/${EXEC_INSTALL_NAME}"
[[ -n "${ARCHIVE_EXT}" ]] && DOWNLOAD_FILENAME="${DOWNLOAD_FILENAME}.${ARCHIVE_EXT}"

REMOTE_SUFFIX=""
REMOTE_FILENAME=""

IS_INSTALL="yes"
IS_UPDATE="no"

CURRENT_VERSION="0.0.0"
VERSION_FILENAME="${EXEC_INSTALL_PATH}/${EXEC_INSTALL_NAME}.version"

if [[ -x "$(command -v ${EXEC_INSTALL_NAME})" ]]; then
    IS_UPDATE="yes"
    [[ -n "${VERSION_FILENAME}" ]] && CURRENT_VERSION=$(head -n1 ${VERSION_FILENAME})
else
    [[ "${IS_UPDATE_ONLY}" == "yes" ]] && IS_INSTALL="no"
fi

if [[ "${IS_INSTALL}" == "yes" ]]; then
    colorEcho "${BLUE}Checking latest version for ${FUCHSIA}${APP_INSTALL_NAME}${BLUE}..."

    CHECK_URL="https://api.github.com/repos/${GITHUB_REPO_NAME}/releases/latest"
    REMOTE_VERSION=$(curl -fsL $CHECK_URL | grep 'tag_name' | cut -d\" -f4 | cut -d'v' -f2)
    if version_le $REMOTE_VERSION $CURRENT_VERSION; then
        IS_INSTALL="no"
    fi
fi

if [[ "${IS_INSTALL}" == "yes" ]]; then
    [[ -z "${OS_INFO_TYPE}" ]] && get_os_type
    [[ -z "${OS_INFO_ARCH}" ]] && get_arch

    case "$OS_INFO_TYPE" in
        linux)
            REMOTE_FILENAME="${EXEC_INSTALL_NAME}-${REMOTE_VERSION}"
            ;;
    esac

    [[ -z "${REMOTE_FILENAME}" ]] && IS_INSTALL="no"
fi

if [[ "${IS_INSTALL}" == "yes" ]]; then
    colorEcho "${BLUE}  Installing ${FUCHSIA}${APP_INSTALL_NAME} ${YELLOW}${REMOTE_VERSION}${BLUE}..."

    if [[ -s "${EXEC_INSTALL_PATH}/${EXEC_INSTALL_NAME}" ]]; then
        sudo rm -f "${EXEC_INSTALL_PATH}/${EXEC_INSTALL_NAME}"
    fi

    # Download file
    DOWNLOAD_URL="https://github.com/${GITHUB_REPO_NAME}/releases/download/v${REMOTE_VERSION}/${REMOTE_FILENAME}"
    curl -fSL -o "${DOWNLOAD_FILENAME}" -C- "${DOWNLOAD_URL}"

    # Extract file
    if [[ $? -eq 0 ]]; then
        case "${ARCHIVE_EXT}" in
            "zip")
                unzip -qo "${DOWNLOAD_FILENAME}" -d "${WORKDIR}"
                ;;
            "tar.bz2")
                tar -xjf "${DOWNLOAD_FILENAME}" -C "${WORKDIR}"
                ;;
            "tar.gz")
                tar -xzf "${DOWNLOAD_FILENAME}" -C "${WORKDIR}"
                ;;
            "tar.xz")
                tar -xJf "${DOWNLOAD_FILENAME}" -C "${WORKDIR}"
                ;;
            "gz")
                gzip -d -f "${DOWNLOAD_FILENAME}"
                ;;
        esac
    fi

    # Install
    if [[ $? -eq 0 ]]; then
        [[ -n "${ARCHIVE_EXEC_DIR}" ]] && \
            ARCHIVE_EXEC_DIR=$(find ${WORKDIR} -type d -name ${ARCHIVE_EXEC_DIR})

        [[ -z "${ARCHIVE_EXEC_DIR}" || ! -d "${ARCHIVE_EXEC_DIR}" ]] && ARCHIVE_EXEC_DIR=${WORKDIR}

        sudo mv -f ${ARCHIVE_EXEC_DIR}/${ARCHIVE_EXEC_NAME} "${EXEC_INSTALL_PATH}/${EXEC_INSTALL_NAME}" && \
            sudo chmod +x "${EXEC_INSTALL_PATH}/${EXEC_INSTALL_NAME}" && \
            sudo mv -f ${ARCHIVE_EXEC_DIR}/${ARCHIVE_EXEC_NAME}.1 "${EXEC_INSTALL_PATH}/${EXEC_INSTALL_NAME}.1"
            [[ -n "${VERSION_FILENAME}" ]] && echo ${REMOTE_VERSION} | sudo tee "${VERSION_FILENAME}" >/dev/null || true
    fi

    # Move the native `rm` command to `/bin/rm.real` then replace the native `rm` with `safe-rm`
    if [[ -x "$(command -v safe-rm)" ]]; then
        if [[ ! -f "/bin/rm.real" ]]; then
            file "/bin/rm" | grep -q ELF && sudo /bin/mv -f "/bin/rm" "/bin/rm.real"
        fi

        if [[ -f "/bin/rm.real" ]]; then
            if ! grep -q 'rm_binary = ' "/etc/safe-rm.toml" >/dev/null 2>&1; then
                echo 'rm_binary = "/bin/rm.real"' | sudo tee -a "/etc/safe-rm.toml" >/dev/null
            fi
        fi

        sudo /bin/cp -f "/usr/local/bin/safe-rm" "/bin/rm"
    fi
fi


## srm: Safe Remove (rm) command with cache/undo
## This is a rm command imitation, but without actually removing anything, only moving it into cache (~/.cache/srm)
## https://github.com/WestleyR/srm


# install_shell-safe-rm


cd "${CURRENT_DIR}"