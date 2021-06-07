DEFAULT_GOAL := main

main: CBOR eat_test_tokens.c eat_test_tokens.h


# TODO: 
# Bring in comments and diag to the header file (this is in make_c_file.sh)
# Fix the validation
# This may have to pull in CDDL from other places than just EAT
# Add lots of comments
# Add more .PHONY targets




# tools
curl ?= curl
xpath ?= xpath
cddl ?= cddl
diag2cbor ?= diag2cbor.rb
xxd ?= xxd



# The source files are .diag and .hex files in the "src" directory.
# They build into CBOR format files in the "cbor" directory.  All the
# test case files are oganized in subdirectories of the "src" and
# "cbor" directories by the feature or EAT claim the test. Only one
# level is supported.
#
#     TESTVECTOR = BASEDIR "/" ( "valid" / "invalid" ) "_" SYNOPSIS "." EXT
#     BASEDIR = "src" "/" ( CLAIMNAME / FEATURE )
#     CLAIMNAME = <the list of EAT claims>
#     FEATURE = <a list of feaures or areas to test that are not claims>
#     SYNOPSIS = 1* ( ALPHA / "_" / DIGIT )
#     EXT = "diag" / "hex"
#
# The following variables are lists of the diag and cbor
# files. There's a separate list for the test cases that are valid as
# these are the ones that are checked against the CDDL by "make check"
# The .hex files are used only for invalid CBOR so they are never
# checked against the CDDL.

diag_files := $(wildcard src/*.diag src/*/*.diag)

hex_files := $(wildcard src/*.hex src/*/*.hex)

cbor_files := $(patsubst src/%,cbor/%,$(patsubst %.diag,%.cbor,$(diag_files)))

cbor_files += $(patsubst src/%,cbor/%,$(patsubst %.hex,%.cbor,$(hex_files)))

valid_diag_files := $(wildcard src/valid_*.diag src/*/valid_*.diag)

valid_cbor_files := $(patsubst src/%,cbor/%,$(patsubst %.diag,%.cbor,$(valid_diag_files)))



# Here's the rules to make the CBOR from the CDDL and hex files.  This
# also makes a .c and a .h file with initialized constant variables so
# the cbor can be used for testing C code. (One could also have the
# test code read the .cbor files, but some embedded systems don't have
# full file systems so initilized variables are useful)
# 
# These rules make the intermediate directories.

%.cbor :	%.diag
	$(diag2cbor) $< > $@

cbor/%.cbor :	src/%.diag
	@mkdir -p $(@D)
	$(diag2cbor) $< > $@

%.cbor	:	%.hex
	grep -v '^#' $< | $(xxd) -r -p > $@

cbor/%.cbor	:	src/%.hex
	@mkdir -p $(@D)
	grep -v '^#' $< | $(xxd) -r -p > $@


CBOR:	$(cbor_files)

eat_test_tokens.c eat_test_tokens.h:	$(cbor_files)
	./make_c_files.sh source_preamble > eat_test_tokens.c
	./make_c_files.sh header_preamble > eat_test_tokens.h
	for f in $? ; do \
                ./make_c_files.sh source $$f >> eat_test_tokens.c ; \
                ./make_c_files.sh header $$f >> eat_test_tokens.h ; \
	done 

CLEANFILES += $(cbor_files)
CLEANFILES += eat_test_tokens.c eat_test_tokens.h




eat_xml := draft-ietf-rats-eat.xml
CLEANFILES += $(eat_xml)

eat_cddl := eat.cddl
CLEANFILES += $(eat_cddl)


# upstream repo configuration
eat_repo_baseurl ?= https://ietf-rats-wg.github.io/eat
# Set eat_repo_branch if you need to work with a branch other than master/main.
# For example, if you need to work with a branch named CoSWID, do:
#   make eat_repo_branch=CoSWID
# Check https://ietf-rats-wg.github.io/eat/ for the branches that are currently
# available.
eat_repo_branch ?=
ifeq ($(eat_repo_branch),)
  eat_repo := $(eat_repo_baseurl)
else
  eat_repo := $(eat_repo_baseurl)/$(eat_repo_branch)
endif

$(eat_cddl): $(eat_xml)
	$(xpath) -n -q -e '//section[@anchor="collected-cddl"]//sourcecode/text()' $< \
		| sed -e 's/\&amp;/\&/g' \
		> $@

$(eat_xml):
	if ! $(curl) -s -w "%{http_code}" -O $(eat_repo)/$@ | grep 200 ; then \
                echo ">>> failed downloading $(eat_repo)/$@" ; \
                rm -f $@ ; \
                exit 1 ; \
        fi

.PHONY: check
check: $(eat_cddl) $(valid_cbor_files)
	for f in $(valid_cbor_files) ; do \
		$(cddl) $(eat_cddl) validate $$f ; \
	done



# Docker for platforms that don't support the correct tool versions.
# In particular, MacOS xpath doesn't work right

docker_image := eat-test-sandbox
docker_wdir := /root
docker_run_it := docker run -it -w $(docker_wdir) -v $(shell pwd):$(docker_wdir) $(docker_image)

build-docker: ; docker build -t $(docker_image) .
.PHONY: build-docker

run-docker: ; $(docker_run_it)
.PHONY: run-docker

# Execute any Makefile target into the docker sandbox
# E.g., to run the "check" target in the sandbox, do:
#   make docker-check
# To run the "clean" target in the sandbox, do:
#   make docker-clean
docker-%:
	$(docker_run_it) bash -c "make $(subst docker-,,$@)"



# Cleaning
.PHONY: clean
clean: ; $(RM) $(CLEANFILES)


