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

get-aws-vault() {
    local r
    local VSN="${1:-}"
    local DLPAGE="https://github.com/99designs/aws-vault/releases"
    local RE="download/v[0-9\\.]+/aws-vault-linux-amd64"

    r="$(curl -sL "$DLPAGE" | grep -oE "$RE" | grep "$VSN" | sort -uV | tail -n1)"
    [ -z "$r" ] && err "no file at $DLPAGE."
    echo "found file: $r"
    curl -sL "$DLPAGE/$r" -o /tmp/aws-vault
    sudo install /tmp/aws-vault /usr/bin
}

get-awscli() {
    sudo apt-get update \
        && sudo apt-get install -y awscli
}

get-bazel() {
    local VSN="${1:-}"
    local GH="https://github.com/bazelbuild/bazel/releases"
    local RE="download/[.0-9-]+/bazel-[.0-9-]+-installer-linux-x86_64.sh"
    local r

    r="$(curl -sSL "$GH" | grep -Eo "$RE" | grep "$VSN" | sort -Vu | tail -n1)"
    echo "found file $r"
    curl -sSL "$GH/$r" > /tmp/bazel.sh
    chmod +x /tmp/bazel.sh
    sudo /tmp/bazel.sh
    sudo rm -f /etc/bash_completion.d/bazel-complete.bash
    sudo ln -s /usr/local/lib/bazel/bin/bazel-complete.bash /etc/bash_completion.d
}

get-docker() {
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    sudo add-apt-repository \
         "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
          $(lsb_release -cs) \
          stable"
    sudo apt-get update \
	&& sudo apt-get install -y \
		docker-ce docker-ce-cli containerd.io
    sudo usermod -aG docker "$USER"
}

get-docker-compose() {
    local r
    local VSN="${1:-}"
    local DLPAGE="https://github.com/docker/compose/releases"
    local RE="download/[0-9\\.]+/docker-compose-Linux-x86_64"

    r="$(curl -sL "$DLPAGE" | grep -oE "$RE" | grep "$VSN" | sort -uV | tail -n1)"
    [ -z "$r" ] && err "no file at $DLPAGE."
    echo "found file: $r"
    sudo curl -sL "$DLPAGE/$r" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
}

get-erlang() {
    sudo apt-get update \
	&& sudo apt-get install -y \
		erlang-common-test erlang-eunit erlang-dialyzer \
		erlang-mode erlang-parsetools erlang-dev
}

get-java() {
    sudo apt-get update \
	&& sudo apt-get install -y \
		openjdk-8-jdk-headless openjdk-11-jdk-headless openssh-server
    sudo update-java-alternatives -s java-1.8.0-openjdk-amd64
}

get-keybase() {
    curl -sSL https://prerelease.keybase.io/keybase_amd64.deb > /tmp/keybase.deb
    sudo dpkg -i /tmp/keybase.deb || true
    sudo apt-get install -yf
}

get-kubectl() {
    curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
    echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" > /tmp/kubernetes.list
    sudo mv /tmp/kubernetes.list /etc/apt/sources.list.d/kubernetes.list
    sudo apt-get update \
        && sudo apt-get install -y kubectl
}

get-pgadmin() {
    sudo apt-get update \
	&& sudo apt-get install -y pgadmin3
}

get-python() {
    sudo apt-get update \
	&& sudo apt-get install -y python2 python3 \
	&& sudo update-alternatives --install /usr/bin/python python /usr/bin/python2.7 1 \
	&& sudo update-alternatives --install /usr/bin/python python /usr/bin/python3.6 2
}

get-wireshark() {
    sudo apt-get update \
	&& sudo apt-get install -y tshark wireshark
    sudo usermod -aG wireshark "$USER"
}

sudo true
[ -z "$1" ] && usage
TRG="$1"
VSN="${2:-}"
"get-$TRG" "$VSN"
