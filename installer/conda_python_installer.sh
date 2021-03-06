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
# sudo pacman -S build-essential pkg-config python3-dev python3-distutils
# sudo pacman -S libssl-dev libcurl4-openssl-dev libcairo2-dev libjpeg-dev libgif-dev libgirepository1.0-dev
## https://pip.pypa.io/en/stable/installing/
# curl "https://bootstrap.pypa.io/get-pip.py" -o get-pip.py && python3 get-pip.py && rm get-pip.py
## fix: ERROR: Could not install packages due to an OSError: Missing dependencies for SOCKS support.
# python3 -m pip install --user -U pysocks
# python3 -m pip install --user -U pip
# python3 -m pip install --user -U setuptools wheel
# pip list -o | grep -Ev "^-|^Package" | cut -d" " -f1 | xargs -n1 pip install -U

## Install and use pip in a local directory without root/sudo access
## https://gist.github.com/saurabhshri/46e4069164b87a708b39d947e4527298
# .local/bin/pip install --user <package_name>


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
        # https://mirrors.bfsu.edu.cn/help/anaconda/
        # https://mirrors.tuna.tsinghua.edu.cn/help/anaconda/
        # https://mirrors.sjtug.sjtu.edu.cn/docs/anaconda
        CONDA_MIRROR="https://mirrors.bfsu.edu.cn"

        # conda config --add channels ${CONDA_MIRROR}/anaconda/pkgs/main/
        # conda config --add channels ${CONDA_MIRROR}/anaconda/cloud/pytorch/
        tee -a "$HOME/.condarc" >/dev/null <<-EOF
channels:
  - defaults
show_channel_urls: true
default_channels:
  - ${CONDA_MIRROR}/anaconda/pkgs/main
  - ${CONDA_MIRROR}/anaconda/pkgs/r
  - ${CONDA_MIRROR}/anaconda/pkgs/msys2
custom_channels:
  conda-forge: ${CONDA_MIRROR}/anaconda/cloud
  msys2: ${CONDA_MIRROR}/anaconda/cloud
  bioconda: ${CONDA_MIRROR}/anaconda/cloud
  menpo: ${CONDA_MIRROR}/anaconda/cloud
  pytorch: ${CONDA_MIRROR}/anaconda/cloud
  simpleitk: ${CONDA_MIRROR}/anaconda/cloud
EOF
    fi

    ## Use default channels
    # conda config --remove-key channels
    # rm "$HOME/.condarc"

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

    # conda config --set show_channel_urls yes
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


[[ -s "${MY_SHELL_SCRIPTS:-$HOME/terminal-custom}/installer/python_pip_config.sh" ]] && \
    source "${MY_SHELL_SCRIPTS:-$HOME/terminal-custom}/installer/python_pip_config.sh"
