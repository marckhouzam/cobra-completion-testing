#!/usr/bin/env bash

echo "===================================================="
echo Running completions tests on $(uname) with bash $BASH_VERSION
echo "===================================================="

# Test logging using $BASH_COMP_DEBUG_FILE
verifyDebug() {
   debugfile=/tmp/comptests.bash.debug
   rm -f $debugfile
   export BASH_COMP_DEBUG_FILE=$debugfile
   _completionTests_verifyCompletion "testprog help comp" "completion" nofile
   if ! test -s $debugfile; then
      # File should not be empty
      echo -e "${RED}ERROR: No debug logs were printed to ${debugfile}${NC}"
      _completionTests_TEST_FAILED=1
   else
      echo -e "${GREEN}SUCCESS: Debug logs were printed to ${debugfile}${NC}"
   fi
   unset BASH_COMP_DEBUG_FILE
}

# Test completion with a redirection
# https://github.com/spf13/cobra/issues/1334
verifyRedirect() {
   rm -f notexist
   _completionTests_verifyCompletion "testprog completion bash > notexist" ""
   if test -f notexist; then
      # File should not exist
      echo -e "${RED}ERROR: completion mistakenly created the file 'notexist'${NC}"
      _completionTests_TEST_FAILED=1
	  rm -f notexist
   else
      echo -e "${GREEN}SUCCESS: No extra file created, as expected${NC}"
   fi
}

ROOTDIR=$(pwd)
export PATH=$ROOTDIR/testprog/bin:$PATH

# Are we testing Cobra's bash completion v1 or v2?
BASHCOMP_VERSION=bash
NO_DESC=""
if [ -n "$BASHCOMPV2" ]; then
    BASHCOMP_VERSION=bash2
    # When running docker without the --tty/-t flag, the COLUMNS variable is not set
    # bash completion v2 needs it to handle descriptions, so we set it here if it is unset
    COLUMNS=${COLUMNS-100}

    # FIXME Turn off descriptions for now
    NO_DESC="--no-descriptions"
fi

# Source the testing logic
source tests/bash/comp-test-lib.bash

cd testingdir

# Basic first level commands (static completion)
if [ "$BASHCOMP_VERSION" = bash2 ]; then
    _completionTests_verifyCompletion "testprog comp" "completion" nofile
    _completionTests_verifyCompletion "testprog completion " "bash bash2 fish powershell zsh" nofile
else
    _completionTests_verifyCompletion "testprog comp" "completion"
    _completionTests_verifyCompletion "testprog completion " "bash bash2 fish powershell zsh"
fi
_completionTests_verifyCompletion "testprog help comp" "completion" nofile
_completionTests_verifyCompletion "testprog completion bash " "" nofile

#################################################
# Completions are filtered by prefix by program
#################################################

# Test ShellCompDirectiveDefault => File completion when no other completions
_completionTests_verifyCompletion "testprog prefix default " "bear bearpaw dog unicorn"
_completionTests_verifyCompletion "testprog prefix default u" "unicorn"
_completionTests_verifyCompletion "testprog prefix default f" ""
_completionTests_verifyCompletion "testprog prefix default z" ""

# Test ShellCompDirectiveNoFileComp => No file completion even when there are no other completions
_completionTests_verifyCompletion "testprog prefix nofile " "bear bearpaw dog unicorn" nofile
_completionTests_verifyCompletion "testprog prefix nofile u" "unicorn" nofile
_completionTests_verifyCompletion "testprog prefix nofile f" "" nofile
_completionTests_verifyCompletion "testprog prefix nofile z" "" nofile

