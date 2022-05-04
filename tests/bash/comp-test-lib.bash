#!bash

# COLOR codes
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'
_compTests_nofile=/tmp/comptests.bash.nofile
_compTests_nospace=/tmp/comptests.bash.nospace
# Global variable to keep track of if a test has failed.
_completionTests_TEST_FAILED=0

# Setup bash_completion package
bashCompletionScript="/usr/share/bash-completion/bash_completion"
if [ $(uname) = "Darwin" ]; then
   bashCompletionScript="/usr/local/etc/profile.d/bash_completion.sh"
   # Trick bash-completion into thinking this is an interactive shell
   # See the if statement at the beginning of /usr/local/etc/profile.d/bash_completion.sh
   PS1="%"
fi
source ${bashCompletionScript}

# compopt does not exist for bash 3, so we don't
# define it and if it is called by mistake it will
# cause an error.
if [ $BASH_VERSINFO -gt 3 ]; then
   # compopt cannot be used outside of real shell
   # completion.  What we do instead is keep track
   # of what options are chosen, to check them.
   compopt() {
      if [ "$*" = "+o default" ]; then
         touch $_compTests_nofile
      elif [ "$*" = "-o default" ]; then
         rm -f $_compTests_nofile
      elif [ "$*" = "-o nospace" ]; then
         touch $_compTests_nospace
      elif [ "$*" = "+o nospace" ]; then
         rm -f $_compTests_nospace
      fi
   }
fi

_completionTests_reset() {
   rm -f $_compTests_nofile
   rm -f $_compTests_nospace
}

# Enable aliases to work even though we are in a script (non-interactive shell).
# This allows to test completion with aliases.
# Only needed for bash; zsh does this automatically.
shopt -s expand_aliases

# Run completion and indicate success or failure.
#    $1 is the command line that should be completed
#    $2 is the expected result of the completion
_completionTests_verifyCompletion() {
   _completionTests_reset

   local cmdLine=$1
   local expected=$2
   local currentFailure=0

   local nofile=0
   local nospace=0
   case "$3" in
   "")
      ;;
   nofile)
      nofile=1
      case "$4" in
      "")
         ;;
      nospace)
         nospace=1
         ;;
      *)
         echo "Invalid directive: $4"
         exit 1
         ;;
      esac 
      ;;
   nospace)
      nospace=1
      case "$4" in
      "")
         ;;
      nofile)
         nofile=1
         ;;
      *)
         echo "Invalid directive: $4"
         exit 1
         ;;
      esac 
      ;;
   *)
      echo "Invalid directive: $3"
      exit 1
      ;;
   esac 

   result=$(_completionTests_complete "${cmdLine}")

   result=$(_completionTests_sort "$result")
   expected=$(_completionTests_sort "$expected")

   if [ "$result" = "$expected" ]; then
      if ! _completionTests_checkDirective $nofile $nospace "$cmdLine"; then
         _completionTests_TEST_FAILED=1
         return 1
      fi

      # Truncate result to save space
      resultOut="$result"
      if [ "${#result}" -gt 50 ]; then
         resultOut="${result:0:50} <truncated>"
      fi
      echo -e "${GREEN}SUCCESS: \"$cmdLine\" completes to \"$resultOut\"$NC"
      return 0
   fi

   _completionTests_TEST_FAILED=1
   echo -e "${RED}ERROR: \"$cmdLine\" should complete to \"$expected\" but we got \"$result\"$NC"
   return 1
}

_completionTests_sort() {
   # We use printf instead of echo as the $1 could be -n which would be
   # interpreted as an argument to echo
   if [ -n "$BASH_COMP_NO_SORT" ]; then
      # Don't sort, just print back what we received
      printf "%s\n" "$1"
   else
      # sort the output
      printf "%s\n" "$1" | sed -e 's/^ *//' -e 's/ *$//' | tr ' ' '\n' | sort -n | tr '\n' ' ' | sed -e 's/^ *//' -e 's/ *$//'
   fi
}

# $1 - The completion to measure
# $2 - The maximum time to consider it an error
# $3 - An output prefix
_completionTests_timing() {
   TIMEFORMAT=%R
   timing=$({ time { _completionTests_complete "$1" > /dev/null; } } 2>&1)
   if (( $(echo "$timing > ${2}" | bc -l) )); then
      _completionTests_TEST_FAILED=1
      echo -e "${RED}<= TIMING => ${3}: 1000 completions took ${timing} seconds > ${2-0.1} seconds limit$NC" 
      return 1
   else
      echo -e "${GREEN}<= TIMING => ${3}: 1000 completions took ${timing} seconds < ${2-0.1} seconds limit$NC" 
      return 0
   fi
}

# Find the completion function associated with the binary.
# $1 is the first argument of the line to complete which allows
# us to find the existing completion function name.
_completionTests_findCompletionFunction() {
    binary=$(basename $1)
    local out=($(complete -p ${binary}))
    local returnNext=0
    for i in ${out[@]}; do
       if [ $returnNext -eq 1 ]; then
          echo "$i"
          return
       fi
       [ "$i" = "-F" ] && returnNext=1
    done
}

_completionTests_complete() {
   local cmdLine=$1

   # Set the bash completion variables which are
   # used for both bash and zsh completion
   COMP_LINE=${cmdLine}
   COMP_POINT=${#COMP_LINE}
   COMP_TYPE=${COMP_TYPE-9} # 9 is TAB, but we allow to override for some tests
   COMP_KEY=9  # 9 is TAB
   COMP_WORDS=($(echo ${cmdLine}))

   COMP_CWORD=$((${#COMP_WORDS[@]}-1))
   # We must check for a space as the last character which will tell us
   # that the previous word is complete and the cursor is on the next word.
   [ "${cmdLine: -1}" = " " ] && COMP_CWORD=${#COMP_WORDS[@]}

   # Call the completion function associated with the binary being called.
   # Also redirect stderr to stdout so that the tests fail if anything is printed
   # to stderr.
   eval $(_completionTests_findCompletionFunction ${COMP_WORDS[0]}) 2>&1

   # Return the result of the completion.
   # We use printf instead of echo as the first completion could be -n which
   # would be interpreted as an argument to echo
   printf "%s\n" "${COMPREPLY[@]}"
}

_completionTests_exit() {
   # Return the global result each time.  This allows for the very last call to
   # this method to return the correct success or failure code for the entire script
   return $_completionTests_TEST_FAILED
}

_completionTests_checkDirective() {
   # compopt does not exist for bash 3 so shell directives
   # don't work.  Don't fail in this case.
   if [ $BASH_VERSINFO -eq 3 ]; then
       return 0
   fi

   local requestnofile=$1
   local requestnospace=$2
   local cmdLine=$3

   local realnofile=0
   [ -f $_compTests_nofile ] && realnofile=1
   local realnospace=0
   [ -f $_compTests_nospace ] && realnospace=1

   if [ $requestnofile -ne $realnofile ]; then
      echo -e "${RED}ERROR: \"$cmdLine\" expected nofile=$requestnofile but got nofile=$realnofile$NC"
      return 1
   fi
   if [ $requestnospace -ne $realnospace ]; then
      echo -e "${RED}ERROR: \"$cmdLine\" expected nospace=$requestnospace but got nospace=$realnospace$NC"
      return 1
   fi

   return 0
}
