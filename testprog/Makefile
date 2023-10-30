BINDIR      := $(CURDIR)/bin
BINNAME     ?= testprog
SRC        := $(shell find . -type f -name '*.go' -print)

GOBIN         = $(shell go env GOBIN)
ifeq ($(GOBIN),)
GOBIN         = $(shell go env GOPATH)/bin
endif

.PHONY: all
all: build

.PHONY: build
build: $(BINDIR)/$(BINNAME)

$(BINDIR)/$(BINNAME): $(SRC)
	go build -o '$(BINDIR)'/$(BINNAME) -ldflags '-extldflags "-static"' .

.PHONY: build-linux
build-linux:
	GOOS=linux go build -o "$(BINDIR)/$(BINNAME)" -ldflags '-extldflags "-static"' .

.PHONY: clean
clean:
	@rm -rf '$(BINDIR)'
