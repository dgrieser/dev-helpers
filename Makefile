PREFIX ?= /usr/local
DESTDIR ?=

BINDIR ?= $(PREFIX)/bin
COMPLETIONSDIR ?= $(PREFIX)/share/bash-completion/completions
SHAREDIR ?= $(PREFIX)/share/dev-helpers

SCRIPTS := $(shell find . -maxdepth 1 -type f -perm /111 -printf '%f\n' | sort)
LINKS := $(shell find . -maxdepth 1 -type l -printf '%f\n' | sort)

COMPLETIONS_FILE := completions/dev-helpers
COMPLETION_CMDS := $(shell awk '/^complete /{print $$NF}' $(COMPLETIONS_FILE) | sort -u)
# also install under the stable name so shell rc files can source it for alias completion
COMPLETION_NAMES := $(COMPLETION_CMDS) dev-helpers

# sourced from shell rc files, see README.md
SHELL_FILES := $(shell find shell -maxdepth 1 -type f -printf '%f\n' | sort)

REPO_DIR := $(CURDIR)

.PHONY: list install install-links uninstall list-install

list:
	@printf 'Available targets:\n'
	@printf '  make list                     Show this help and available commands\n'
	@printf '  make list-install             Show install destination and installed files\n'
	@printf '  sudo make install             Install commands, bash completions and shell integration\n'
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
	[ -d "$(DESTDIR)$(SHAREDIR)" ] || mkdir -p "$(DESTDIR)$(SHAREDIR)"
	for file in $(SHELL_FILES); do \
		install -m 0644 "shell/$$file" "$(DESTDIR)$(SHAREDIR)/$$file"; \
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
	[ -d "$(DESTDIR)$(SHAREDIR)" ] || mkdir -p "$(DESTDIR)$(SHAREDIR)"
	for file in $(SHELL_FILES); do \
		ln -sfn "$(REPO_DIR)/shell/$$file" "$(DESTDIR)$(SHAREDIR)/$$file"; \
	done

uninstall:
	for script in $(SCRIPTS) $(LINKS); do \
		rm -f "$(DESTDIR)$(BINDIR)/$$script"; \
	done
	for cmd in $(COMPLETION_NAMES); do \
		rm -f "$(DESTDIR)$(COMPLETIONSDIR)/$$cmd"; \
	done
	for file in $(SHELL_FILES); do \
		rm -f "$(DESTDIR)$(SHAREDIR)/$$file"; \
	done
	rmdir "$(DESTDIR)$(SHAREDIR)" 2>/dev/null || true

list-install:
	@printf 'Scripts -> %s\n' "$(DESTDIR)$(BINDIR)"
	@printf '%s\n' $(SCRIPTS) $(LINKS) | sed 's/^/  /'
	@printf 'Completions -> %s\n' "$(DESTDIR)$(COMPLETIONSDIR)"
	@printf '%s\n' $(COMPLETION_NAMES) | sed 's/^/  /'
	@printf 'Shell integration -> %s\n' "$(DESTDIR)$(SHAREDIR)"
	@printf '%s\n' $(SHELL_FILES) | sed 's/^/  /'
