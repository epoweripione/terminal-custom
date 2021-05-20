#!/usr/bin/env bash

trap 'rm -rf "$WORKDIR"' EXIT

[[ -z "$WORKDIR" ]] && WORKDIR="$(mktemp -d)"
[[ -z "$CURRENT_DIR" ]] && CURRENT_DIR=$(pwd)

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

# Use proxy or mirror when some sites were blocked or low speed
set_proxy_mirrors_env


## python3
# sudo pacman -S python3

## pip
# python3 -m pip install --upgrade pip --user

## Install and use pip in a local directory without root/sudo access
## https://gist.github.com/saurabhshri/46e4069164b87a708b39d947e4527298
# .local/bin/pip install <package_name> --user


# fix `pip list` warning
if [[ ! $(grep "format=columns" "$HOME/.pip/pip.conf") ]]; then
    mkdir -p $HOME/.pip && \
        echo -e "[global]\nformat=columns" >> "$HOME/.pip/pip.conf"
fi

# pip mirror
# alias pip="pip --proxy 127.0.0.1:8080"
# alias pipinstall='pip install -i https://mirrors.aliyun.com/pypi/simple/ --trusted-host mirrors.aliyun.com'
PIP_MIRROR_URL=https://mirrors.aliyun.com/pypi/simple/
PIP_MIRROR_HOST=mirrors.aliyun.com
if [[ -z "$PIP_NOT_USE_MIRROR" && ! $(grep "${PIP_MIRROR_HOST}" "$HOME/.pip/pip.conf") ]]; then
    if [[ $(grep "index-url=" "$HOME/.pip/pip.conf") ]]; then
        sed -i "s|index-url=.*|index-url=${PIP_MIRROR_URL}|" "$HOME/.pip/pip.conf"
    else
        sed -i "/^\[global\]/a\index-url=${PIP_MIRROR_URL}" "$HOME/.pip/pip.conf"
    fi

    if [[ $(grep "trusted-host=" "$HOME/.pip/pip.conf") ]]; then
        sed -i "s|trusted-host=.*|trusted-host=${PIP_MIRROR_HOST}|" "$HOME/.pip/pip.conf"
    else
        [[ ! $(grep "[install]" "$HOME/.pip/pip.conf") ]] && \
            echo -e "\n[install]" | tee -a "$HOME/.pip/pip.conf" >/dev/null
        sed -i "/^\[install\]/a\trusted-host=${PIP_MIRROR_HOST}" "$HOME/.pip/pip.conf"
    fi
fi


# Miniconda
colorEcho "${BLUE}Installing ${FUCHSIA}Miniconda3${BLUE}..."
if [[ ! -d "$HOME/miniconda3" ]]; then
    DOWNLOAD_URL="https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh"
    wget -O "${WORKDIR}/Miniconda3.sh" -c "${DOWNLOAD_URL}" && \
        bash "${WORKDIR}/Miniconda3.sh" -b -p "$HOME/miniconda3"
fi

if [[ -d "$HOME/miniconda3" ]]; then
    export PATH=$PATH:$HOME/miniconda3/condabin
    source "$HOME/miniconda3/bin/activate"

    ## Use mirror channels
    if [[ -z "$CONDA_NOT_USE_MIRROR" ]]; then
        # https://mirrors.tuna.tsinghua.edu.cn/help/anaconda/
        tee -a "$HOME/.condarc" >/dev/null <<-'EOF'
channels:
  - defaults
show_channel_urls: true
default_channels:
  - https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/main
  - https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/r
  - https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/msys2
custom_channels:
  conda-forge: https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud
  msys2: https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud
  bioconda: https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud
  menpo: https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud
  pytorch: https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud
  simpleitk: https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud
EOF
        # conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/free/ && \
        #     conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/main/ && \
        #     conda config --set show_channel_urls yes

        # conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud/conda-forge/ && \
        #     conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud/msys2/ && \
        #     conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud/bioconda/ && \
        #     conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud/menpo/ && \
        #     conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud/pytorch/
    fi

    ## Use default channels
    # conda config --remove-key channels

    ## clean channels cache
    # conda clean -i

    conda update -y --all

    ## Use conda
    ## https://conda.io/docs/user-guide/getting-started.html
    ## https://conda.io/docs/_downloads/conda-cheatsheet.pdf
    # conda info
    # conda update -y conda
    # conda install <PackageName>
    # conda update <PackageName>
    # conda update -y --all

    # conda clean --tarballs
    # conda clean --all

    conda config --set auto_activate_base false

    DEFALUT_SHELL=$(basename $SHELL)
    conda init ${DEFALUT_SHELL}

    # conda create -n py38 python=3.8
    # conda activate py38
    # conda deactivate

    # conda create -n py27 python=2.7
    # conda activate py27
    # conda deactivate

    ## pip updates
    # pip list  --outdated

    ## https://pypi.org/project/pip-review/
    pip install pip-review
    # pip-review --auto
    # pip-review --local --interactive

    ## Fix:
    ## Cannot uninstall ‘xxx’.
    ## It is a distutils installed project and thus we cannot accurately determine 
    ## which files belong to it which would lead to only a partial uninstall.
    # pip install -U --ignore-installed xxx
fi
