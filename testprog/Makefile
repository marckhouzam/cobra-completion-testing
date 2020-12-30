BINDIR      := $(CURDIR)/bin
BINNAME     ?= testprog
SRC        := $(shell find . -type f -name '*.go' -print)

GOBIN         = $(shell go env GOBIN)
ifeq ($(GOBIN),)
GOBIN         = $(shell go env GOPATH)/bin
endif
GOX           = $(GOBIN)/gox

.PHONY: all
all: build

.PHONY: build
build: $(BINDIR)/$(BINNAME)

$(BINDIR)/$(BINNAME): $(SRC)
	go build -o '$(BINDIR)'/$(BINNAME) .

# If go get is run from inside the project directory it will add the dependencies
# to the go.mod file. To avoid that we change to a directory without a go.mod file
# when downloading the following dependencies
$(GOX):
	(cd /; go get -u github.com/mitchellh/gox)

.PHONY: build-linux
build-linux: $(GOX)
	CGO_ENABLED=0 $(GOX) -output="$(BINDIR)/$(BINNAME)" -osarch='linux/amd64' -ldflags '-extldflags "-static"' .

.PHONY: clean
clean:
	@rm -rf '$(BINDIR)'
