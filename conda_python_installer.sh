#!/bin/bash

# Load custom functions
if type 'colorEcho' 2>/dev/null | grep -q 'function'; then
    :
else
    if [[ -e "$HOME/custom_functions.sh" ]]; then
        source "$HOME/custom_functions.sh"
    else
        echo "$HOME/custom_functions.sh not exist!"
        exit 0
    fi
fi


# Miniconda
colorEcho ${BLUE} "Installing Miniconda3..."
if [[ ! -d "$HOME/miniconda3" ]]; then
    curl -SL -O https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh
    bash ./Miniconda3-latest-Linux-x86_64.sh -b -p $HOME/miniconda3

    export PATH=$PATH:$HOME/miniconda3/bin
    # source $HOME/miniconda3/bin/activate

    ## Use mirror channels
    # conda config --add channels https://mirrors.ustc.edu.cn/anaconda/pkgs/free/ && \
    #     conda config --add channels https://mirrors.ustc.edu.cn/anaconda/pkgs/main/ && \
    #     conda config --set show_channel_urls yes

    # conda config --add channels https://mirrors.ustc.edu.cn/anaconda/cloud/conda-forge/ && \
    #     conda config --add channels https://mirrors.ustc.edu.cn/anaconda/cloud/msys2/ && \
    #     conda config --add channels https://mirrors.ustc.edu.cn/anaconda/cloud/bioconda/ && \
    #     conda config --add channels https://mirrors.ustc.edu.cn/anaconda/cloud/menpo/
    
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

    conda create -n py37 python=3.7
    # source activate py37
    # source deactivate

    conda create -n py27 python=2.7
    # source activate py2.7
    # source deactivate
fi
