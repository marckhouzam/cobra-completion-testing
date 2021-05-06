#!/usr/bin/env fish

echo "===================================================="
echo Running completions tests on (uname) with fish $version
echo "===================================================="

set ROOTDIR (pwd)
set PATH $ROOTDIR/testprog/bin:$PATH

# Source the testing logic
source tests/fish/comp-test-lib.fish

#################################################
# Setup completion with descriptions
#################################################
testprog completion fish | source

cd testingdir

# Basic first level commands (static completion)
_completionTests_verifyCompletion "testprog comp" "completion"
_completionTests_verifyCompletion "testprog help comp" "completion"
_completionTests_verifyCompletion "testprog completion " "bash bash2 fish powershell zsh"
_completionTests_verifyCompletion "testprog completion bash " ""

#################################################
# Completions are filtered by prefix by program
#################################################

# Test ShellCompDirectiveDefault => File completion when no other completions
_completionTests_verifyCompletion "testprog prefix default " "bear	an animal bearpaw	a dessert dog unicorn	mythical"
_completionTests_verifyCompletion "testprog prefix default u" "unicorn	mythical"
_completionTests_verifyCompletion "testprog prefix default f" "file"
_completionTests_verifyCompletion "testprog prefix default z" ""

# Test ShellCompDirectiveNoFileComp => No file completion even when there are no other completions
_completionTests_verifyCompletion "testprog prefix nofile " "bear	an animal bearpaw	a dessert dog unicorn	mythical"
_completionTests_verifyCompletion "testprog prefix nofile u" "unicorn	mythical"
_completionTests_verifyCompletion "testprog prefix nofile f" ""
_completionTests_verifyCompletion "testprog prefix nofile z" ""

# Test ShellCompDirectiveNoSpace => No space even when there is a single completion
_completionTests_verifyCompletion "testprog prefix nospace " "bear	an animal bearpaw	a dessert dog unicorn	mythical"
_completionTests_verifyCompletion "testprog prefix nospace b" "bear	an animal bearpaw	a dessert"
_completionTests_verifyCompletion "testprog prefix nospace u" "unicorn unicorn."
_completionTests_verifyCompletion "testprog prefix nospace f" "file"
_completionTests_verifyCompletion "testprog prefix nospace z" ""
_completionTests_verifyCompletion "testprog prefix nofilenospace " "bear	an animal bearpaw	a dessert dog unicorn	mythical"
_completionTests_verifyCompletion "testprog prefix nofilenospace b" "bear	an animal bearpaw	a dessert"
_completionTests_verifyCompletion "testprog prefix nofilenospace u" "unicorn unicorn."
_completionTests_verifyCompletion "testprog prefix nofilenospace f" ""
_completionTests_verifyCompletion "testprog prefix nofilenospace z" ""

# Test ShellCompDirectiveNoSpace => when completion ends with any of @=/:.,
# in which case fish won't add a space automatically
_completionTests_verifyCompletion "testprog prefix nospacechar at" "at@"
_completionTests_verifyCompletion "testprog prefix nospacechar equal" "equal="
_completionTests_verifyCompletion "testprog prefix nospacechar slash" "slash/"
_completionTests_verifyCompletion "testprog prefix nospacechar colon" "colon:"
_completionTests_verifyCompletion "testprog prefix nospacechar period" "period."
_completionTests_verifyCompletion "testprog prefix nospacechar comma" "comma,"
_completionTests_verifyCompletion "testprog prefix nospacechar letter" "letter letter."

#################################################
# Completions are NOT filtered by prefix by the program
#################################################

# When not allowing file completion, we can get smarter completions from fish
# when the program does not filter by prefix
_completionTests_verifyCompletion "testprog noprefix nofile paw" "bearpaw	a dessert"

# Test ShellCompDirectiveDefault => File completion when no other completions
_completionTests_verifyCompletion "testprog noprefix default u" "unicorn	mythical"
_completionTests_verifyCompletion "testprog noprefix default f" "file"
_completionTests_verifyCompletion "testprog noprefix default z" ""

# Test ShellCompDirectiveNoFileComp => No file completion even when there are no other completions
_completionTests_verifyCompletion "testprog noprefix nofile u" "unicorn	mythical"
_completionTests_verifyCompletion "testprog noprefix nofile f" ""
_completionTests_verifyCompletion "testprog noprefix nofile z" ""

