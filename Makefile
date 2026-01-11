NAME := checkzombies
BIN  := bin/checkzombies
MAN  := man/man1/checkzombies.1

# Prefer git tag, fallback to VERSION file, fallback to 0.0.0
VERSION ?= $(shell git describe --tags --abbrev=0 2>/dev/null | sed 's/^v//' || cat VERSION 2>/dev/null || echo "0.0.0")

DIST_DIR := dist
DEB_DIR  := $(DIST_DIR)/deb
OUT_BIN  := $(DIST_DIR)/$(NAME)
OUT_DEB  := $(DIST_DIR)/$(NAME)_$(VERSION)_all.deb
OUT_SUMS := $(DIST_DIR)/SHA256SUMS

.PHONY: all clean dist deb checksums release verify-man

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
	./scripts/build_deb.sh "$(VERSION)" "$(OUT_DEB)"

checksums: dist deb
	(cd $(DIST_DIR) && sha256sum "$(NAME)" "$(NAME)_$(VERSION)_all.deb" > "SHA256SUMS")

release: checksums
	@echo "Built:"
	@ls -lah $(OUT_BIN) $(OUT_DEB) $(OUT_SUMS)
