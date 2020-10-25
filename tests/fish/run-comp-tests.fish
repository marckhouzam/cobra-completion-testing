#!fish

echo "===================================================="
echo Running completions tests on (uname) with fish $version
echo "===================================================="

source $COMP_DIR/fish/fish-comp-test-lib.fish

source $COMP_DIR/common/comp-tests-common.sh
source $COMP_DIR/fish/comp-tests.fish