# Test ShellCompDirectiveNoSpace => No space even when there is a single completion
_completionTests_verifyCompletion "testprog noprefix nospace b" "bear	an animal bearpaw	a dessert"
_completionTests_verifyCompletion "testprog noprefix nospace u" "unicorn unicorn."
_completionTests_verifyCompletion "testprog noprefix nospace f" "file"
_completionTests_verifyCompletion "testprog noprefix nospace z" ""
_completionTests_verifyCompletion "testprog noprefix nofilenospace b" "bear	an animal bearpaw	a dessert"
_completionTests_verifyCompletion "testprog noprefix nofilenospace u" "unicorn unicorn."
_completionTests_verifyCompletion "testprog noprefix nofilenospace f" ""
_completionTests_verifyCompletion "testprog noprefix nofilenospace z" ""

#################################################
# Other directives
#################################################
# Test ShellCompDirectiveFilterFileExt => Not supported for fish, file completion instead
_completionTests_verifyCompletion "testprog fileext f" "file"
_completionTests_verifyCompletion "testprog fileext z" ""

# Test ShellCompDirectiveFilterDirs => Not supported for fish, file completion instead
_completionTests_verifyCompletion "testprog dir f" "file"
_completionTests_verifyCompletion "testprog subdir f" "file"
_completionTests_verifyCompletion "testprog subdir z" ""
_completionTests_verifyCompletion "testprog --theme f" "file"
_completionTests_verifyCompletion "testprog --theme z" ""
_completionTests_verifyCompletion "testprog --theme=f" "--theme=file"
_completionTests_verifyCompletion "testprog --theme=z" ""

# Test ShellCompDirectiveError => File completion only
_completionTests_verifyCompletion "testprog error f" "file"
_completionTests_verifyCompletion "testprog error z" ""

#################################################
# Flags
#################################################
_completionTests_verifyCompletion "testprog --custom" "--customComp	test custom comp for flags"
_completionTests_verifyCompletion "testprog --customComp " "firstComp	the first value secondComp	the second value forthComp"
_completionTests_verifyCompletion "testprog --customComp f" "firstComp	the first value forthComp"
_completionTests_verifyCompletion "testprog --customComp=" "--customComp=firstComp	the first value --customComp=secondComp	the second value --customComp=forthComp"
_completionTests_verifyCompletion "testprog --customComp=f" "--customComp=firstComp	the first value --customComp=forthComp"

#################################################
# Special cases
#################################################
# Test when there is a space before the binary name
# https://github.com/spf13/cobra/issues/1303
_completionTests_verifyCompletion " testprog prefix default u" "unicorn	mythical"

# Test using env variable and ~
# https://github.com/spf13/cobra/issues/1306
set OLD_HOME $HOME
set HOME /tmp
cp $ROOTDIR/testprog/bin/testprog $HOME/
_completionTests_verifyCompletion '$HOME/testprog prefix default u' "unicorn	mythical"
# Must use single quotes to keep the environment variable
_completionTests_verifyCompletion "~/testprog prefix default u" "unicorn	mythical"
set HOME $OLD_HOME

# An argument starting with dashes
_completionTests_verifyCompletion "testprog dasharg " "--arg	an arg starting with dashes"
_completionTests_verifyCompletion "testprog dasharg -- --" "--arg	an arg starting with dashes"

# Multiple commands on the same line
_completionTests_verifyCompletion "echo hello; testprog comp" "completion"

# Unmatched quote
# https://github.com/spf13/cobra/issues/1214
# If there is a regression with this tests, we will see some error printouts from fish, even
# though we may not get an error code. 
_completionTests_verifyCompletion "testprog '" ""

# Test debug printouts
_completionTests_verifyDebug

#############################
# Disable descriptions
#############################
testprog completion fish --no-descriptions | source

_completionTests_verifyCompletion "testprog prefix default " "bear bearpaw dog unicorn"
_completionTests_verifyCompletion " testprog prefix default u" "unicorn"
_completionTests_verifyCompletion "testprog noprefix nofile paw" "bearpaw"
_completionTests_verifyCompletion "testprog --custom" "--customComp"
_completionTests_verifyCompletion "testprog --customComp " "firstComp secondComp forthComp"
_completionTests_verifyCompletion "testprog --customComp f" "firstComp forthComp"
_completionTests_verifyCompletion "testprog --customComp=" "--customComp=firstComp --customComp=secondComp --customComp=forthComp"
_completionTests_verifyCompletion "testprog --customComp=f" "--customComp=firstComp --customComp=forthComp"
_completionTests_verifyDebug

# This must be the last call.  It allows to exit with an exit code
# that reflects the final status of all the tests.
_completionTests_exit