#!sh

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

function _completionTests_exit
   # Return the global result each time.  This allows for the very last call to
   # this method to return the correct success or failure code for the entire script
   return $_completionTests_TEST_FAILED
end

# Test logging using $BASH_COMP_DEBUG_FILE
function _completionTests_verifyDebug
   set debugfile /tmp/comp-tests.fish.debug
   rm -f $debugfile
   set -g BASH_COMP_DEBUG_FILE $debugfile
   _completionTests_verifyCompletion "testprog comp" "completion"
   if not test -s $debugfile
      # File should not be empty
      echo "ERROR: No debug logs were printed to $debugfile"
      set _completionTests_TEST_FAILED 1
   else
      echo "SUCCESS: Debug logs were printed to $debugfile"
   end
   set -e BASH_COMP_DEBUG_FILE
end