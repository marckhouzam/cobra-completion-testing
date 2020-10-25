#!sh

#############################################################################
# This file holds all tests that apply to all shells (bash, zsh, fish)
# It cannot use any if statements since their syntax is not portable
# between shells.
#
# For tests that are specific to a shell, use the proper specific file.
#############################################################################

# Basic first level commands (static completion)
_completionTests_verifyCompletion "testprog comp " "completion"
_completionTests_verifyCompletion "testprog help comp" "completion"
_completionTests_verifyCompletion "testprog completion " "bash fish zsh"
