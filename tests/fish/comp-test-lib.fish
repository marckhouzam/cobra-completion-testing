#!sh

# Global variable to keep track of if a test has failed.
set -g _completionTests_TEST_FAILED 0

# COLOR codes
set RED '\033[0;31m'
set GREEN '\033[0;32m'
set NC '\033[0m'


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
        echo -e $GREEN"SUCCESS: \"$cmdLine\" completes to \"$resultOut\"$NC"
    else
       set _completionTests_TEST_FAILED 1
       set currentFailure 1
       echo -e $RED"ERROR: \"$cmdLine\" should complete to \"$expected\" but we got \"$result\"$NC"
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
   set debugfile /tmp/comptests.fish.debug
   rm -f $debugfile
   set -g BASH_COMP_DEBUG_FILE $debugfile
   _completionTests_verifyCompletion "testprog comp" "completion"
   if not test -s $debugfile
      # File should not be empty
      echo -e $RED"ERROR: No debug logs were printed to $debugfile$NC"
      set _completionTests_TEST_FAILED 1
   else
      echo -e $GREEN"SUCCESS: Debug logs were printed to $debugfile$NC"
   end
   set -e BASH_COMP_DEBUG_FILE
end