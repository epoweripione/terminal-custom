#!/bin/bash

# Load custom functions
if type 'colorEcho' 2>/dev/null | grep -q 'function'; then
    :
else
    if [[ -s "$HOME/custom_functions.sh" ]]; then
        source "$HOME/custom_functions.sh"
    else
        echo "$HOME/custom_functions.sh not exist!"
        exit 0
    fi
fi


# How to export installed extensions list
# code --list-extensions > vscode_extensions.list

if [[ ! -s "vscode_extensions.list" ]]; then
    colorEcho ${RED} "vscode_extensions.list is not exist or empty!"
    exit 0
fi

# How to install extensions from exprot list
# windows cmd:
# for /F "tokens=*" %%A in (vscode_extensions.list) do code --install-extension %%A
# bash:
# <vscode_extensions.list xargs -I % code --install-extension %
# or
# cat vscode_extensions.list | grep -v '^#' | xargs -L1 code --install-extension

cat vscode_extensions.list | grep -v '^#' | xargs -L1 code --install-extension

## https://www.growingwiththeweb.com/2016/06/syncing-vscode-extensions.html
# EXTENSIONS=(
#     "cssho.vscode-svgviewer" \
#     "dbaeumer.vscode-eslint" \
#     "EditorConfig.EditorConfig" \
#     "ryzngard.vscode-header-source" \
#     "spywhere.guides" \
#     "Tyriar.sort-lines" \
#     "Tyriar.lorem-ipsum" \
#     "waderyan.gitblame"
# )

# for VARIANT in "code" "code-insiders"; do
#     if hash $VARIANT 2>/dev/null; then
#         echo "Installing extensions for $VARIANT"
#         for EXTENSION in ${EXTENSIONS[@]}; do
#             $VARIANT --install-extension $EXTENSION
#         done
#     fi
# done
