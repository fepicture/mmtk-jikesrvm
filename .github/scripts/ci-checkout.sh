# ci-checkout.sh
set -ex

. $(dirname "$0")/common.sh

# JIKESRVM_URL=`cargo read-manifest --manifest-path=$BINDING_PATH/mmtk/Cargo.toml | python3 -c 'import json,sys; print(json.load(sys.stdin)["metadata"]["jikesrvm"]["jikesrvm_repo"])'`
# JIKESRVM_VERSION=`cargo read-manifest --manifest-path=$BINDING_PATH/mmtk/Cargo.toml | python3 -c 'import json,sys; print(json.load(sys.stdin)["metadata"]["jikesrvm"]["jikesrvm_version"])'`

rm -rf $JIKESRVM_PATH
git clone https://fepicture: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@ghproxy.com/https://github.com/fepicture/jikesrvm.git $JIKESRVM_PATH
#git -C $JIKESRVM_PATH checkout $JIKESRVM_VERSION
