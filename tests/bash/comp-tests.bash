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
      echo "${RED}ERROR: No debug logs were printed to ${debugfile}${NC}"
      _completionTests_TEST_FAILED=1
   else
      echo "${GREEN}SUCCESS: Debug logs were printed to ${debugfile}${NC}"
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
      echo "${RED}ERROR: completion mistakenly created the file 'notexist'${NC}"
      _completionTests_TEST_FAILED=1
	  rm -f notexist
   else
      echo "${GREEN}SUCCESS: No extra file created, as expected${NC}"
   fi
}

ROOTDIR=$(pwd)
export PATH=$ROOTDIR/testprog/bin:$PATH

# Are we testing Cobra's bash completion v1 or v2?
BASHCOMP_VERSION=bash
if [ -n "$BASHCOMPV2" ]; then
    BASHCOMP_VERSION=bash2
fi

# Source the testing logic
source tests/bash/comp-test-lib.bash

# Setup completion of testprog, disabling descriptions (which is important for v2)
# Don't use the new source <() form as it does not work with bash v3.
# Normally, compopt is a builtin, and the script checks that it is a
# builtin to disable it if we are in bash3 (where compopt does not exist).
# We replace 'builtin' with 'function' because we cannot use the native
# compopt since we are explicitely calling the completion code instead
# of from within a real completion environment.
source /dev/stdin <<- EOF
   $(testprog completion --no-descriptions $BASHCOMP_VERSION | sed s/builtin/function/g)
EOF

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
# Special characters
#################################################
if [ "$BASHCOMP_VERSION" = bash2 ]; then
    # When there are may completions that match, these completions will be shown in a list
    # and we do not escape them.  We only escape them when there is a single completion as it
    # will be inserted directly into the command line.
    _completionTests_verifyCompletion 'testprog prefix special-chars bash' 'bash1 space bash2\escape bash3\ escaped\ space bash4>redirect bash5#comment bash6$var bash7|pipe bash8;semicolon bash9=equals bashA:colon' nofile

    _completionTests_verifyCompletion 'testprog prefix special-chars bash1' 'bash1\ space' nofile
    _completionTests_verifyCompletion 'testprog prefix special-chars bash1 ' '' nofile

    _completionTests_verifyCompletion 'testprog prefix special-chars bash2' 'bash2\\escape' nofile
    _completionTests_verifyCompletion 'testprog prefix special-chars bash2\\e' 'bash2\\escape' nofile
    _completionTests_verifyCompletion 'testprog prefix special-chars bash2e' '' nofile
    _completionTests_verifyCompletion 'testprog prefix special-chars bash2\e' '' nofile

    _completionTests_verifyCompletion 'testprog prefix special-chars bash3' 'bash3\\\ escaped\\\ space' nofile
    _completionTests_verifyCompletion 'testprog prefix special-chars bash3\\' 'bash3\\\ escaped\\\ space' nofile
    _completionTests_verifyCompletion 'testprog prefix special-chars bash3\ ' '' nofile

    _completionTests_verifyCompletion 'testprog prefix special-chars bash4' 'bash4\>redirect' nofile
    _completionTests_verifyCompletion 'testprog prefix special-chars bash4\>' 'bash4\>redirect' nofile
    # Surprisingly, bash still calls the completion function with an unescaped redirect, but it does not
    # pass the directive appropriately.  This looks like a bug in bash.  Either way, we want our
    # script to return no completion so as to let bash do file completion.
    _completionTests_verifyCompletion 'testprog prefix special-chars bash4>' ''

    _completionTests_verifyCompletion 'testprog prefix special-chars bash5#c' 'bash5#comment' nofile

    _completionTests_verifyCompletion 'testprog prefix special-chars bash6\$v' 'bash6\$var' nofile
    # Bash still calls the completion function with an unescaped variable
    # Furthermore, compgen ignores escape characters when matchging, so bash6\$var matches bash6$v
    _completionTests_verifyCompletion 'testprog prefix special-chars bash6$v' 'bash6\$var' nofile

    _completionTests_verifyCompletion 'testprog prefix special-chars bash7\|p' 'bash7\|pipe' nofile
    # In practice, bash justifiably does not call our completion script in the below case
    # because after the pipe (|), it expects another command.  So, we don't need to test this.
    #  _completionTests_verifyCompletion 'testprog prefix special-chars bash7|p' ''

    _completionTests_verifyCompletion 'testprog prefix special-chars bash8\;s' 'bash8\;semicolon' nofile
    # In practice, bash justifiably does not call our completion script in the below case
    # because after the semicolon (;), it expects another command.  So, we don't need to test this.
    #  _completionTests_verifyCompletion 'testprog prefix special-chars bash8;s' '''

    _completionTests_verifyCompletion 'testprog prefix special-chars bash9=e' 'equals' nofile
    _completionTests_verifyCompletion 'testprog prefix special-chars bashA:c' 'colon' nofile
fi

