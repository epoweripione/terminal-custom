# https://gist.github.com/mdschweda/2311e3f2c7062bf7367e44f8a7aa8b55
# Script for batch installing Visual Studio Code extensions
# Specify extensions to be checked & installed by modifying $extensions

## How to export installed extensions list
# code --list-extensions > vscode_extensions.list

## How to install extensions from exprot list
# windows cmd:
# for /F "tokens=*" %%A in (vscode_extensions.list) do code --install-extension %%A
# bash:
# <vscode_extensions.list xargs -I % code --install-extension %

Param (
	[switch]$UseFile,
	[string]$FileName = "vscode_extensions.list"
)

$extensions = @(
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
    ## HTML/CSS
	# "thekalinga.bootstrap4-vscode"
	# "wcwhitehead.bootstrap-3-snippets"
	"zignd.html-css-class-completion"
	"sidthesloth.html5-boilerplate"
    ## Javascript
	"msjsdiag.debugger-for-chrome"
	# "xabikos.javascriptsnippets"
	## Typescript
	# "ms-vscode.vscode-typescript-tslint-plugin"
	# "stringham.move-ts"
	## Angular
	# "cipchk.ng-alain-extension-pack"
	## Vue
	# "dariofuzinato.vue-peek"
	# "abdelaziz18003.quasar-snippets"
    ## kubernete/docker
	# "ms-kubernetes-tools.vscode-kubernetes-tools"
	"ms-azuretools.vscode-docker"
    ## Markdown
	# "yzhang.markdown-all-in-one"
    ## nginx
	"shanoor.vscode-nginx"
    ## plsql
	"xyz.plsql-language"
    ## python
	# "ms-python.anaconda-extension-pack"
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
	# "ms-vsliveshare.vsliveshare"
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
	# "eighthundreds.vscode-drawio"
)

$cmd = "code --list-extensions"
Invoke-Expression $cmd -OutVariable output | Out-Null
$installed = $output -split "\s"

$extTotal = 0
if ($UseFile) {
	## vscode_extensions.list
	# windows cmd:
	# for /F "tokens=*" %%A in ($FileName) do code --install-extension %%A
	
	## Get-Content has bad performance
	## it tries to read the file into memory all at once
	# foreach ($ext in Get-Content $PSScriptRoot\$FileName) {
	#     if ($ext -notmatch '\#') {
	# 		if ($installed -match "$ext") {
	# 			Write-Host "$ext already installed." -ForegroundColor Green
	# 		} else {
	# 			Write-Host "Installing $ext..." -ForegroundColor Blue
	# 			code --install-extension $ext
	# 		}
	#     }
	# }
	
	## (.NET) file reader reads each line one by one
	foreach ($ext in [System.IO.File]::ReadLines("$PSScriptRoot\$FileName")) {
		if ($ext -notmatch '\#') {
			$extTotal++
			# if ($installed.Contains($ext)) {
			if ($installed -match "$ext") {
				Write-Host "$ext already installed." -ForegroundColor Green
			} else {
				Write-Host "Installing $ext..." -ForegroundColor Blue
				code --install-extension $ext
			}
		}
	}
} else {
	foreach ($ext in $extensions) {
		$extTotal++
		if ($installed -match "$ext") {
			Write-Host "$ext already installed." -ForegroundColor Green
		} else {
			Write-Host "Installing $ext..." -ForegroundColor Blue
			code --install-extension $ext
		}
	}
}

Write-Host "Done, $extTotal extensions installed." -ForegroundColor Green