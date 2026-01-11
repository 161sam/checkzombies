PREFIX ?= /usr/local
MANPREFIX ?= $(PREFIX)/man

install:
	cp bin/checkzombies $(DESTDIR)$(PREFIX)/bin/
	gzip -f man/man1/checkzombies.1
	cp man/man1/checkzombies.1.gz $(DESTDIR)$(MANPREFIX)/man1/
	mandb

deb:
	dpkg-buildpackage -us -uc

test:
	bats tests/

lint:
	shellcheck bin/checkzombies

.PHONY: install deb test lint

