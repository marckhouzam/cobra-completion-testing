#!/usr/bin/env bash

export SHELL_TYPE=$1
export PATH=${COMP_DIR}/bin:$PATH

case "$SHELL_TYPE" in
"")
    echo "Missing parameter for shell to test"
    exit 1
    ;;
bash)
    bash -c "source ${COMP_DIR}/run-completionTests.bash"
    ;;
zsh)
    zsh -c "source ${COMP_DIR}/run-completionTests.zsh"
    ;;
fish)
    fish -c "source ${COMP_DIR}/run-completionTests.fish"
    ;;
powershell)
    pwsh -c "source ${COMP_DIR}/run-completionTests.pwsh"
    ;;
*)
    echo "Invalid shell to test: $SHELL_TYPE"
    exit 1
    ;;
esac
