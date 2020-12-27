#!/usr/bin/env sh

BASE_DIR=$(cd $(dirname "${BASH_SOURCE[0]}")/..; pwd)

export TESTS_DIR=${TESTS_DIR:-${BASE_DIR}/tests}
export TESTPROG_DIR=${TESTPROG_DIR:-${BASE_DIR}/testprog}
export TESTING_DIR=${TESTING_DIR:-${BASE_DIR}/testingdir}
export SHELL_TYPE=$1

case "$SHELL_TYPE" in
"")
    echo "Missing parameter for shell to test"
    exit 1
    ;;
bash|fish|zsh)
    export UNAME=$(uname)
    $SHELL_TYPE -c "source $TESTS_DIR/common/run.all"
    ;;
*)
    echo "Invalid shell to test: $SHELL_TYPE"
    exit 1
    ;;
esac
