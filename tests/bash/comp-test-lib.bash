#!bash

echo "===================================================="
echo Running completions tests on $UNAME with $SHELL_TYPE $BASH_VERSION
echo "===================================================="

# Setup bash_completion package
bashCompletionScript="/usr/share/bash-completion/bash_completion"
if [ $(uname) = "Darwin" ]; then
   bashCompletionScript="/usr/local/etc/bash_completion"
fi
source ${bashCompletionScript}

# Put test program on PATH
export PATH=$TESTPROG_DIR/bin:$PATH

# Setup completion of testprog
# Don't use the new source <() form as it does not work with bash v3
source /dev/stdin <<- EOF
   $(testprog completion ${SHELL_TYPE})
EOF

# Enable aliases to work even though we are in a script (non-interactive shell).
# This allows to test completion with aliases.
# Only needed for bash; zsh does this automatically.
shopt -s expand_aliases

# Global variable to keep track of if a test has failed.
_completionTests_TEST_FAILED=0

# Run completion and indicate success or failure.
#    $1 is the command line that should be completed
#    $2 is the expected result of the completion
_completionTests_verifyCompletion() {
    local cmdLine=$1
    local expected=$2
    local currentFailure=0

    result=$(_completionTests_complete "${cmdLine}")

    result=$(_completionTests_sort "$result")
    expected=$(_completionTests_sort "$expected")

    if [ "$result" = "$expected" ]; then
        # Truncate result to save space
        resultOut="$result"
        if [ "${#result}" -gt 50 ]; then
            resultOut="${result:0:50} <truncated>"
        fi
        echo "SUCCESS: \"$cmdLine\" completes to \"$resultOut\""
    else
        _completionTests_TEST_FAILED=1
        currentFailure=1
        echo "ERROR: \"$cmdLine\" should complete to \"$expected\" but we got \"$result\""
    fi

    return $currentFailure
}

_completionTests_sort() {
   # We use printf instead of echo as the $1 could be -n which would be
   # interpreted as an argument to echo
   printf "%s\n" "$1" | sed -e 's/^ *//' -e 's/ *$//' | tr ' ' '\n' | sort -n | tr '\n' ' '
}

# Find the completion function associated with the binary.
# $1 is the first argument of the line to complete which allows
# us to find the existing completion function name.
_completionTests_findCompletionFunction() {
    binary=$(basename $1)
    # The below must work for both bash and zsh
    # which is why we use grep as complete -p $binary only works for bash
    local out=($(complete -p | grep ${binary}$))
    local returnNext=0
    for i in ${out[@]}; do
       if [ $returnNext -eq 1 ]; then
          echo "$i"
          return
       fi
       [ "$i" = "-F" ] && returnNext=1
    done
}

_completionTests_complete() {
   local cmdLine=$1

   # Set the bash completion variables which are
   # used for both bash and zsh completion
   COMP_LINE=${cmdLine}
   COMP_POINT=${#COMP_LINE}
   COMP_TYPE=9 # 9 is TAB
   COMP_KEY=9  # 9 is TAB
   COMP_WORDS=($(echo ${cmdLine}))

   COMP_CWORD=$((${#COMP_WORDS[@]}-1))
   # We must check for a space as the last character which will tell us
   # that the previous word is complete and the cursor is on the next word.
   [ "${cmdLine: -1}" = " " ] && COMP_CWORD=${#COMP_WORDS[@]}

   # Call the completion function associated with the binary being called.
   # Also redirect stderr to stdout so that the tests fail if anything is printed
   # to stderr.
   eval $(_completionTests_findCompletionFunction ${COMP_WORDS[0]}) 2>&1

   # Return the result of the completion.
   # We use printf instead of echo as the first completion could be -n which
   # would be interpreted as an argument to echo
   printf "%s\n" "${COMPREPLY[@]}"
}

_completionTests_exit() {
   # Return the global result each time.  This allows for the very last call to
   # this method to return the correct success or failure code for the entire script
   return $_completionTests_TEST_FAILED
}

# compopt, which is only available for bash 4, I believe,
# prints an error when it is being called outside of real shell
# completion.  Since it doesn't work anyway in our case, let's
# disable it to avoid the error printouts.
# Impacts are limited to completion of flags and even then
# for bash 3, it is not even available.
compopt() {
   :
}