#################################################
# Special cases
#################################################
# Test when there is a space before the binary name
# https://github.com/spf13/cobra/issues/1303
_completionTests_verifyCompletion " testprog prefix default u" "unicorn"

# Test using env variable and ~
# https://github.com/spf13/cobra/issues/1306
OLD_HOME=$HOME
HOME=$(mktemp -d)
cp $ROOTDIR/testprog/bin/testprog $HOME/
# Must use single quotes to keep the environment variable
_completionTests_verifyCompletion '$HOME/testprog prefix default u' "unicorn"
_completionTests_verifyCompletion "~/testprog prefix default u" "unicorn"
rm $HOME/testprog
rmdir $HOME
HOME=$OLD_HOME

# An argument starting with dashes
_completionTests_verifyCompletion "testprog dasharg " "--arg"
# Needs bash completion v2
#_completionTests_verifyCompletion "testprog dasharg -- --" "--arg"

# Test debug printouts
verifyDebug

# Test completion with a redirection
# https://github.com/spf13/cobra/issues/1334
if [ $BASH_VERSINFO != 3 ]; then
   # We know and accept that this fails with bash 3
   # https://github.com/spf13/cobra/issues/1334
   verifyRedirect
fi

# Measure speed of execution without descriptions (for both v1 and v2)
_completionTests_timing "testprog manycomps " 0.2 "no descriptions"

# COMP_TYPE does not get set by bash 3
if [ $BASH_VERSINFO != 3 ]; then
   # Test other bash completion types with descriptions disabled.
   # There should be no change in behaviour when there are no descriptions.
   # The types are: menu-complete/menu-complete-backward (COMP_TYPE == 37)
   # and insert-completions (COMP_TYPE == 42)
   COMP_TYPE=37
   _completionTests_verifyCompletion "testprog prefix nospace b" "bear bearpaw" nospace
   _completionTests_verifyCompletion "testprog prefix nofile b" "bear bearpaw" nofile

   # Measure speed of execution with menu-complete without descriptions (for both v1 and v2)
   _completionTests_timing "testprog manycomps " 0.2 "menu-complete no descs"

   COMP_TYPE=42
   _completionTests_verifyCompletion "testprog prefix nospace b" "bear bearpaw" nospace
   _completionTests_verifyCompletion "testprog prefix nofile b" "bear bearpaw" nofile

   # Measure speed of execution with insert-completions without descriptions (for both v1 and v2)
   _completionTests_timing "testprog manycomps " 0.2 "insert-completions no descs"

   unset COMP_TYPE
fi

# Test descriptions of bash v2
if [ "$BASHCOMP_VERSION" = bash2 ]; then

  # Setup completion of testprog, enabling descriptions for v2.
  # Don't use the new source <() form as it does not work with bash v3.
  # Normally, compopt is a builtin, and the script checks that it is a
  # builtin to disable it if we are in bash3 (where compopt does not exist).
  # We replace 'builtin' with 'function' because we cannot use the native
  # compopt since we are explicitely calling the completion code instead
  # of from within a real completion environment.
  source /dev/stdin <<- EOF
     $(testprog completion --no-descriptions=false $BASHCOMP_VERSION | sed s/builtin/function/g)
