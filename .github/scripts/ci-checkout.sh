# ci-checkout.sh
set -ex

. $(dirname "$0")/common.sh


# Check if curl is installed
if ! command -v curl &> /dev/null; then
    echo "curl not found. Installing curl..."
    apt-get update -y
    apt-get install curl -y
fi

# Check if cargo is installed
if ! command -v cargo &> /dev/null; then
    echo "cargo not found. Installing Rust..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --profile minimal --default-toolchain $RUSTUP_TOOLCHAIN
    source "$HOME/.cargo/env"
fi


# Check if python3 is installed
if ! command -v python3 &> /dev/null; then
    echo "python3 not found. Installing python3..."
    apt-get update -y
    apt-get install python3 -y
fi
JIKESRVM_URL=$(cargo read-manifest --manifest-path=$BINDING_PATH/mmtk/Cargo.toml | python3 -c 'import json, sys; print(json.load(sys.stdin)["metadata"]["jikesrvm"]["jikesrvm_repo"])')
JIKESRVM_VERSION=$(cargo read-manifest --manifest-path=$BINDING_PATH/mmtk/Cargo.toml | python3 -c 'import json, sys; print(json.load(sys.stdin)["metadata"]["jikesrvm"]["jikesrvm_version"])')

# Modify the original URL to include the proxy
PROXY_URL="https://ghproxy.com/"
MODIFIED_JIKESRVM_URL="${PROXY_URL}${JIKESRVM_URL}"


# Check if git is installed
if ! command -v git &> /dev/null; then
    echo "git not found. Installing git..."
    apt-get update -y
    apt-get install git -y
fi

# Check if the repository exists
if [ ! -d "$JIKESRVM_PATH/.git" ]; then
    rm -rf $JIKESRVM_PATH
    git clone $MODIFIED_JIKESRVM_URL $JIKESRVM_PATH
fi

# Check if the desired commit version is reachable from the current branch
if git -C $JIKESRVM_PATH merge-base --is-ancestor "$JIKESRVM_VERSION" HEAD; then
    echo "Already at or ahead of the desired commit version. Skipping clone."
else
    git -C $JIKESRVM_PATH fetch
    git -C $JIKESRVM_PATH checkout $JIKESRVM_VERSION
fi
