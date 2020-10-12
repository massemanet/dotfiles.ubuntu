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
    sudo apt-get update
    sudo apt-get install -y awscli
}

get-bazelisk() {
    local VSN="${1:-}"
    local GH="https://github.com/bazelbuild/bazelisk/releases"
    local RE="download/v[.0-9-]+/bazelisk-linux-amd64"
    local r

    r="$(curl -sSL "$GH" | grep -Eo "$RE" | grep "$VSN" | sort -Vu | tail -n1)"
    echo "found file $r"
    curl -sSL "$GH/$r" > /tmp/bazelisk
    chmod +x /tmp/bazelisk
    cp /tmp/bazelisk ~/bin/bazel
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

get-chromium() {
    echo 'deb http://download.opensuse.org/repositories/home:/ungoogled_chromium/Ubuntu_Focal/ /' | \
        sudo tee /etc/apt/sources.list.d/home-ungoogled_chromium.list > /dev/null
    curl -s 'https://download.opensuse.org/repositories/home:/ungoogled_chromium/Ubuntu_Focal/Release.key' | \
        gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/home-ungoogled_chromium.gpg > /dev/null
    sudo apt update
    sudo apt install -y ungoogled-chromium

    local GH="https://github.com/gorhill/uBlock/releases"
    local RE="download/[0-9\\.]+/uBlock0_[0-9\\.]+.chromium.zip"
    local r
    r="$(curl -sSL "$GH" | grep -Eo "$RE" | grep "$VSN" | sort -Vu | tail -n1)"
    echo "found file $r"
    curl -sSL "$GH/$r" > /tmp/ublock.zip
    unzip -d ~/.local /tmp/ublock.zip
    mv ~/.local/uBlock0.chromium ~/.local/ublock
    echo "Add the extension in chromium; 'More Tools => Extensions' = ~/.local/ublock"
}

get-docker() {
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    sudo add-apt-repository \
         "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
          disco \
          stable"
    sudo apt-get update
    sudo apt-get install -y \
         docker-ce docker-ce-cli containerd.io
    sudo usermod -aG docker "$USER"
}

get-go() {
    sudo snap install go --classic
}

get-grpcurl() {
    local VSN="${1:-}"
    local ITEM=grpcurl
    local DLPAGE="https://github.com/fullstorydev/$ITEM/releases"
    local RE="download/v[0-9\\.]+/${ITEM}_[0-9\\.]+_linux_x86_64.tar.gz"
    local r TMP

    sudo true
    r="$(curl -sL "$DLPAGE" | grep -oE "$RE" | grep "$VSN" | sort -uV | tail -n1)"
    [ -z "$r" ] && err "no file at $DLPAGE."
    echo "found file: $r"
    TMP="$(mktemp)"
    curl -sL "$DLPAGE/$r" -o "$TMP"
    sudo tar -xz -C /usr/local/bin --no-same-owner -f "$TMP" "$ITEM"
    sudo chmod +x /usr/local/bin/"$ITEM"
}

get-gtk-server() {
    local VSN="${1:-}"
    local DLPAGE="http://gtk-server.org/stable"
    local RE="gtk-server-[0-9\\.]+.tar.gz"
    local r

    sudo apt update \
        && sudo apt install -y --auto-remove \
                libcairo2-dev libgtk-3-dev glade
    r="$(curl -sL "$DLPAGE" | grep -oE "$RE" | grep "$VSN" | sort -uV | tail -n1)"
    echo "found $r"
    curl -sSL "$DLPAGE/$r" > /tmp/gtk-server.tgz
    tar -xz -C /tmp/ -f /tmp/gtk-server.tgz
    cd /tmp/gtk-server-*/src
    ./configure
    make && sudo make install
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

get-gopass() {
    local r TMP
    local VSN="${1:-}"
    local DLPAGE="https://github.com/gopasspw/gopass/releases"
    local RE="download/v[0-9\\.]+/gopass-[0-9\\.]+-linux-amd64.tar.gz"

    TMP="$(mktemp)"
    r="$(curl -sL "$DLPAGE" | grep -oE "$RE" | grep "$VSN" | sort -uV | tail -n1)"
    [ -z "$r" ] && err "no file at $DLPAGE."
    echo "found file: $r"
    curl -sL "$DLPAGE/$r" -o "$TMP"
    sudo tar -xz -C /usr/local/bin --no-same-owner -f "$TMP" gopass
    sudo chmod +x /usr/local/bin/gopass
}

# emacs for wayland
get-emacs() {
    cd /tmp
    git clone --depth=2 --single-branch https://github.com/masm11/emacs
    cd emacs/
    ./autogen.sh
    sudo apt install -y --auto-remove \
         libcairo2-dev libgtk-3-dev libgnutls28-dev
    ./configure --with-pgtk --with-cairo --with-modules --without-makeinfo
    sudo make install
    [ ! -d ~/.cask ] && \
        curl -fsSL https://raw.githubusercontent.com/cask/cask/master/go | python
    cd ~/.emacs.d
    ~/.cask/bin/cask install
}

# install erlang + rebar + redbug
get-erlang() {
    local VSN="${1:-23}"

    command -v make > /dev/null || err "install 'make'"
    command -v automake > /dev/null || err "install 'automake'"
    command -v autoconf > /dev/null || err "install 'autoconf'"

    sudo true
    sudo apt-get install -y \
         libncurses-dev libpcap-dev libsctp-dev libssl-dev libwxgtk3.0-gtk3-dev
    [ -d ~/git/otp ] || git clone --depth=2 --branch "maint-$VSN" --single-branch \
                            https://github.com/erlang/otp.git ~/git/otp
    cd ~/git/otp/
    git pull --depth=2
    ./otp_build autoconf
    ./configure --without-megaco --without-odbc --without-jinterface --without-javac
    make
    sudo make install

    mkdir -p ~/.emacs.d/masserlang \
        && rm -f ~/.emacs.d/masserlang/masserlang.el \
        && ln -s ~/install/masserlang.el ~/.emacs.d/masserlang
    rm -f ~/.erlang \
        && ln -s ~/install/erlang ~/.erlang
    rm -f ~/user_default.erl \
        && ln -s ~/install/user_default.erl ~

    curl https://s3.amazonaws.com/rebar3/rebar3 > /tmp/rebar3
    sudo cp /tmp/rebar3 /usr/local/bin/rebar3
    sudo chmod +x /usr/local/bin/rebar3

    cd ~/git
    ( [ -d redbug ] || git clone https://github.com/massemanet/redbug )
    cd redbug
    make
}

get-intellij() {
    sudo snap install intellij-idea-community --classic
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

get-kotlin() {
    local r
    local VSN="${1:-}"
    local DLPAGE="https://github.com/JetBrains/kotlin/releases"
    local RE="download/v[0-9\\.]+/kotlin-native-linux-[0-9\\.]+.tar.gz"
    local TMP=/tmp/kt.tgz

    r="$(curl -sL "$DLPAGE/latest" | grep -oE "$RE" | grep "$VSN" | sort -uV | tail -n1)"
    [ -z "$r" ] && err "no file at $DLPAGE."
    echo "found file: $r"
    curl -sL "$DLPAGE/$r" -o "$TMP"
    sudo rm -rf /opt/kotlin \
        && sudo mkdir /opt/kotlin \
        && sudo tar -xz -C /opt/kotlin --strip-components=1 --no-same-owner -f "$TMP"
}

get-kubectl() {
    curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
    echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" > /tmp/kubernetes.list
    sudo mv /tmp/kubernetes.list /etc/apt/sources.list.d/kubernetes.list
    sudo apt-get update \
        && sudo apt-get install -y kubectl
    kubectl completion bash > /tmp/kubectl_completion
    sudo cp /tmp/kubectl_completion /etc/bash_completion.d
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

get-pgadmin() {
    curl https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
    sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt/ $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
    sudo apt-get update \
         && sudo apt-get install -y pgadmin4
}

get-rust() {
    sudo snap install rustup --classic
    rustup toolchain install stable
}

get-spotify() {
    curl -sS https://download.spotify.com/debian/pubkey.gpg | sudo apt-key add -
    curl -sS https://download.spotify.com/debian/pubkey_0D811D58.gpg | sudo apt-key add -
    echo "deb http://repository.spotify.com stable non-free" | sudo tee /etc/apt/sources.list.d/spotify.list
    sudo apt-get update \
        && sudo apt-get install -y --auto-remove spotify-client
}

get-sway(){
    sudo apt-get update \
         && sudo apt install -y \
                 sway swaylock swayidle waybar slurp grim wl-clipboard fzf rofi
}

sudo true
[ -z "$1" ] && usage
TRG="$1"
VSN="${2:-}"
"get-$TRG" "$VSN"
