#!/usr/bin/env bash

# This script runs completion tests in different environments and different shells.

if [ -z $(which docker) ]; then
  echo "Missing 'docker' client which is required for these tests";
  exit 2;
fi

# Fail as soon as there is an error
set -e
SCRIPT_DIR=$(dirname "${BASH_SOURCE[0]}")

BINARY_NAME=testprog
BINARY_ROOT=${SCRIPT_DIR}/../testprog/bin
BINARY_PATH_DOCKER=${BINARY_ROOT}/../dist/linux-amd64
BINARY_PATH_LOCAL=${BINARY_ROOT}

# Only use the -d flag for mktemp as many other flags don't
# work on every plateform
OUTPUT_DIR="${OUTPUT_DIR:-${PWD}}"
export COMP_DIR=$OUTPUT_DIR/tmp # $(mktemp -d ${OUTPUT_DIR}/cobra-completion-testing.XXXXXX)
trap "rm -rf ${COMP_DIR}" EXIT

COMP_SCRIPT_NAME=test-completion.sh
COMP_SCRIPT=${COMP_DIR}/common/${COMP_SCRIPT_NAME}

rm -rf ${COMP_DIR}
mkdir -p ${COMP_DIR}/bin
cp -a ${SCRIPT_DIR}/ ${COMP_DIR}

CHECK_BINARY_PATH="$(cd ${BINARY_PATH_DOCKER} && pwd)/${BINARY_NAME}"
if [[ ! -f ${CHECK_BINARY_PATH} ]] && [[ -L ${CHECK_BINARY_PATH} ]]; then
    echo "These tests require a binary located at ${CHECK_BINARY_PATH}"
    echo "Hint: Run 'make build-cross' in a clone of the repo"
    exit 2
fi
cp ${CHECK_BINARY_PATH} ${COMP_DIR}/bin

# Now run all tests, even if there is a failure.
# But remember if there was any failure to report it at the end.
set +e
GOT_FAILURE=0
trap "GOT_FAILURE=1" ERR

cd ${SCRIPT_DIR}/testdir

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
#            -v ${COMP_DIR}:${COMP_DIR} \
#            -e ROBOT_HELM_V3=${ROBOT_HELM_V3} \
#            -e ROBOT_DEBUG_LEVEL=${ROBOT_DEBUG_LEVEL} \
#            -e COMP_DIR=${COMP_DIR} \
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
#            -v ${COMP_DIR}:${COMP_DIR} \
#            -e BASH_COMPLETION=/usr/share/bash-completion \
#            -e ROBOT_HELM_V3=${ROBOT_HELM_V3} \
#            -e ROBOT_DEBUG_LEVEL=${ROBOT_DEBUG_LEVEL} \
#            -e COMP_DIR=${COMP_DIR} \
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
#            -v ${COMP_DIR}:${COMP_DIR} \
#            -e ROBOT_HELM_V3=${ROBOT_HELM_V3} \
#            -e ROBOT_DEBUG_LEVEL=${ROBOT_DEBUG_LEVEL} \
#            -e COMP_DIR=${COMP_DIR} \
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
#            -v ${COMP_DIR}:${COMP_DIR} \
#            -e ROBOT_HELM_V3=${ROBOT_HELM_V3} \
#            -e ROBOT_DEBUG_LEVEL=${ROBOT_DEBUG_LEVEL} \
#            -e COMP_DIR=${COMP_DIR} \
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
#            -v ${COMP_DIR}:${COMP_DIR} \
#            -e ROBOT_HELM_V3=${ROBOT_HELM_V3} \
#            -e ROBOT_DEBUG_LEVEL=${ROBOT_DEBUG_LEVEL} \
#            -e COMP_DIR=${COMP_DIR} \
#            ${ZSH_IMAGE} ${COMP_SCRIPT} zsh

# ########################################
# # Fish completion tests
# ########################################
# FISH_IMAGE=completion-fish

# docker build -t ${FISH_IMAGE} - <<- EOF
#    FROM centos
#    RUN cd /etc/yum.repos.d/ && \
#        curl -O https://download.opensuse.org/repositories/shells:/fish/CentOS_8/shells:fish.repo && \
#        yum install -y fish which
# EOF
# docker run --rm \
#            -v ${COMP_DIR}:${COMP_DIR} \
#            -e ROBOT_HELM_V3=${ROBOT_HELM_V3} \
#            -e ROBOT_DEBUG_LEVEL=${ROBOT_DEBUG_LEVEL} \
#            -e COMP_DIR=${COMP_DIR} \
#            ${FISH_IMAGE} ${COMP_SCRIPT} fish

########################################
# MacOS completion tests
########################################
# Since we can't use Docker to test MacOS,
# we run the MacOS tests locally when possible.
if [ "$(uname)" == "Darwin" ]; then
    echo;echo
    echo "======================================"
    echo "Attempting completion tests on Darwin"
    echo "======================================"

    # Copy the local testprogram to use
    if ! cp ${BINARY_PATH_LOCAL}/${BINARY_NAME} ${COMP_DIR}/bin ; then
        echo "Cannot find ${BINARY_NAME} under ${BINARY_PATH_LOCAL}/${BINARY_NAME} although it is what we need to test."
        exit 1
    fi

    if which bash>/dev/null && [ -f /usr/local/etc/bash_completion ]; then
        echo;echo;
        echo "Completion tests for bash running locally"
        ${COMP_SCRIPT} bash
    else
        echo "Bash or bash_completion package not available locally"
    fi
 
    if which fish>/dev/null; then
        echo;echo;
        echo "Completion tests for fish running locally"
        ${COMP_SCRIPT} fish
    else
        echo "Fish shell not available locally"
    fi
fi

# Indicate if anything failed during the run
exit ${GOT_FAILURE}