EOF

   # Disable sorting of output because it would mix up the descriptions
   BASH_COMP_NO_SORT=1

   # When running docker without the --tty/-t flag, the COLUMNS variable is not set
   # bash completion v2 needs it to handle descriptions, so we set it here if it is unset
   COLUMNS=${COLUMNS-100}

   # Test descriptions with ShellCompDirectiveDefault
   _completionTests_verifyCompletion "testprog prefix default " "bear     (an animal) bearpaw  (a dessert) dog unicorn  (mythical)"
   _completionTests_verifyCompletion "testprog prefix default b" "bear     (an animal) bearpaw  (a dessert)"
   _completionTests_verifyCompletion "testprog prefix default bearp" "bearpaw"

   # Test descriptions with ShellCompDirectiveNoFileComp
   _completionTests_verifyCompletion "testprog prefix nofile " "bear     (an animal) bearpaw  (a dessert) dog unicorn  (mythical)" nofile
   _completionTests_verifyCompletion "testprog prefix nofile b" "bear     (an animal) bearpaw  (a dessert)" nofile
   _completionTests_verifyCompletion "testprog prefix nofile bearp" "bearpaw" nofile

   # Test descriptions with ShellCompDirectiveNoSpace
   _completionTests_verifyCompletion "testprog prefix nospace " "bear     (an animal) bearpaw  (a dessert) dog unicorn  (mythical)" nospace
   _completionTests_verifyCompletion "testprog prefix nospace b" "bear     (an animal) bearpaw  (a dessert)" nospace
   _completionTests_verifyCompletion "testprog prefix nospace bearp" "bearpaw" nospace

   # Test descriptions with completion of flag values
   _completionTests_verifyCompletion "testprog --customComp " "firstComp   (the first value) secondComp  (the second value) forthComp" nofile
   _completionTests_verifyCompletion "testprog --customComp f" "firstComp  (the first value) forthComp" nofile
   _completionTests_verifyCompletion "testprog --customComp fi" "firstComp" nofile

   # Measure speed of execution with descriptions
   _completionTests_timing "testprog manycomps " 0.5 "with descriptions"

   ############################
   # Special character handling
   ############################
   # When there are may completions that match, these completions will be shown in a list
   # and we do not escape them.  We only escape them when there is a single completion as it
   # will be inserted directly into the command line.
   _completionTests_verifyCompletion 'testprog prefix special-chars bash' "\
bash1 space            (with space) \
bash2\escape           (with escape) \
bash3\ escaped\ space  (with escape and space) \
bash4>redirect         (with redirect) \
bash5#comment          (with comment) \
bash6\$var              (with var) \
bash7|pipe             (with pipe) \
bash8;semicolon        (with semicolon) \
bash9=equals           (with equal) \
bashA:colon            (with colon)" nofile

   _completionTests_verifyCompletion 'testprog prefix special-chars bash1' 'bash1\ space' nofile
   _completionTests_verifyCompletion 'testprog prefix special-chars bash1 ' '' nofile

   _completionTests_verifyCompletion 'testprog prefix special-chars bash2' 'bash2\\escape' nofile
   _completionTests_verifyCompletion 'testprog prefix special-chars bash2\\e' 'bash2\\escape' nofile
   _completionTests_verifyCompletion 'testprog prefix special-chars bash2e' '' nofile
   _completionTests_verifyCompletion 'testprog prefix special-chars bash2\e' '' nofile

   _completionTests_verifyCompletion 'testprog prefix special-chars bash3' 'bash3\\\ escaped\\\ space' nofile
   _completionTests_verifyCompletion 'testprog prefix special-chars bash3\\' 'bash3\\\ escaped\\\ space' nofile
   _completionTests_verifyCompletion 'testprog prefix special-chars bash3\ ' '' nofile

   _completionTests_verifyCompletion 'testprog prefix special-chars bash4' 'bash4\>redirect' nofile
   _completionTests_verifyCompletion 'testprog prefix special-chars bash4\>' 'bash4\>redirect' nofile
   # Surprisingly, bash still calls the completion function with an unescaped redirect, but it does not
   # pass the directive appropriately.  This looks like a bug in bash.  Either way, we want our
   # script to return no completion so as to let bash do file completion.
   _completionTests_verifyCompletion 'testprog prefix special-chars bash4>' ''

   _completionTests_verifyCompletion 'testprog prefix special-chars bash5#c' 'bash5#comment' nofile

   _completionTests_verifyCompletion 'testprog prefix special-chars bash6\$v' 'bash6\$var' nofile
   # Bash still calls the completion function with an unescaped variable
   _completionTests_verifyCompletion 'testprog prefix special-chars bash6$v' '' nofile

   _completionTests_verifyCompletion 'testprog prefix special-chars bash7\|p' 'bash7\|pipe' nofile
   # In practice, bash justifiably does not call our completion script in the below case
   # because after the pipe (|), it expects another command.  So, we don't need to test this.
   #  _completionTests_verifyCompletion 'testprog prefix special-chars bash7|p' ''

   _completionTests_verifyCompletion 'testprog prefix special-chars bash8\;s' 'bash8\;semicolon' nofile
   # In practice, bash justifiably does not call our completion script in the below case
   # because after the semicolon (;), it expects another command.  So, we don't need to test this.
   #  _completionTests_verifyCompletion 'testprog prefix special-chars bash8;s' '''

   _completionTests_verifyCompletion 'testprog prefix special-chars bash9=e' 'equals' nofile
   _completionTests_verifyCompletion 'testprog prefix special-chars bashA:c' 'colon' nofile
   ##################################
   # end of pecial character handling
   ##################################

   # COMP_TYPE does not get set by bash 3
   if [ $BASH_VERSINFO != 3 ]; then
      # Test descriptions are properly removed when using other bash completion types
      # The types are: menu-complete/menu-complete-backward (COMP_TYPE == 37)
      # and insert-completions (COMP_TYPE == 42)
      COMP_TYPE=37
      _completionTests_verifyCompletion "testprog prefix nospace b" "bear bearpaw" nospace
      _completionTests_verifyCompletion "testprog prefix nofile b" "bear bearpaw" nofile

      # Measure speed of execution with menu-complete with descriptions
      _completionTests_timing "testprog manycomps " 0.2 "menu-complete with descs"

      COMP_TYPE=42
      _completionTests_verifyCompletion "testprog prefix nospace b" "bear bearpaw" nospace
      _completionTests_verifyCompletion "testprog prefix nofile b" "bear bearpaw" nofile

      # Measure speed of execution with insert-completions with descriptions
      _completionTests_timing "testprog manycomps " 0.2 "insert-completions no descs"

      unset COMP_TYPE
   fi
fi

# This must be the last call.  It allows to exit with an exit code
# that reflects the final status of all the tests.
_completionTests_exit
