#!sh

#############################################################################
# This file holds all tests that apply to all shells (bash, zsh, fish)
# It cannot use any if statements since their syntax is not portable
# between shells.
#
# For tests that are specific to a shell, use the proper specific file.
#############################################################################

# Basic first level commands (static completion)
#_completionTests_verifyCompletion "testprog comp " "completion"
#_completionTests_verifyCompletion "testprog help comp" "completion"
#_completionTests_verifyCompletion "testprog completion " "bash fish zsh"


# Test logging using $BASH_COMP_DEBUG_FILE

# Test completion from middle of line

# Test --flag= form


# Test when completions are not filtered by prefix.  NoSpace and FileComp should still work.


#################################################
# Completions are filtered by prefix by program
#################################################

# Test ShellCompDirectiveDefault => File completion when no other completions
_completionTests_verifyCompletion "testprog prefix default " "bear bearpaw cat dog"
_completionTests_verifyCompletion "testprog prefix default c" "cat"
_completionTests_verifyCompletion "testprog prefix default f" "file"
_completionTests_verifyCompletion "testprog prefix default z" ""

# Test ShellCompDirectiveNoFileComp => No file completion even when there are no other completions
_completionTests_verifyCompletion "testprog prefix nofile " "bear bearpaw cat dog"
_completionTests_verifyCompletion "testprog prefix nofile c" "cat"
_completionTests_verifyCompletion "testprog prefix nofile f" ""
_completionTests_verifyCompletion "testprog prefix nofile z" ""

# Test ShellCompDirectiveNoSpace => No space even when there is a single completion
_completionTests_verifyCompletion "testprog prefix nospace " "bear bearpaw cat dog"
_completionTests_verifyCompletion "testprog prefix nospace b" "bear bearpaw"
_completionTests_verifyCompletion "testprog prefix nospace c" "cat cat."
_completionTests_verifyCompletion "testprog prefix nospace f" "file"
_completionTests_verifyCompletion "testprog prefix nospace z" ""
_completionTests_verifyCompletion "testprog prefix nofilenospace " "bear bearpaw cat dog"
_completionTests_verifyCompletion "testprog prefix nofilenospace b" "bear bearpaw"
_completionTests_verifyCompletion "testprog prefix nofilenospace c" "cat cat."
_completionTests_verifyCompletion "testprog prefix nofilenospace f" ""
_completionTests_verifyCompletion "testprog prefix nofilenospace z" ""

#################################################
# Completions are NOT filtered by prefix by the program
#################################################

# When not allowing file completion, we can get smarter completions from fish
# when the program does not filter by prefix
_completionTests_verifyCompletion "testprog noprefix nofile paw" "bearpaw"

# Test ShellCompDirectiveDefault => File completion when no other completions
_completionTests_verifyCompletion "testprog noprefix default c" "cat"
_completionTests_verifyCompletion "testprog noprefix default f" "file"
_completionTests_verifyCompletion "testprog noprefix default z" ""

# Test ShellCompDirectiveNoFileComp => No file completion even when there are no other completions
_completionTests_verifyCompletion "testprog noprefix nofile c" "cat"
_completionTests_verifyCompletion "testprog noprefix nofile f" ""
_completionTests_verifyCompletion "testprog noprefix nofile z" ""

# Test ShellCompDirectiveNoSpace => No space even when there is a single completion
_completionTests_verifyCompletion "testprog noprefix nospace b" "bear bearpaw"
_completionTests_verifyCompletion "testprog noprefix nospace c" "cat cat."
_completionTests_verifyCompletion "testprog noprefix nospace f" "file"
_completionTests_verifyCompletion "testprog noprefix nospace z" ""
_completionTests_verifyCompletion "testprog noprefix nofilenospace b" "bear bearpaw"
_completionTests_verifyCompletion "testprog noprefix nofilenospace c" "cat cat."
_completionTests_verifyCompletion "testprog noprefix nofilenospace f" ""
_completionTests_verifyCompletion "testprog noprefix nofilenospace z" ""

#################################################
# Other directives
#################################################
# Test ShellCompDirectiveFilterFileExt => Not supported for fish, file completion instead
_completionTests_verifyCompletion "testprog fileext yaml" "setup.yaml"

# Test ShellCompDirectiveFilterDirs => Not supported for fish, file completion instead
_completionTests_verifyCompletion "testprog subdir dir" "dir/"

# Test ShellCompDirectiveError => File completion only
_completionTests_verifyCompletion "testprog error f" "file"
_completionTests_verifyCompletion "testprog error z" ""

#################################################
# Special cases
#################################################
# Test when there is a space before the binary name
# https://github.com/spf13/cobra/issues/1303
_completionTests_verifyCompletion " testprog prefix default c" "cat"
