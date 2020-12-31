TESTPROG_DIR := $(CURDIR)/testprog

.PHONY: all
all: bash fish

.PHONY: build
build:
	@cd $(TESTPROG_DIR) && make

.PHONY: build-linux
build-linux:
	@cd $(TESTPROG_DIR) && make build-linux

.PHONY: bash
bash:
	@tests/test-all.sh bash

.PHONY: fish
fish:
	@tests/test-all.sh fish

.PHONY: test
test: clean build
	@echo "NOT READY"

.PHONY: macos
macos: mac

PHONY: mac
mac:
	@cd $(TESTPROG_DIR) && make clean
	@cd $(TESTPROG_DIR) && make
	@tests/test-completion.sh bash
	@tests/test-completion.sh fish

.PHONY: clean
clean:
	@cd $(TESTPROG_DIR) && make clean
