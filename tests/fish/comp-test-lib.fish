#!fish

echo "===================================================="
echo Running completions tests on $UNAME with $SHELL_TYPE $version
echo "===================================================="

# Must set the path again for Fish as the path gets modified when the shell starts
set PATH $TESTPROG_DIR/bin:$PATH

# Setup completion
testprog completion fish --no-descriptions | source

# Global variable to keep track of if a test has failed.
set -g _completionTests_TEST_FAILED 0

# Run completion and indicate success or failure.
#    $1 is the command line that should be completed
#    $2 is the expected result of the completion
function _completionTests_verifyCompletion
    set cmdLine $argv[1]
    set expected $argv[2]
    set currentFailure 0

    set result (complete --do-complete "$cmdLine")

    set result (_completionTests_sort "$result")
    set expected (_completionTests_sort "$expected")

    if test "$result" = "$expected"
        set resultOut "$result"
        if test (string length -- "$result") -gt 50
            set resultOut (string sub --length 50 -- $result) "<truncated>"
        end
        echo "SUCCESS: \"$cmdLine\" completes to \"$resultOut\""
    else
       set _completionTests_TEST_FAILED 1
       set currentFailure 1
       echo "ERROR: \"$cmdLine\" should complete to \"$expected\" but we got \"$result\""
    end

    return $currentFailure
end

function _completionTests_sort
   string trim $argv[1] | tr ' ' '\n' | sort -n | tr '\n' ' ' | string trim
end

function _completionTests_exit
   # Return the global result each time.  This allows for the very last call to
   # this method to return the correct success or failure code for the entire script
   return $_completionTests_TEST_FAILED
end
