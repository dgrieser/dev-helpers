PREFIX ?= /usr/local
DESTDIR ?=

BINDIR ?= $(PREFIX)/bin
COMPLETIONSDIR ?= $(PREFIX)/share/bash-completion/completions
SHAREDIR ?= $(PREFIX)/share/dev-helpers
# the group that may install without root: the invoking user's primary group
INSTALL_GROUP ?= $(shell id -gn "$${SUDO_USER:-$$(id -un)}")

SCRIPTS := $(shell find . -maxdepth 1 -type f -perm /111 -printf '%f\n' | sort)
LINKS := $(shell find . -maxdepth 1 -type l -printf '%f\n' | sort)

COMPLETIONS_FILE := completions/dev-helpers
COMPLETION_CMDS := $(shell awk '/^complete /{print $$NF}' $(COMPLETIONS_FILE) | sort -u)
# also install under the stable name so shell rc files can source it for alias completion
COMPLETION_NAMES := $(COMPLETION_CMDS) dev-helpers

# sourced from shell rc files, see README.md
SHELL_FILES := $(shell find shell -maxdepth 1 -type f -printf '%f\n' | sort)

REPO_DIR := $(CURDIR)

.PHONY: list check-dirs setup-dirs install install-links uninstall list-install

list:
	@printf 'Available targets:\n'
	@printf '  make list                     Show this help and available commands\n'
	@printf '  make list-install             Show install destination and installed files\n'
	@printf '  sudo make setup-dirs          Create the install folders as root:$(INSTALL_GROUP), group-writable (once)\n'
	@printf '  sudo make install             Install commands, bash completions and shell integration\n'
	@printf '  sudo make install-links       Install as symlinks back to this repo (no file copy)\n'
	@printf '  sudo make uninstall           Remove installed files\n'
	@printf '\nAvailable commands:\n'
	@printf '%s\n' $(SCRIPTS) $(LINKS) | sed 's/^/  /'

# runs before install/install-links: as a user, fail early with a hint instead of
# halfway through, when a folder (or the parent it would be created in) is not writable
check-dirs:
	@[ "$$(id -u)" -eq 0 ] && exit 0; \
	for dir in "$(DESTDIR)$(BINDIR)" "$(DESTDIR)$(COMPLETIONSDIR)" "$(DESTDIR)$(SHAREDIR)"; do \
		existing="$$dir"; \
		while [ ! -e "$$existing" ]; do existing="$$(dirname "$$existing")"; done; \
		if [ ! -w "$$existing" ]; then \
			echo "ERROR: $$existing is not writable for $$(id -un), cannot install into $$dir" 1>&2; \
			echo "HINT: run once: sudo make setup-dirs$(if $(strip $(MAKEOVERRIDES)), $(MAKEOVERRIDES))  (then install without sudo), or install with sudo" 1>&2; \
			exit 1; \
		fi; \
	done

# run once as root: creates the install folders as root:$(INSTALL_GROUP) and
# group-writable, so install-links (and install) work afterwards without sudo
setup-dirs:
	@if [ "$$(id -u)" -ne 0 ]; then \
		echo "ERROR: setup-dirs needs root, run: sudo make setup-dirs" 1>&2; \
		exit 1; \
	fi
	for dir in "$(DESTDIR)$(BINDIR)" "$(DESTDIR)$(COMPLETIONSDIR)" "$(DESTDIR)$(SHAREDIR)"; do \
		mkdir -p "$$dir" && chown root:"$(INSTALL_GROUP)" "$$dir" && chmod g+w "$$dir" || exit 1; \
	done

install: check-dirs
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

install-links: check-dirs
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
