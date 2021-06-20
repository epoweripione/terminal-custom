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

## Rust and Cargo
## https://doc.rust-lang.org/cargo/getting-started/installation.html
## On Linux and macOS systems
curl https://sh.rustup.rs -sSf | sh

## On Windows
## https://win.rustup.rs/
# scoop install rustup


# rustup & cargo mirror
if [[ -z "$RUST_NOT_USE_PROXY" ]]; then
    # rustup mirror
    export RUSTUP_DIST_SERVER=https://mirrors.sjtug.sjtu.edu.cn/rust-static/
    # export RUSTUP_DIST_SERVER=https://mirrors.tuna.tsinghua.edu.cn/rustup
    # export RUSTUP_DIST_SERVER=https://mirrors.ustc.edu.cn/rust-static

    # cargo mirror
    if [[ ! -s "$HOME/.cargo/config" ]]; then
        mkdir -p "$HOME/.cargo"
        tee "$HOME/.cargo/config" >/dev/null <<-'EOF'
[source.crates-io]
registry = "https://github.com/rust-lang/crates.io-index"

replace-with = 'rustcc'

[source.tuna]
registry = "https://mirrors.tuna.tsinghua.edu.cn/git/crates.io-index.git"

[source.ustc]
registry = "git://mirrors.ustc.edu.cn/crates.io-index"

[source.sjtu]
registry = "https://mirrors.sjtug.sjtu.edu.cn/git/crates.io-index"

[source.rustcc]
registry = "git://crates.rustcc.cn/crates.io-index"
EOF
    fi
fi
