#!/usr/bin/env bash

# This script runs completion tests in different environments and different shells.

if [ -z $(which docker) ]; then
  echo "Missing 'docker' client which is required for these tests";
  exit 2;
fi

# Fail as soon as there is an error
set -e
BASE_DIR=$(cd $(dirname "${BASH_SOURCE[0]}")/..; pwd)

export TESTS_DIR=${BASE_DIR}/tests
export TESTPROG_DIR=${BASE_DIR}/testprog
export TESTING_DIR=${BASE_DIR}/testingdir
SHELL_TYPE=$1

case "$SHELL_TYPE" in
all|bash|fish|zsh)
    ;;
"")
    SHELL_TYPE=all
    ;;
*)
    echo "Invalid shell to test: $SHELL_TYPE.  Can be: all|bash|fish|zsh"
    exit 1
    ;;
esac

#BINARY_NAME=testprog
#BINARY_ROOT=${BASE_DIR}/testprog/bin
#BINARY_PATH_DOCKER=${BINARY_ROOT}/../dist/linux-amd64
#BINARY_PATH_LOCAL=${BINARY_ROOT}
#
## Only use the -d flag for mktemp as many other flags don't
## work on every plateform
#OUTPUT_DIR="${OUTPUT_DIR:-${PWD}}"
#export TESTS_DIR=$(mktemp -d ${OUTPUT_DIR}/cobra-completion-testing.XXXXXX)
#trap "rm -rf ${TESTS_DIR}" EXIT
#
#COMP_SCRIPT_NAME=test-completion.sh
#COMP_SCRIPT=${TESTS_DIR}/common/${COMP_SCRIPT_NAME}
#
#rm -rf ${TESTS_DIR}
#mkdir -p ${TESTS_DIR}/bin
#cp -a ${BASE_DIR}/tests/ ${TESTS_DIR}
#
#CHECK_BINARY_PATH="$(cd ${BINARY_PATH_DOCKER} && pwd)/${BINARY_NAME}"
#if [[ ! -f ${CHECK_BINARY_PATH} ]] && [[ -L ${CHECK_BINARY_PATH} ]]; then
#    echo "These tests require a binary located at ${CHECK_BINARY_PATH}"
#    echo "Hint: Run 'make build-cross' in a clone of the repo"
#    exit 2
#fi
#cp ${CHECK_BINARY_PATH} ${TESTS_DIR}/bin
#
## Now run all tests, even if there is a failure.
## But remember if there was any failure to report it at the end.
#set +e
#GOT_FAILURE=0
#trap "GOT_FAILURE=1" ERR
#
#cd ${BASE_DIR}/testdir

# ########################################
# # Bash 4 completion tests
# ########################################
# BASH4_IMAGE=completion-bash4

# echo;echo;
# docker build -t ${BASH4_IMAGE} - <<- EOF
#    FROM bash:4.4
#    RUN apk update && apk add bash-completion ca-certificates
# EOF
# docker run --rm \
#            -v ${TESTS_DIR}:${TESTS_DIR} \
#            -e ROBOT_HELM_V3=${ROBOT_HELM_V3} \
#            -e ROBOT_DEBUG_LEVEL=${ROBOT_DEBUG_LEVEL} \
#            -e TESTS_DIR=${TESTS_DIR} \
#            ${BASH4_IMAGE} ${COMP_SCRIPT} bash

# ########################################
# # Bash 3.2 completion tests
# ########################################
# # We choose version 3.2 because we want some Bash 3 version and 3.2
# # is the version by default on MacOS.  So testing that version
# # gives us a bit of coverage for MacOS.
# BASH3_IMAGE=completion-bash3

# echo;echo;
# docker build -t ${BASH3_IMAGE} - <<- EOF
#    FROM bash:3.2
#    RUN apk update && apk add ca-certificates
#    # For bash 3.2, the bash-completion package required is version 1.3
#    RUN mkdir /usr/share/bash-completion && \
#        wget -qO - https://github.com/scop/bash-completion/archive/1.3.tar.gz | \
#             tar xvz -C /usr/share/bash-completion --strip-components 1 bash-completion-1.3/bash_completion
# EOF
# docker run --rm \
#            -v ${TESTS_DIR}:${TESTS_DIR} \
#            -e BASH_COMPLETION=/usr/share/bash-completion \
#            -e ROBOT_HELM_V3=${ROBOT_HELM_V3} \
#            -e ROBOT_DEBUG_LEVEL=${ROBOT_DEBUG_LEVEL} \
#            -e TESTS_DIR=${TESTS_DIR} \
#            ${BASH3_IMAGE} ${COMP_SCRIPT} bash

