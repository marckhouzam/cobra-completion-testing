#!bash

echo "===================================================="
echo "Running completions tests on $(uname) with bash $BASH_VERSION"
echo "===================================================="

# Enable aliases to work even though we are in a script (non-interactive shell).
# This allows to test completion with aliases.
# Only needed for bash; zsh does this automatically.
shopt -s expand_aliases

# Setup bash_completion package
bashCompletionScript="/usr/share/bash-completion/bash_completion"
if [ $(uname) = "Darwin" ]; then
   bashCompletionScript="/usr/local/etc/bash_completion"
fi
source ${bashCompletionScript}

source ${COMP_DIR}/completionTests-lib.bash
source ${COMP_DIR}/completionTests-common.sh
source ${COMP_DIR}/completionTests.bash