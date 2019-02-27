#!/bin/bash

set -euo pipefail

usage() {
    echo "$0 TARGET [VSN]"
    err ""
}

err() {
    echo "$1"
    exit 1
}

get-kubectl() {
    curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
    echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" > /tmp/kubernetes.list
    sudo mv /tmp/kubernetes.list /etc/apt/sources.list.d/kubernetes.list
    sudo apt-get update \
        && sudo apt-get install -y kubectl
}

get-awscli() {
    sudo aptpget update \
        && sudo apt-get install -y awscli
}

get-docker() {
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    sudo add-apt-repository \
         "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
          $(lsb_release -cs) \
          stable"
    sudo apt-get install docker-ce docker-ce-cli containerd.io
}

get-keybase() {
    curl -sSL https://prerelease.keybase.io/keybase_amd64.deb > /tmp/keybase.deb
     sudo dpkg -i /tmp/keybase.deb || true
     sudo apt-get install -yf
}

get-aws-vault() {
    local r
    local VSN=""
    local DLPAGE="https://github.com/99designs/aws-vault/releases"
    local RE="download/v[0-9\\.]+/aws-vault-linux-amd64"

    r="$(curl -sL "$DLPAGE" | grep -oE "$RE" | grep "$VSN" | sort -uV | tail -n1)"
    [ -z "$r" ] && err "no file at $DLPAGE."
    echo "found file: $r"
    curl -sL "$DLPAGE/$r" -o /tmp/aws-vault
    sudo install /tmp/aws-vault /usr/bin
}

get-docker-compose() {
    local r
    local VSN="$1"
    local DLPAGE="https://github.com/docker/compose/releases"
    local RE="download/[0-9\\.]+/docker-compose-Linux-x86_64"

    r="$(curl -sL "$DLPAGE" | grep -oE "$RE" | grep "$VSN" | sort -uV | tail -n1)"
    [ -z "$r" ] && err "no file at $DLPAGE."
    echo "found file: $r"
    sudo curl -sL "$DLPAGE/$r" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
}

get-bazel() {
    local VSN="${2:-}"
    local GH="https://github.com/bazelbuild/bazel/releases"
    local RE="download/[.0-9-]+/bazel-[.0-9-]+-installer-linux-x86_64.sh"
    local r

    r="$(curl -sSL "$GH" | grep -Eo "$RE" | grep "$VSN" | sort -Vu | tail -n1)"
    echo "found file $r"
    curl -sSL "$GH/$r" > /tmp/bazel.sh
    chmod +x /tmp/bazel.sh
    sudo bash -x /tmp/bazel.sh
    /usr/local/bin/bazel help
    sudo ln -s /usr/local/lib/bazel/bin/bazel-complete.bash /etc/bash_completion.d
}

sudo true
[ -z "$1" ] && usage
TRG="$1"
VSN="${2:-}"
"get-$TRG" "$VSN"
