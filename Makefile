PREFIX ?= /usr/local
DESTDIR ?=

BINDIR ?= $(PREFIX)/bin

SCRIPTS := $(shell find . -maxdepth 1 -type f -perm /111 -printf '%f\n' | sort)
LINKS := $(shell find . -maxdepth 1 -type l -printf '%f\n' | sort)

REPO_DIR := $(CURDIR)

.PHONY: list install install-links uninstall list-install

list:
	@printf 'Available targets:\n'
	@printf '  make list                     Show this help and available commands\n'
	@printf '  make list-install             Show install destination and installed files\n'
	@printf '  sudo make install             Install commands\n'
	@printf '  sudo make install-links       Install as symlinks back to this repo (no file copy)\n'
	@printf '  sudo make uninstall           Remove installed files\n'
	@printf '\nAvailable commands:\n'
	@printf '%s\n' $(SCRIPTS) $(LINKS) | sed 's/^/  /'

install:
	[ -d "$(DESTDIR)$(BINDIR)" ] || mkdir -p "$(DESTDIR)$(BINDIR)"
	for script in $(SCRIPTS); do \
		install -m 0755 "$$script" "$(DESTDIR)$(BINDIR)/$$script"; \
	done
	for link in $(LINKS); do \
		target="$$(readlink "$$link")"; \
		ln -sfn "$$target" "$(DESTDIR)$(BINDIR)/$$link"; \
	done

install-links:
	[ -d "$(DESTDIR)$(BINDIR)" ] || mkdir -p "$(DESTDIR)$(BINDIR)"
	for script in $(SCRIPTS); do \
		ln -sfn "$(REPO_DIR)/$$script" "$(DESTDIR)$(BINDIR)/$$script"; \
	done
	for link in $(LINKS); do \
		ln -sfn "$(REPO_DIR)/$$link" "$(DESTDIR)$(BINDIR)/$$link"; \
	done

uninstall:
	for script in $(SCRIPTS) $(LINKS); do \
		rm -f "$(DESTDIR)$(BINDIR)/$$script"; \
	done

list-install:
	@printf 'Scripts -> %s\n' "$(DESTDIR)$(BINDIR)"
	@printf '%s\n' $(SCRIPTS) $(LINKS) | sed 's/^/  /'
