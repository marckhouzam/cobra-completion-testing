BINDIR      := $(CURDIR)/bin
BINNAME     ?= testprog
TARGETS     := linux/amd64
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

.PHONY: build-cross
build-cross: LDFLAGS += -extldflags "-static"
build-cross: $(GOX)
	CGO_ENABLED=0 $(GOX) -parallel=3 -output="dist/{{.OS}}-{{.Arch}}/$(BINNAME)" -osarch='$(TARGETS)' $(GOFLAGS) -tags '$(TAGS)' -ldflags '$(LDFLAGS)' .

.PHONY: clean
clean:
	@rm -rf '$(BINDIR)' ./_dist
