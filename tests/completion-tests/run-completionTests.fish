#!fish

echo "===================================================="
echo Running completions tests on (uname) with fish $version
echo "===================================================="

source $COMP_DIR/lib/fish-comp-testing.fish

source $COMP_DIR/completionTests-common.sh
source $COMP_DIR/completionTests.fish
