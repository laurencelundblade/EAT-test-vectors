March 2021
A rough start at a collection of EAT tokens for testing

The tokens are one per file in the src directory

The .diag files describe the tokens in CBOR diag format. The
diag-format comments, the ones between '/' and '/' describe
the token and its testing use.

The .hex files are text files with lines of hex digits. For example
    010203dead
    beef
Lines beginning with "#" are comment lines that are not 
encoded into the token. The .diag format is preferred, but
some malformed and invalid CBOR is needed for some tests
and can't be represented in diag.

The .c file src tokens will be deprecated soon in favor
of the .hex format.
The .c files descibe the token as a C string. The .diag 
files are preferred but can't represent tokens with truly
malformed and invalid CBOR that is needed for some tests.

The script script/t2c.sh will take the .diag files and .hex files
and make a .c and .h file out of them that contains a byte
array for each token. This is good for testing embedded C
implementations of EAT.

A script should be authored that takes the .c and .diag files
and makes an individual CBOR-format token file out of each.
This should be straight forward

It should be possible to author scripts for other test uses.

There should be a script to use the cddl tool and cddl from
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

* src/euid/valid_rand_type.diag
* src/euid/invalid_unknown_type.diag

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
