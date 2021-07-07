#!/usr/bin/env bash

if [[ -x "$(command -v git)" ]]; then
    git config --global core.autocrlf false
    git config --global core.safecrlf true
    git config --global core.filemode false

    git config --global color.ui true
    git config --global color.status true
    git config --global color.diff true
    git config --global color.branch true
    git config --global color.interactive true

    git config --global alias.st status
    git config --global alias.co checkout
    git config --global alias.ci commit
    git config --global alias.br branch
    git config --global alias.lg "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"

    ## fix filemode overwrite in repository
    # cd <workdir>
    # git config core.filemode false
    # git submodule foreach git config core.filemode false
fi

# git-delta
# https://github.com/dandavison/delta
if [[ -x "$(command -v delta)" ]]; then
    git config --global core.pager delta

    git config --global delta.features "side-by-side line-numbers decorations"
    git config --global delta.plus-style "syntax #003800"
    git config --global delta.minus-style "syntax #3f0001"
    git config --global delta.syntax-theme Dracula

    git config --global delta.decorations.commit-decoration-style "bold yellow box ul"
    git config --global delta.decorations.file-style "bold yellow ul"
    git config --global delta.decorations.file-decoration-style none
    git config --global delta.decorations.hunk-header-decoration-style "cyan box ul"

    git config --global delta.line-numbers.line-numbers-left-style cyan
    git config --global delta.line-numbers.line-numbers-right-style cyan
    git config --global delta.line-numbers.line-numbers-minus-style 124
    git config --global delta.line-numbers.line-numbers-plus-style 28

    git config --global interactive.diffFilter "delta --color-only"
fi