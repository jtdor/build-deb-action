bindir=$(exec_prefix)/bin
exec_prefix=$(prefix)
prefix=/usr/local

INSTALL:=install
INSTALL_PROGRAM:=$(INSTALL)

mybin:
	touch mybin

.PHONY: clean
clean:
	$(RM) mybin

.PHONY: install
install: mybin
	mkdir -p $(DESTDIR)$(bindir)
	$(INSTALL_PROGRAM) mybin $(DESTDIR)$(bindir)/mybin
