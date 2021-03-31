.DEFAULT_GOAL := check

# tools
curl ?= curl
xpath ?= xpath
cddl ?= cddl
diag2cbor ?= diag2cbor.rb

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

eat_xml := draft-ietf-rats-eat.xml
CLEANFILES += $(eat_xml)

eat_cddl := eat.cddl
CLEANFILES += $(eat_cddl)

$(eat_cddl): $(eat_xml)
	$(xpath) -n -q -e '//section[@anchor="collected-cddl"]//artwork/text()' $< \
		| sed -e 's/\&amp;/\&/g' \
		> $@

$(eat_xml):
	if ! $(curl) -s -w "%{http_code}" -O $(eat_repo)/$@ | grep 200 ; then \
                echo ">>> failed downloading $(eat_repo)/$@" ; \
                rm -f $@ ; \
                exit 1 ; \
        fi

# TODO decide a file name convention to identify the valid test cases.
# TODO add more valid test cases
diags := src/secboot/valid1.diag

cbors := $(diags:.diag=.cbor)
CLEANFILES += $(cbors)

%.cbor: %.diag ; $(diag2cbor) $< > $@

# Check the valid test cases against the EAT CDDL
.PHONY: check
check: $(eat_cddl) $(cbors)
	for f in $(cbors) ; do \
		$(cddl) $< validate $$f ; \
	done

.PHONY: clean
clean: ; $(RM) $(CLEANFILES)
