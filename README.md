# Regression tests for Cobra completion scripts

The [Cobra](https://github.com/spf13/cobra) library provides support for shell
completion for programs that use it.  For this, Cobra provides a `__complete`
command which is implemented in Go and is used by each completion script
(`bash`, `zsh`, `fish` and `powershell`). Cobra has Go tests to help avoid any
regressions to the `__complete` command logic.
However, implementing regression tests for each shell script itself, which are
written in the corresponding shell language, is a more challenging endeavour.

This project aims to provide such regression tests which exercise and verify the
completion scripts implemented by Cobra.

# Current shell support

At this time regression testing is supported for the `bash` and `fish` shell.

I aim to also support `zsh` but I have to figure out how to do so first.

I don't expect to be able to test `powershell` as I am not familiar with that shell;
contributions welcomed.

# Dependencies

- Clone this project and clone the Cobra project both in the same parent directory
- A container engine installation (e.g., Podman or Docker)
- GO

Containers are used to execute the tests for different versions of the different
shells.  The tests can be run on Linux or MacOS.

It is also possible to run the tests natively on MacOS to run regression tests
for that platform. This is done automatically when running the tests on MacOS.
# Running the tests

## Test all
```
make
```
## Test bash
```
make bash
```
## Test fish
```
make fish
```

# Implementation

## fish

Testing completion for the `fish` shell is relatively simple as the `fish` shell
allows to trigger completion from a test script by using `complete --do-complete <commandLine>`.
With this approach, it is also possible to check if file completion is triggered or not
(to test `ShellCompDirectiveNoFileComp`).
See [comp-tests-lib.fish](tests/bash/comp-tests-lib.fish).

## bash

The completion logic for the `bash` shell requires the completion script to store all
completions in the `$COMPREPLY` array.  Also, starting with bash 4, the `compopt` command
is used to specify special directives such as disabling file completion and disabling a space
being added at the end of the completed word.

To test completion, the regression tests explicitly call the completion function associated
with the program being tested, after having set all required variables for completion to work,
and then verifies the results stored in `$COMPREPLY`.

Testing the special directives is slightly more complicated however.  The `compopt` command
cannot be used outside of a real completion scenario, so it cannot be used during the
regression tests.  The tests replace it with their own implementation and keep track
of what directives have been enabled/disabled to verify it is what is expected.
See [comp-tests-lib.bash](tests/bash/comp-tests-lib.bash).

