TESTPROG_DIR := $(CURDIR)/testprog

.PHONY: all
all: build test

.PHONY: build
build:
	@cd $(TESTPROG_DIR) && make

.PHONY: bash
bash: build
	@tests/test-completion.sh bash

.PHONY: fish
fish: build
	@tests/test-completion.sh fish

.PHONY: zsh
zsh: build
	@tests/test-completion.sh zsh

.PHONY: test
test:
	@tests/test-all.sh

.PHONY: clean
clean:
	@cd $(TESTPROG_DIR) && make clean