# ########################################
# # Bash centos completion tests
# # https://github.com/helm/helm/pull/7304
# ########################################
# BASH_IMAGE=completion-bash-centos

# echo;echo;
# docker build -t ${BASH_IMAGE} - <<- EOF
#    FROM centos
#    RUN yum install -y bash-completion which
# EOF
# docker run --rm \
#            -v ${TESTS_DIR}:${TESTS_DIR} \
#            -e ROBOT_HELM_V3=${ROBOT_HELM_V3} \
#            -e ROBOT_DEBUG_LEVEL=${ROBOT_DEBUG_LEVEL} \
#            -e TESTS_DIR=${TESTS_DIR} \
#            ${BASH_IMAGE} ${COMP_SCRIPT} bash

# ########################################
# # Zsh completion tests
# ########################################
# ZSH_IMAGE=completion-zsh

# echo;echo;
# docker build -t ${ZSH_IMAGE} - <<- EOF
#    FROM zshusers/zsh:5.7
#    # This will install the SSL certificates necessary for helm repo update to work
#    RUN apt-get update && apt-get install -y wget
# EOF
# docker run --rm \
#            -v ${TESTS_DIR}:${TESTS_DIR} \
#            -e ROBOT_HELM_V3=${ROBOT_HELM_V3} \
#            -e ROBOT_DEBUG_LEVEL=${ROBOT_DEBUG_LEVEL} \
#            -e TESTS_DIR=${TESTS_DIR} \
#            ${ZSH_IMAGE} ${COMP_SCRIPT} zsh

# ########################################
# # Zsh alpine/busybox completion tests
# # https://github.com/helm/helm/pull/6327
# ########################################
# ZSH_IMAGE=completion-zsh-alpine

# echo;echo;
# docker build -t ${ZSH_IMAGE} - <<- EOF
#    FROM alpine
#    RUN apk update && apk add bash zsh ca-certificates
# EOF
# docker run --rm \
#            -v ${TESTS_DIR}:${TESTS_DIR} \
#            -e ROBOT_HELM_V3=${ROBOT_HELM_V3} \
#            -e ROBOT_DEBUG_LEVEL=${ROBOT_DEBUG_LEVEL} \
#            -e TESTS_DIR=${TESTS_DIR} \
#            ${ZSH_IMAGE} ${COMP_SCRIPT} zsh

########################################
# Fish completion tests
########################################
if [ $SHELL_TYPE = fish ] || [ $SHELL_TYPE = all ]; then
   make clean && make build-linux

   FISH_IMAGE=comp-test:fish

   docker build -t ${FISH_IMAGE} ${BASE_DIR} -f - <<- EOF
      FROM centos
      RUN cd /etc/yum.repos.d/ && \
          curl -O https://download.opensuse.org/repositories/shells:/fish/CentOS_8/shells:fish.repo && \
          yum install -y fish which

      WORKDIR /work
      COPY . .
EOF
   echo "======================================"
   echo "Testing on Docker"
   echo "======================================"
   docker run --rm \
           ${FISH_IMAGE} tests/fish/comp-tests.fish
fi

########################################
# MacOS completion tests
########################################
# Since we can't use Docker to test MacOS,
# we run the MacOS tests locally when possible.
if [ "$(uname)" == "Darwin" ]; then
    echo
    echo "==================================="
    echo "Attempting completion tests locally"
    echo "==================================="

    make clean && make build

    # if which bash>/dev/null && [ -f /usr/local/etc/bash_completion ]; then
    #     echo;echo;
    #     echo "Completion tests for bash running locally"
    #     ${COMP_SCRIPT} bash
    # else
    #     echo "Bash or bash_completion package not available locally"
    # fi
 
    if which fish > /dev/null; then
        tests/fish/comp-tests.fish
    else
        echo
        echo "Fish shell not available locally, skipping MacOS."
    fi
else
    echo
    echo "================================================"
    echo "Skipping testing on MacOS; need a MacOS machine."
    echo "================================================"
fi

# Indicate if anything failed during the run
exit ${GOT_FAILURE}
