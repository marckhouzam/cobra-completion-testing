.PHONY: all
all:

build:
    make -f testprog/

test:
	./test-all.sh

.PHONY: clean
clean:
	@rm -rf '$(BINDIR)' ./_dist
