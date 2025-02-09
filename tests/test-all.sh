#!/usr/bin/env bash

# This script runs completion tests in different environments and different shells.

# Get path to docker or podman binary
CONTAINER_ENGINE=$(command -v docker podman | head -n1)

if [ -z $CONTAINER_ENGINE ]; then
  echo "Missing 'docker' or 'podman' which is required for these tests";
  exit 2;
fi

BASE_DIR=$(cd $(dirname "${BASH_SOURCE[0]}")/..; pwd)

export TESTS_DIR=${BASE_DIR}/tests
export TESTPROG_DIR=${BASE_DIR}/testprog
export TESTING_DIR=${BASE_DIR}/testingdir

# Run all tests, even if there is a failure.
# But remember if there was any failure to report it at the end.
set +e
GOT_FAILURE=0
trap "GOT_FAILURE=1" ERR

for TARGET in "$@"; do

case "$TARGET" in
bash|fish|macos)
    ;;
*)
    echo "Invalid target to test: $TARGET.  Can be: bash|fish|macos"
    exit 1
    ;;
esac

#######################################
# Testing in a linux container
#######################################
if [ "$(uname)" == "Linux" ]; then
   make clean && make build
else
   make clean && make build-linux
fi

########################################
# Bash 5 completion tests
########################################
if [ $TARGET = bash ]; then
   IMAGE=comp-test:bash5

   $CONTAINER_ENGINE build -t ${IMAGE} ${BASE_DIR} -f - <<- EOF
      FROM bash:5.1
      RUN apk update && apk add bash-completion ca-certificates libc6-compat

      WORKDIR /work
      COPY . .
EOF
   echo "======================================"
   echo "Testing with $(basename $CONTAINER_ENGINE)"
   echo "======================================"
   $CONTAINER_ENGINE run --rm \
           ${IMAGE} tests/bash/comp-tests.bash

   # Test bashCompletionV2
   echo "======================================"
   echo "Testing with $(basename $CONTAINER_ENGINE) bash v2"
   echo "======================================"
   $CONTAINER_ENGINE run --rm \
           -e BASHCOMPV2=1 \
           ${IMAGE} tests/bash/comp-tests.bash
fi

########################################
# Bash 4 completion tests
########################################
if [ $TARGET = bash ]; then
   IMAGE=comp-test:bash4

   $CONTAINER_ENGINE build -t ${IMAGE} ${BASE_DIR} -f - <<- EOF
      FROM bash:4.4
      RUN apk update && apk add bash-completion ca-certificates libc6-compat

      WORKDIR /work
      COPY . .
EOF
   echo "======================================"
   echo "Testing with $(basename $CONTAINER_ENGINE)"
   echo "======================================"
   $CONTAINER_ENGINE run --rm \
           ${IMAGE} tests/bash/comp-tests.bash

   # Test bashCompletionV2
   echo "======================================"
   echo "Testing with $(basename $CONTAINER_ENGINE) bash v2"
   echo "======================================"
   $CONTAINER_ENGINE run --rm \
           -e BASHCOMPV2=1 \
           ${IMAGE} tests/bash/comp-tests.bash
fi

########################################
# Bash 3.2 completion tests
########################################
if [ $TARGET = bash ]; then
   IMAGE=comp-test:bash3

   $CONTAINER_ENGINE build -t ${IMAGE} ${BASE_DIR} -f - <<- EOF
      FROM bash:3.2
      RUN apk update && apk add ca-certificates libc6-compat
      # For bash 3.2, the bash-completion package required is version 1.3
      RUN mkdir /usr/share/bash-completion && \
          wget -qO - https://github.com/scop/bash-completion/archive/1.3.tar.gz | \
            tar xvz -C /usr/share/bash-completion --strip-components 1 bash-completion-1.3/bash_completion

      WORKDIR /work
      COPY . .
EOF
   echo "======================================"
   echo "Testing with $(basename $CONTAINER_ENGINE)"
   echo "======================================"
   $CONTAINER_ENGINE run --rm \
           -e BASH_COMPLETION=/usr/share/bash-completion \
           ${IMAGE} tests/bash/comp-tests.bash

   # Test bashCompletionV2
   echo "======================================"
   echo "Testing with $(basename $CONTAINER_ENGINE) bash v2"
   echo "======================================"
   $CONTAINER_ENGINE run --rm \
           -e BASH_COMPLETION=/usr/share/bash-completion \
           -e BASHCOMPV2=1 \
           ${IMAGE} tests/bash/comp-tests.bash
fi

########################################
# Bash redhat completion tests
########################################
if [ $TARGET = bash ]; then
   IMAGE=comp-test:bashredhat

   $CONTAINER_ENGINE build -t ${IMAGE} ${BASE_DIR} -f - <<- EOF
      FROM redhat/ubi9
      RUN yum install -y bash-completion which bc

      WORKDIR /work
      COPY . .
EOF
   echo "======================================"
   echo "Testing with $(basename $CONTAINER_ENGINE) with RedHat"
   echo "======================================"
   $CONTAINER_ENGINE run --rm \
           ${IMAGE} tests/bash/comp-tests.bash

   # Test bashCompletionV2
   echo "======================================"
   echo "Testing with $(basename $CONTAINER_ENGINE) bash v2"
   echo "======================================"
   $CONTAINER_ENGINE run --rm \
           -e BASHCOMPV2=1 \
           ${IMAGE} tests/bash/comp-tests.bash
fi

########################################
# Fish completion tests
########################################
if [ $TARGET = fish ]; then
   IMAGE=comp-test:fish

   $CONTAINER_ENGINE build -t ${IMAGE} ${BASE_DIR} -f - <<- EOF
      FROM redhat/ubi8
      RUN cd /etc/yum.repos.d/ && \
          curl -O https://download.opensuse.org/repositories/shells:/fish/CentOS_8/shells:fish.repo && \
          yum install -y fish which

      WORKDIR /work
      COPY . .
EOF
   echo "======================================"
   echo "Testing with $(basename $CONTAINER_ENGINE)"
   echo "======================================"
   $CONTAINER_ENGINE run --rm \
           ${IMAGE} tests/fish/comp-tests.fish
fi

########################################
# MacOS completion tests
########################################
# Since we can't use containers to test MacOS,
# we run the MacOS tests locally when possible.
if [ "$(uname)" == "Darwin" ]; then
    echo
    echo "==================================="
    echo "Attempting MacOS completion tests locally"
    echo "==================================="

    make clean && make build

    if [ $TARGET = bash ] || [ $TARGET = macos ]; then
       if which bash > /dev/null && [ -f $(brew --prefix)/etc/profile.d/bash_completion.sh ]; then
          tests/bash/comp-tests.bash

          # Test bashCompletionV2
          echo "Testing bash v2"
          BASHCOMPV2=1 tests/bash/comp-tests.bash
       else
          echo
          echo "Bash or bash_completion package not available locally, skipping MacOS"
          echo "Please note that you must install bash_completion v2 (brew install bash-completion@2)"
       fi
    fi

    if [ $TARGET = fish ] || [ $TARGET = macos ]; then
       if which fish > /dev/null; then
          tests/fish/comp-tests.fish
       else
          echo
          echo "Fish shell not available locally, skipping MacOS."
       fi
    fi
else
    echo
    echo "================================================"
    echo "Skipping testing on MacOS; need a MacOS machine."
    echo "================================================"
fi

done
# Indicate if anything failed during the run
exit ${GOT_FAILURE}
