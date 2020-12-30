TESTPROG_DIR := $(CURDIR)/testprog

.PHONY: all
all: clean build test

.PHONY: build
build:
	@cd $(TESTPROG_DIR) && make

.PHONY: bash
bash: clean build
	@echo "NOT READY"

.PHONY: fish
fish: clean build
	@echo "NOT READY"

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
