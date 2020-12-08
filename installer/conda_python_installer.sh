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

# Use proxy or mirror when some sites were blocked or low speed
set_proxy_mirrors_env


# python3 & pip
# bash <(curl -sL https://python3.netlify.com/install.sh)

# fix `pip list` warning
if [[ ! $(grep "format=columns" $HOME/.pip/pip.conf) ]]; then
    mkdir -p $HOME/.pip && \
        echo -e "[global]\nformat=columns" >> $HOME/.pip/pip.conf
fi

# pip upgrade
# python -m pip install --upgrade pip

# pip mirror
# alias pip="pip --proxy 127.0.0.1:8080"
# alias pipinstall='pip install -i https://mirrors.aliyun.com/pypi/simple/ --trusted-host mirrors.aliyun.com'
PIP_MIRROR_URL=https://mirrors.aliyun.com/pypi/simple/
PIP_MIRROR_HOST=mirrors.aliyun.com
if [[ -z "$PIP_NOT_USE_MIRROR" && ! $(grep "${PIP_MIRROR_HOST}" $HOME/.pip/pip.conf) ]]; then
    if [[ $(grep "index-url=" $HOME/.pip/pip.conf) ]]; then
        sed -i "s|index-url=.*|index-url=${PIP_MIRROR_URL}|" $HOME/.pip/pip.conf
    else
        sed -i "/^\[global\]/a\index-url=${PIP_MIRROR_URL}" $HOME/.pip/pip.conf
    fi

    if [[ $(grep "trusted-host=" $HOME/.pip/pip.conf) ]]; then
        sed -i "s|trusted-host=.*|trusted-host=${PIP_MIRROR_HOST}|" $HOME/.pip/pip.conf
    else
        [[ ! $(grep "[install]" $HOME/.pip/pip.conf) ]] && \
            echo -e "\n[install]" | tee -a $HOME/.pip/pip.conf >/dev/null
        sed -i "/^\[install\]/a\trusted-host=${PIP_MIRROR_HOST}" $HOME/.pip/pip.conf
    fi
fi


# Miniconda
colorEcho ${BLUE} "Installing Miniconda3..."
if [[ ! -d "$HOME/miniconda3" ]]; then
    wget -c https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh && \
        bash ./Miniconda3-latest-Linux-x86_64.sh -b -p $HOME/miniconda3

    rm -f "$HOME/miniconda3"
fi

if [[ -d "$HOME/miniconda3" ]]; then
    export PATH=$PATH:$HOME/miniconda3/condabin
    source $HOME/miniconda3/bin/activate

    ## Use mirror channels
    if [[ -z "$CONDA_NOT_USE_MIRROR" ]]; then
        conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/free/ && \
            conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/main/ && \
            conda config --set show_channel_urls yes

        # conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud/conda-forge/ && \
        #     conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud/msys2/ && \
        #     conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud/bioconda/ && \
        #     conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud/menpo/ && \
        #     conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud/pytorch/
    fi

    ## Use default channels
    # conda config --remove-key channels

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
