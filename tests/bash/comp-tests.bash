#!bash

_completionTests_verifyCompletion "testprog prefix default c" "cat"
_completionTests_verifyCompletion "testprog prefix nofile z" ""
_completionTests_verifyCompletion "testprog prefix nospace c" "cat"

# This must be the last call.  It allows to exit with an exit code
# that reflects the final status of all the tests.
_completionTests_exit