# Test ShellCompDirectiveNoSpace => No space even when there is a single completion
_completionTests_verifyCompletion "testprog prefix nospace " "bear bearpaw dog unicorn" nospace
_completionTests_verifyCompletion "testprog prefix nospace b" "bear bearpaw" nospace
_completionTests_verifyCompletion "testprog prefix nospace u" "unicorn" nospace
_completionTests_verifyCompletion "testprog prefix nospace f" "" nospace
_completionTests_verifyCompletion "testprog prefix nospace z" "" nospace
_completionTests_verifyCompletion "testprog prefix nofilenospace " "bear bearpaw dog unicorn" nofile nospace
_completionTests_verifyCompletion "testprog prefix nofilenospace b" "bear bearpaw" nofile nospace
_completionTests_verifyCompletion "testprog prefix nofilenospace u" "unicorn" nofile nospace
_completionTests_verifyCompletion "testprog prefix nofilenospace f" "" nofile nospace
_completionTests_verifyCompletion "testprog prefix nofilenospace z" "" nofile nospace

#################################################
# Completions are NOT filtered by prefix by the program
#################################################

# Test ShellCompDirectiveDefault => File completion when no other completions
_completionTests_verifyCompletion "testprog noprefix default u" "unicorn"
_completionTests_verifyCompletion "testprog noprefix default f" ""
_completionTests_verifyCompletion "testprog noprefix default z" ""

# Test ShellCompDirectiveNoFileComp => No file completion even when there are no other completions
_completionTests_verifyCompletion "testprog noprefix nofile u" "unicorn" nofile
_completionTests_verifyCompletion "testprog noprefix nofile f" "" nofile
_completionTests_verifyCompletion "testprog noprefix nofile z" "" nofile

# Test ShellCompDirectiveNoSpace => No space even when there is a single completion
_completionTests_verifyCompletion "testprog noprefix nospace b" "bear bearpaw" nospace
_completionTests_verifyCompletion "testprog noprefix nospace u" "unicorn" nospace
_completionTests_verifyCompletion "testprog noprefix nospace f" "" nospace
_completionTests_verifyCompletion "testprog noprefix nospace z" "" nospace
_completionTests_verifyCompletion "testprog noprefix nofilenospace b" "bear bearpaw" nofile nospace
_completionTests_verifyCompletion "testprog noprefix nofilenospace u" "unicorn" nofile nospace
_completionTests_verifyCompletion "testprog noprefix nofilenospace f" "" nofile nospace
_completionTests_verifyCompletion "testprog noprefix nofilenospace z" "" nofile nospace

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
if [ "$BASHCOMP_VERSION" = bash2 ]; then
    _completionTests_verifyCompletion "testprog --custom" "--customComp" nofile
else
    _completionTests_verifyCompletion "testprog --custom" "--customComp --customComp=" nospace
fi
_completionTests_verifyCompletion "testprog --customComp " "firstComp secondComp forthComp" nofile
_completionTests_verifyCompletion "testprog --customComp f" "firstComp forthComp" nofile
_completionTests_verifyCompletion "testprog --customComp=" "firstComp secondComp forthComp" nofile
_completionTests_verifyCompletion "testprog --customComp=f" "firstComp forthComp" nofile

#################################################
# Special cases
#################################################
# Test when there is a space before the binary name
# https://github.com/spf13/cobra/issues/1303
_completionTests_verifyCompletion " testprog prefix default u" "unicorn"

# Test using env variable and ~
# https://github.com/spf13/cobra/issues/1306
OLD_HOME=$HOME
HOME=/tmp
cp $ROOTDIR/testprog/bin/testprog $HOME/
# Must use single quotes to keep the environment variable
_completionTests_verifyCompletion '$HOME/testprog prefix default u' "unicorn"
_completionTests_verifyCompletion "~/testprog prefix default u" "unicorn"
HOME=$OLD_HOME

# An argument starting with dashes
_completionTests_verifyCompletion "testprog dasharg " "--arg"
# Needs bash completion v2
#_completionTests_verifyCompletion "testprog dasharg -- --" "--arg"

# Test debug printouts
verifyDebug

# Test completion with a redirection
# https://github.com/spf13/cobra/issues/1334
verifyRedirect

# This must be the last call.  It allows to exit with an exit code
# that reflects the final status of all the tests.
_completionTests_exit