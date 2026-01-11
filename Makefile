NAME := checkzombies
BIN  := bin/checkzombies
MAN  := man/man1/checkzombies.1

# Prefer git tag, fallback to VERSION file, fallback to 0.0.0
VERSION ?= $(shell git describe --tags --abbrev=0 2>/dev/null | sed 's/^v//' || cat VERSION 2>/dev/null || echo "0.0.0")
DEB_VERSION ?= $(shell dpkg-parsechangelog -SVersion 2>/dev/null || echo "$(VERSION)-1")

DIST_DIR := dist
DEB_DIR  := $(DIST_DIR)/deb
OUT_BIN  := $(DIST_DIR)/$(NAME)
OUT_DEB  := $(DIST_DIR)/$(NAME)_$(DEB_VERSION)_all.deb
OUT_RPM  := $(DIST_DIR)/$(NAME)-$(VERSION)-1.noarch.rpm
OUT_SUMS := $(DIST_DIR)/SHA256SUMS
RPM_TOP  := $(DIST_DIR)/rpmbuild

.PHONY: all clean dist deb rpm checksums release verify-man

all: release

clean:
	rm -rf $(DIST_DIR)

dist: clean
	mkdir -p $(DIST_DIR)
	# ship single-file executable
	install -m 0755 $(BIN) $(OUT_BIN)

verify-man:
	@test -f "$(MAN)" || (echo "Missing manpage: $(MAN)" >&2; exit 1)

deb: verify-man
	mkdir -p $(DIST_DIR)
	git archive --format=tar.gz --prefix=$(NAME)-$(VERSION)/ -o ../$(NAME)_$(VERSION).orig.tar.gz HEAD
	dpkg-buildpackage -us -uc -b
	mv ../$(NAME)_$(DEB_VERSION)_all.deb $(OUT_DEB)

rpm: verify-man
	mkdir -p $(RPM_TOP)/BUILD $(RPM_TOP)/RPMS $(RPM_TOP)/SOURCES $(RPM_TOP)/SPECS $(RPM_TOP)/SRPMS
	git archive --format=tar.gz --prefix=$(NAME)-$(VERSION)/ -o $(RPM_TOP)/SOURCES/$(NAME)-$(VERSION).tar.gz HEAD
	cp packaging/rpm/$(NAME).spec $(RPM_TOP)/SPECS/$(NAME).spec
	rpmbuild -ba $(RPM_TOP)/SPECS/$(NAME).spec --define "_topdir $(RPM_TOP)" --define "version_override $(VERSION)" --define "release_override 1"
	cp $(RPM_TOP)/RPMS/noarch/$(NAME)-$(VERSION)-1.noarch.rpm $(OUT_RPM)

checksums: dist deb rpm
	(cd $(DIST_DIR) && sha256sum "$(NAME)" "$(NAME)_$(DEB_VERSION)_all.deb" "$(NAME)-$(VERSION)-1.noarch.rpm" > "SHA256SUMS")

release: checksums
	@echo "Built:"
	@ls -lah $(OUT_BIN) $(OUT_DEB) $(OUT_RPM) $(OUT_SUMS)
