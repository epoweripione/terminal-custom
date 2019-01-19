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

$extensions =
    # Look & Feel
	"anseki.vscode-color",
	"robertohuertasm.vscode-icons",
	"idleberg.icon-fonts",
    "zhuangtongfa.Material-theme",
    # Editing
    "aaron-bond.better-comments"
	"bmewburn.vscode-intelephense-client",
	"christian-kohler.npm-intellisense",
	"christian-kohler.path-intellisense",
	"CoenraadS.bracket-pair-colorizer",
	"esbenp.prettier-vscode",
	"fernandoescolar.vscode-solution-explorer",
	"formulahendry.auto-close-tag",
	"formulahendry.auto-rename-tag",
	"HookyQR.beautify",
	"oderwat.indent-rainbow",
	"streetsidesoftware.code-spell-checker",
	"VisualStudioExptTeam.vscodeintellicode",
    # Language support
    ## C/C++
	"ms-vscode.cpptools",
	"austin.code-gnu-global",
    ## C#
	"ms-vscode.csharp",
	"craigthomas.supersharp",
	"jchannon.csharpextensions",
	"jorgeserrano.vscode-csharp-snippets",
	"Leopotam.csharpfixformat",
    ## Core
	"doggy8088.netcore-extension-pack",
	"doggy8088.netcore-snippets",
    ## dotnet
	"formulahendry.dotnet",
	"formulahendry.dotnet-test-explorer",
	"jmrog.vscode-nuget-package-manager",
	"schneiderpat.aspnet-helper",
	"tintoy.msbuild-project-tools",
    "alefragnani.project-manager",
    ## db
	"bajdzis.vscode-database",
	"ms-mssql.mssql",
    ## Dart/Flutter
	"Dart-Code.dart-code",
	"Dart-Code.flutter",
    ## GO
	"ms-vscode.Go",
    ## HTML/CSS
	"thekalinga.bootstrap4-vscode",
    "abusaidm.html-snippets",
    "clinyong.vscode-css-modules",
	"robinbentley.sass-indented",
	"wcwhitehead.bootstrap-3-snippets",
	"Zignd.html-css-class-completion",
    ## JAVA
	"redhat.java",
	"vscjava.vscode-java-debug",
	"vscjava.vscode-java-dependency",
	"vscjava.vscode-java-pack",
	"vscjava.vscode-java-test",
	"vscjava.vscode-maven",
    ## Javascript/Typescript
	"msjsdiag.debugger-for-chrome",
	"Angular.ng-template",
	"cyrilletuzi.angular-schematics",
	"Mikael.Angular-BeastCode",
	"chenxsan.vscode-standardjs",
	"dbaeumer.vscode-eslint",
	"eg2.tslint",
	"octref.vetur",
	"vsmobile.vscode-react-native",
	"xabikos.JavaScriptSnippets",
    ## ionic
	"loiane.ionic-extension-pack",
	"vsmobile.cordova-tools",
    ## kubernete/docker
	"ms-kubernetes-tools.vscode-kubernetes-tools",
	"PeterJausovec.vscode-docker",
    ## latex
	"James-Yu.latex-workshop",
    ## Markdown
	"DavidAnson.vscode-markdownlint",
	"shd101wyy.markdown-preview-enhanced",
	"yzhang.markdown-all-in-one",
    ## nginx
	"shanoor.vscode-nginx",
    ## Node
	"eg2.vscode-npm-script",
    "leizongmin.node-module-intellisense",
    ## PHP
	"ikappas.composer",
	"ikappas.phpcs",
	"felixfbecker.php-debug",
	"junstyle.php-cs-fixer",
    ## plsql
	"xyz.plsql-language",
    ## python
	"ms-python.anaconda-extension-pack",
	"ms-python.python",
    ## powershell
	"ms-vscode.PowerShell",
    ## ruby
	"rebornix.ruby",
    ## linux/shell/vim
	"vscodevim.vim",
    ## XML/JSON/GraphQL/YAML
	"DotJoshJohnson.xml",
    "eriklynd.json-tools",
	"mohsen1.prettify-json",
    "kumar-harsh.graphql-for-vscode",
	"redhat.vscode-yaml",
    # Vesion Control
	"johnstoncode.svn-scm",
	"codezombiech.gitignore",
	"donjayamanne.githistory",
	"eamodio.gitlens",
	"pflannery.vscode-versionlens",
    # Extra functionality
	"bukas.GBKtoUTF8",
	"steoates.autoimport",
	"WakaTime.vscode-wakatime",
    # Extra tools
	"MS-CEINTL.vscode-language-pack-zh-hans",
	"ms-vsliveshare.vsliveshare",
	"Shan.code-settings-sync",
	"formulahendry.code-runner",
	"GrapeCity.gc-excelviewer",
	"Gruntfuggly.todo-tree",
	"humao.rest-client",
	"joelday.docthis",
	"k--kato.docomment",
	"mkxml.vscode-filesize",
	"quicktype.quicktype",
	"wayou.vscode-todo-highlight"


$cmd = "code --list-extensions"
Invoke-Expression $cmd -OutVariable output | Out-Null
$installed = $output -split "\s"

foreach ($ext in $extensions) {
    if ($installed.Contains($ext)) {
        Write-Host $ext "already installed." -ForegroundColor Gray
    } else {
        Write-Host "Installing" $ext "..." -ForegroundColor White
        code --install-extension $ext
    }
}