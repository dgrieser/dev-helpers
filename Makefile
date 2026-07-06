PREFIX ?= /usr/local
DESTDIR ?=

BINDIR ?= $(PREFIX)/bin
COMPLETIONSDIR ?= $(PREFIX)/share/bash-completion/completions

SCRIPTS := $(shell find . -maxdepth 1 -type f -perm /111 -printf '%f\n' | sort)
LINKS := $(shell find . -maxdepth 1 -type l -printf '%f\n' | sort)

COMPLETIONS_FILE := completions/dev-helpers
COMPLETION_CMDS := $(shell awk '/^complete /{print $$NF}' $(COMPLETIONS_FILE) | sort -u)
# also install under the stable name so shell rc files can source it for alias completion
COMPLETION_NAMES := $(COMPLETION_CMDS) dev-helpers

REPO_DIR := $(CURDIR)

.PHONY: list install install-links uninstall list-install

list:
	@printf 'Available targets:\n'
	@printf '  make list                     Show this help and available commands\n'
	@printf '  make list-install             Show install destination and installed files\n'
	@printf '  sudo make install             Install commands and bash completions\n'
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
	[ -d "$(DESTDIR)$(COMPLETIONSDIR)" ] || mkdir -p "$(DESTDIR)$(COMPLETIONSDIR)"
	for cmd in $(COMPLETION_NAMES); do \
		install -m 0644 "$(COMPLETIONS_FILE)" "$(DESTDIR)$(COMPLETIONSDIR)/$$cmd"; \
	done

install-links:
	[ -d "$(DESTDIR)$(BINDIR)" ] || mkdir -p "$(DESTDIR)$(BINDIR)"
	for script in $(SCRIPTS); do \
		ln -sfn "$(REPO_DIR)/$$script" "$(DESTDIR)$(BINDIR)/$$script"; \
	done
	for link in $(LINKS); do \
		ln -sfn "$(REPO_DIR)/$$link" "$(DESTDIR)$(BINDIR)/$$link"; \
	done
	[ -d "$(DESTDIR)$(COMPLETIONSDIR)" ] || mkdir -p "$(DESTDIR)$(COMPLETIONSDIR)"
	for cmd in $(COMPLETION_NAMES); do \
		ln -sfn "$(REPO_DIR)/$(COMPLETIONS_FILE)" "$(DESTDIR)$(COMPLETIONSDIR)/$$cmd"; \
	done

uninstall:
	for script in $(SCRIPTS) $(LINKS); do \
		rm -f "$(DESTDIR)$(BINDIR)/$$script"; \
	done
	for cmd in $(COMPLETION_NAMES); do \
		rm -f "$(DESTDIR)$(COMPLETIONSDIR)/$$cmd"; \
	done

list-install:
	@printf 'Scripts -> %s\n' "$(DESTDIR)$(BINDIR)"
	@printf '%s\n' $(SCRIPTS) $(LINKS) | sed 's/^/  /'
	@printf 'Completions -> %s\n' "$(DESTDIR)$(COMPLETIONSDIR)"
	@printf '%s\n' $(COMPLETION_NAMES) | sed 's/^/  /'
