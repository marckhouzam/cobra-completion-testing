#!/usr/bin/env bash

export SHELL_TYPE=$1
export PATH=${COMP_DIR}/bin:$PATH

case "$SHELL_TYPE" in
"")
    echo "Missing parameter for shell to test"
    exit 1
    ;;
bash|fish|zsh)
    $SHELL_TYPE -c "source $COMP_DIR/$SHELL_TYPE/run-comp-tests.$SHELL_TYPE"
    ;;
*)
    echo "Invalid shell to test: $SHELL_TYPE"
    exit 1
    ;;
esac
