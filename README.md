March 2021
A rough start at a collection of EAT tokens for testing

The tokens are one per file in the src directory

The .diag files describe the tokens in CBOR diag format. The
diag-format comments, the ones between '/' and '/' describe
the token and its testing use.

The .hex files are text files with lines of hex digits. For example:
```
    010203dead
    beef
```
Lines beginning with `#` are comment lines that are not
encoded into the token. The .diag format is preferred, but
some malformed and invalid CBOR is needed for some tests
and can't be represented in diag.

It should be possible to author scripts for other test uses.

There should be a script/Makefile to use the cddl tool and cddl from
the EAT RFC to check some of the .diag format tokens. All
can't be checked because some will be malformed input that
is legal CBOR, but not legal EAT.

Here's the file naming convention:
```
    TESTVECTOR = BASEDIR "/" ( "valid" / "invalid" ) "_" SYNOPSIS "." EXT
    BASEDIR = "src" "/" ( CLAIMNAME / FEATURE )
    CLAIMNAME = <the list of EAT claims>
    FEATURE = <a list of feaures or areas to test that are not claims>
    SYNOPSIS = 1* ( ALPHA / "_" / DIGIT )
    EXT = "diag" / "hex"
```

E.g.:
* `src/euid/valid_rand_type.diag`
* `src/euid/invalid_unknown_type.diag`

# Make

The source code is the .hex and .diag files in the src directory.
The made files are the .cbor files in the cbor directory and
xxx.c and xxx.h in the top level directory.

The default make target is to just make these files.

Make can also be invoked to validate the valid CBOR
files against the EAT CDDL. When it does this it will
fetch the EAT CDDL and invoke the needed CDDL tools.
This requires a lot more tools, some of which may be
more tempermental.  See next section on docker.

# Docker

To build the docker sandbox, do:
```
make build-docker
```

To enter the sandbox and run an interactive shell, do:
```
make run-docker
```

From within the sandbox, all the Makefile targets (e.g., `check`, `clean`,
etc.) are directly available; e.g.:
```
sandbox# make check
```

In order to run a Makefile target in the sandbox from the host, add a `docker-`
prefix, e.g.:
```
host$ make docker-check`
```
