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
SHELL_TYPE=$1

case "$SHELL_TYPE" in
bash|fish|zsh)
    ;;
*)
    echo "Invalid shell to test: $SHELL_TYPE.  Can be: bash|fish|zsh"
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
if [ $SHELL_TYPE = bash ]; then
   IMAGE=comp-test:bash5

   $CONTAINER_ENGINE build -t ${IMAGE} ${BASE_DIR} -f - <<- EOF
      FROM bash:5.1
      RUN apk update && apk add bash-completion ca-certificates

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
if [ $SHELL_TYPE = bash ]; then
   IMAGE=comp-test:bash4

   $CONTAINER_ENGINE build -t ${IMAGE} ${BASE_DIR} -f - <<- EOF
      FROM bash:4.4
      RUN apk update && apk add bash-completion ca-certificates

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
if [ $SHELL_TYPE = bash ]; then
   IMAGE=comp-test:bash3

   $CONTAINER_ENGINE build -t ${IMAGE} ${BASE_DIR} -f - <<- EOF
      FROM bash:3.2
      RUN apk update && apk add ca-certificates
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
# Bash centos completion tests
########################################
if [ $SHELL_TYPE = bash ]; then
   IMAGE=comp-test:bashcentos

   $CONTAINER_ENGINE build -t ${IMAGE} ${BASE_DIR} -f - <<- EOF
      FROM centos
      RUN yum install -y bash-completion which

      WORKDIR /work
      COPY . .
EOF
   echo "======================================"
   echo "Testing with $(basename $CONTAINER_ENGINE) with CentOS"
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
if [ $SHELL_TYPE = fish ]; then
   IMAGE=comp-test:fish

   $CONTAINER_ENGINE build -t ${IMAGE} ${BASE_DIR} -f - <<- EOF
      FROM centos
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
    echo "Attempting completion tests locally"
    echo "==================================="

    make clean && make build

    if [ $SHELL_TYPE = bash ]; then
       if which bash > /dev/null && [ -f /usr/local/etc/bash_completion ]; then
          tests/bash/comp-tests.bash

          # Test bashCompletionV2
          echo "Testing bash v2"
          BASHCOMPV2=1 tests/bash/comp-tests.bash
       else
          echo
          echo "Bash or bash_completion package not available locally, skipping MacOS"
       fi
    fi

    if [ $SHELL_TYPE = fish ]; then
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

# Indicate if anything failed during the run
exit ${GOT_FAILURE}
