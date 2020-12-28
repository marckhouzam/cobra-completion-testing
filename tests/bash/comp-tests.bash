#!bash

_completionTests_verifyCompletion "testprog prefix default c" "cat"
_completionTests_verifyCompletion "testprog prefix nofile z" ""
_completionTests_verifyCompletion "testprog prefix nospace c" "cat"

echo "DONE for bash"