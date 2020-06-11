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


if [[ ! -x "$(command -v code)" ]]; then
    colorEcho ${RED} "Please install visual studio code first!"
    exit 0
fi


# ExtFile="vscode_extensions.list"
[[ $PARAMS_NUM > 0 ]] && ExtFile=${1:-"vscode_extensions.list"}


extensions=(
    # Look & Feel
	"ms-ceintl.vscode-language-pack-zh-hans"
	"zhuangtongfa.material-theme"
	"vscode-icons-team.vscode-icons"
    # Editing
    "aaron-bond.better-comments"
	"coenraads.bracket-pair-colorizer-2"
	"esbenp.prettier-vscode"
	"Hookyqr.beautify"
	"oderwat.indent-rainbow"
    ## Core
	"doggy8088.netcore-extension-pack"
	"doggy8088.netcore-snippets"
	## GO
	"golang.go"
	"zignd.html-css-class-completion"
	"sidthesloth.html5-boilerplate"
    ## Javascript
	"msjsdiag.debugger-for-chrome"
    ## kubernete/docker
	"ms-azuretools.vscode-docker"
    ## nginx
	"shanoor.vscode-nginx"
    ## plsql
	"xyz.plsql-language"
	"ms-python.python"
    ## powershell
	"ms-vscode.powershell"
    ## XML/JSON/GraphQL/YAML
    "eriklynd.json-tools"
	"mohsen1.prettify-json"
    "kumar-harsh.graphql-for-vscode"
	"redhat.vscode-yaml"
    # Vesion Control
	"eamodio.gitlens"
	# Remote
	"ms-vscode-remote.vscode-remote-extensionpack"
	"ms-vscode-remote.remote-wsl"
	# Debug & Test
	"formulahendry.code-runner"
	"humao.rest-client"
	"hediet.debug-visualizer"
    # Extra tools
	"shan.code-settings-sync"
	"anseki.vscode-color"
	"mkxml.vscode-filesize"
	"wayou.vscode-todo-highlight"
	"wwm.better-align"
	"tyriar.sort-lines"
	"russell.any-rule"
	"hediet.vscode-drawio"
)

# How to export installed extensions list
# code --list-extensions > "${ExtFile}"

if [[ $PARAMS_NUM > 0 ]]; then
    if [[ ! -s "${ExtFile}" ]]; then
        colorEcho ${RED} ${ExtFile}" is not exist or empty!"
        exit 0
    fi

    cat "${ExtFile}" | grep -v '^#' | xargs -L1 code --install-extension
else
    for Target in "${extensions[@]}"; do
        code --install-extension $Target
    done
fi

# How to install extensions from exprot list
# windows cmd:
# for /F "tokens=*" %%A in ("${ExtFile}") do code --install-extension %%A
# bash:
# <"${ExtFile}" xargs -I % code --install-extension %
# or
# cat "${ExtFile}" | grep -v '^#' | xargs -L1 code --install-extension

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
