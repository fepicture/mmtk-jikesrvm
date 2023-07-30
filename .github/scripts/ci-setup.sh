set -xe

. $(dirname "$0")/common.sh

# Check if rustup is installed
if ! command -v rustup &> /dev/null; then
    echo "rustup not found. Installing Rust..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --profile minimal --default-toolchain $RUSTUP_TOOLCHAIN
    source "$HOME/.cargo/env"
fi

# Install nightly rust if not already installed
if ! rustup toolchain list | grep -q "$RUSTUP_TOOLCHAIN"; then
    rustup toolchain install $RUSTUP_TOOLCHAIN
fi
rustup target add i686-unknown-linux-gnu --toolchain $RUSTUP_TOOLCHAIN
rustup component add clippy --toolchain $RUSTUP_TOOLCHAIN
rustup component add rustfmt --toolchain $RUSTUP_TOOLCHAIN
rustup override set $RUSTUP_TOOLCHAIN

# Check if wget is installed
if ! command -v wget &> /dev/null; then
    echo "wget not found. Installing wget..."
    apt-get update -y
    apt-get install wget -y
fi

# Download dacapo if not already downloaded
if [ ! -f "$DACAPO_PATH/dacapo-2006-10-MR2.jar" ]; then
    mkdir -p $DACAPO_PATH
    wget https://downloads.sourceforge.net/project/dacapobench/archive/2006-10-MR2/dacapo-2006-10-MR2.jar -O $DACAPO_PATH/dacapo-2006-10-MR2.jar
fi

# Install dependencies for JikesRVM if not already installed
if ! dpkg -s build-essential gcc-multilib gettext bison libgcc-s1:i386 libc6-dev-i386 zlib1g-dev:i386 >/dev/null 2>&1; then
    apt-get update -y
    apt-get install build-essential gcc-multilib gettext bison -y

    dpkg --add-architecture i386
    apt-get update
    apt-get install -y libgcc-s1:i386
    apt-get install -y libc6-dev-i386
    apt-get install -y zlib1g-dev:i386
fi


## Install dependencies for running ci_test_normal.sh (DaCapo benchmark require)
if ! dpkg -s ant libtool autotools-dev temurin-8-jdk >/dev/null 2>&1; then

    apt install ant -y

    #apt install temurin-8-jdk-amd64 (need solve GPG key)
    wget -O - https://packages.adoptium.net/artifactory/api/gpg/key/public | apt-key add -
    echo "deb https://packages.adoptium.net/artifactory/deb $(awk -F= '/^VERSION_CODENAME/{print$2}' /etc/os-release) main" |  tee /etc/apt/sources.list.d/adoptium.list
    apt update && apt install temurin-8-jdk -y

    apt install libtool -y
    apt install autotools-dev -y
fi