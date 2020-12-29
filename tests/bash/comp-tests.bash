#!sh

echo "===================================================="
echo Running completions tests on $(uname) with bash $BASH_VERSION
echo "===================================================="

cd $TESTING_DIR

# Source the testing logic
source $TESTS_DIR/bash/comp-test-lib.bash

export PATH=$TESTPROG_DIR/bin:$PATH

# Setup completion of testprog
# Don't use the new source <() form as it does not work with bash v3
source /dev/stdin <<- EOF
   $(testprog completion bash)
EOF

# Basic first level commands (static completion)
_completionTests_verifyCompletion "testprog comp" "completion"
_completionTests_verifyCompletion "testprog help comp" "completion"
_completionTests_verifyCompletion "testprog completion " "bash fish zsh"

#################################################
# Completions are filtered by prefix by program
#################################################

# Test ShellCompDirectiveDefault => File completion when no other completions
_completionTests_verifyCompletion "testprog prefix default " "bear bearpaw dog unicorn"
_completionTests_verifyCompletion "testprog prefix default u" "unicorn"
_completionTests_verifyCompletion "testprog prefix default f" ""
_completionTests_verifyCompletion "testprog prefix default z" ""

# Test ShellCompDirectiveNoFileComp => No file completion even when there are no other completions
_completionTests_verifyCompletion "testprog prefix nofile " "bear bearpaw dog unicorn"
_completionTests_verifyCompletion "testprog prefix nofile u" "unicorn"
_completionTests_verifyCompletion "testprog prefix nofile f" ""
_completionTests_verifyCompletion "testprog prefix nofile z" ""

# Test ShellCompDirectiveNoSpace => No space even when there is a single completion
_completionTests_verifyCompletion "testprog prefix nospace " "bear bearpaw dog unicorn"
_completionTests_verifyCompletion "testprog prefix nospace b" "bear bearpaw"
_completionTests_verifyCompletion "testprog prefix nospace u" "unicorn"
_completionTests_verifyCompletion "testprog prefix nospace f" ""
_completionTests_verifyCompletion "testprog prefix nospace z" ""
_completionTests_verifyCompletion "testprog prefix nofilenospace " "bear bearpaw dog unicorn"
_completionTests_verifyCompletion "testprog prefix nofilenospace b" "bear bearpaw"
_completionTests_verifyCompletion "testprog prefix nofilenospace u" "unicorn"
_completionTests_verifyCompletion "testprog prefix nofilenospace f" ""
_completionTests_verifyCompletion "testprog prefix nofilenospace z" ""

#################################################
# Completions are NOT filtered by prefix by the program
#################################################

# Test ShellCompDirectiveDefault => File completion when no other completions
_completionTests_verifyCompletion "testprog noprefix default u" "unicorn"
_completionTests_verifyCompletion "testprog noprefix default f" ""
_completionTests_verifyCompletion "testprog noprefix default z" ""

# Test ShellCompDirectiveNoFileComp => No file completion even when there are no other completions
_completionTests_verifyCompletion "testprog noprefix nofile u" "unicorn"
_completionTests_verifyCompletion "testprog noprefix nofile f" ""
_completionTests_verifyCompletion "testprog noprefix nofile z" ""

# Test ShellCompDirectiveNoSpace => No space even when there is a single completion
_completionTests_verifyCompletion "testprog noprefix nospace b" "bear bearpaw"
_completionTests_verifyCompletion "testprog noprefix nospace u" "unicorn"
_completionTests_verifyCompletion "testprog noprefix nospace f" ""
_completionTests_verifyCompletion "testprog noprefix nospace z" ""
_completionTests_verifyCompletion "testprog noprefix nofilenospace b" "bear bearpaw"
_completionTests_verifyCompletion "testprog noprefix nofilenospace u" "unicorn"
_completionTests_verifyCompletion "testprog noprefix nofilenospace f" ""
_completionTests_verifyCompletion "testprog noprefix nofilenospace z" ""

#################################################
# Other directives
#################################################
# Test ShellCompDirectiveFilterFileExt
_completionTests_verifyCompletion "testprog fileext setup" "setup.json setup.yaml"

# Test ShellCompDirectiveFilterDirs
_completionTests_verifyCompletion "testprog dir di" "dir dir2"
_completionTests_verifyCompletion "testprog subdir " "jsondir txtdir yamldir"
_completionTests_verifyCompletion "testprog subdir j" "jsondir"
_completionTests_verifyCompletion "testprog --theme " "jsondir txtdir yamldir"
_completionTests_verifyCompletion "testprog --theme t" "txtdir"
_completionTests_verifyCompletion "testprog --theme=" "jsondir txtdir yamldir"
_completionTests_verifyCompletion "testprog --theme=t" "txtdir"

# Test ShellCompDirectiveError => File completion only
_completionTests_verifyCompletion "testprog error u" ""

#################################################
# Flags
#################################################
_completionTests_verifyCompletion "testprog --custom" "--customComp --customComp="
_completionTests_verifyCompletion "testprog --customComp " "firstComp secondComp forthComp"
_completionTests_verifyCompletion "testprog --customComp f" "firstComp forthComp"
_completionTests_verifyCompletion "testprog --customComp=" "firstComp secondComp forthComp"
_completionTests_verifyCompletion "testprog --customComp=f" "firstComp forthComp"

#################################################
# Special cases
#################################################
# Test when there is a space before the binary name
# https://github.com/spf13/cobra/issues/1303
_completionTests_verifyCompletion " testprog prefix default u" "unicorn"

# Test debug printouts
_completionTests_verifyDebug

# This must be the last call.  It allows to exit with an exit code
# that reflects the final status of all the tests.
_completionTests_exit