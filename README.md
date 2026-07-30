# dev-helpers

Collection of git helper scripts for everyday workflows across GitHub and GitLab.

## Install

```bash
sudo make install            # copy scripts to /usr/local/bin and bash completions
sudo make install-links      # symlink scripts and completions back to this repo
sudo make uninstall          # remove installed files
make list                    # show targets and available commands
make list-install            # show install destination
```

Bash completions (`completions/dev-helpers`) are installed to
`/usr/local/share/bash-completion/completions`, one entry per command, so
bash-completion lazy-loads them on first tab. Flags, subcommands, and
contextual values (branches, tags, projects, changed files) are completed.

Aliases and wrapper functions don't trigger lazy loading, so to complete them
source the stable-named copy from your shell rc after defining the aliases:

```bash
source /usr/local/share/bash-completion/completions/dev-helpers
__dh_register_aliases                    # auto-map aliases to git-* commands
__dh_complete_alias g git-find-repo      # map wrapper functions explicitly
```

## Tools

### git-activity-to-issue
Resolve GitLab activity feed items to issue references.
```bash
git-activity-to-issue
```

### git-add
Interactive fuzzy stager: stage/unstage/delete/reset/ignore files and resolve conflicts via picker.
```bash
git-add [-p] [<path>...] [-s <path>] [-u <path>] [-d <path>] [-r <path>] [-i <path>] [-q <query>]
```

### git-branch
Create/checkout a branch, or delete/reset/backup it (with confirmation).
```bash
git-branch [--delete] [--reset] [--backup] [-y|--yes] [BRANCH_NAME]
```

### git-branch-from-tag
Create a branch starting from an existing tag.
```bash
git-branch-from-tag [<tag>]
```

### git-browse
Open the current repo (and optionally branch) in the browser.
```bash
git-browse [-p|--print] [--host-only] [--include-branch]
```

### git-change
Switch to a different branch.
```bash
git-change <branch>
```

### git-checkout
Checkout given branch, default branch if none, or `-` for previous.
```bash
git-checkout [BRANCH]
```

### git-clone
Clone a repo; reads URL from arg, clipboard, or prompt.
```bash
git-clone <git url>
```

### git-container
List, inspect, filter, delete GitLab container registry tags for current repo.
```bash
git-container <check|list|delete> [ID] [-n <name>] [-t <tag>] [-o txt|json]
```

### git-create
Create a new GitLab repo under `$WORKSPACE` via `glab`.
```bash
git-create
```

### git-default
Print the name of the default remote branch.
```bash
git-default [--fqn]
```

### git-diff
Show diff of HEAD plus untracked files, or against a branch; optional vimdiff.
```bash
git-diff [-p|--path PATH] [-v|--vim] [BRANCH]
```

### git-find-repo
Print the path of a repo under `$WORKSPACE` by name, `name#parent` qualifier, relative path, or git URL; `-` jumps to the previous repo from history. Clones missing repos unless disabled. GitLab MR (`/-/merge_requests/<id>`) and branch (`/-/tree/<branch>`) URLs also check out and pull the referenced branch unless disabled; a bare or `!`-prefixed MR number does the same for the current repo. Keeps a cached repo listing and a jump history.
```bash
git-find-repo [--workspace|-W <path>] [--vc-folder|-F <folder>] [--update-listing|-U] \
              [--list|-L] [--history|-H] [--no-git-clone] [--no-history] [--no-checkout] <project|url|mr-id|->
```

### git-fix-goimports
Run `make imports` and `goimports -w` on a chosen recent branch.
```bash
git-fix-goimports
```

### git-fork
Fork the current repo on github.com.
```bash
git-fork
```

### git-ignore
Append paths/patterns to `.gitignore` (cwd or repo root).
```bash
git-ignore [-r|--root] FILE...
```

### git-last-change
Show diff between the last two tags.
```bash
git-last-change
```

### git-log
Interactive log picker. Commits are listed as COMMIT / AGE / AUTHOR / MESSAGE
(with branch and tag decorations), the preview shows the commit with its stat
and patch. Keys: `ctrl-c` copies the hash, `ctrl-d` shows the diff, `ctrl-o`
opens the commit in the browser, `alt-p` writes it as a patch file, `alt-r`
reverts it in the working tree, `alt-b` reverts it on a new branch and
optionally pushes it and opens a merge/pull request.

`enter` steps into a commit and opens a file picker with the changed files
plus their churn on the left and the diff of the selected file in the preview:
`enter` shows the file diff, `ctrl-c` copies the path, `alt-v` opens the before
and after version in vimdiff, `alt-p` writes the file's diff as a patch, and
`alt-r` reverts just that file's change. `esc` and `backspace` return to the
commit list. Merge commits are shown against their first parent.
```bash
git-log [--print] [-q <query>] [-n <count>] [--ref <rev>] [--all] \
        [--author <pattern>] [--grep <pattern>] [--merges|--no-merges] \
        [-d <commit>] [-f <commit>] [-p <commit>] [-o <dir>] \
        [-r <commit>] [-b <commit>] [--] [<path>...]
```

### git-move
Move uncommitted changes to a new branch, leaving the current branch clean; optionally take unpushed commits along and reset the current branch to its upstream. Changes travel with the branch switch when the branch starts at the current commit, otherwise through a stash that is only dropped once it applied cleanly.
```bash
git-move [-b|--base <ref>] [-c|--with-commits] [-C|--no-commits] [-y|--yes] [BRANCH]
```

### git-mr
Work with GitLab merge requests and GitHub pull requests; the provider is
detected from the remote, so `git-mr` and `git-pr` are the same command.
Approve, merge, create, copy a channel message, create an issue, or show the
review feedback.

Without an action an interactive menu offers every action plus the branch and
state filter (`branch` and `states` change the filter and return to the menu).
The requests are then listed in a picker with the request and its diff in the
preview: `enter` runs the chosen action (approve + merge by default), `ctrl-s`
shows the request, `ctrl-d` its diff, `ctrl-o` opens it in the browser,
`ctrl-y` copies a channel message, `ctrl-f` shows the feedback, `alt-a`
approves, `alt-m` merges, `alt-i` creates an issue from it, and `esc` goes
back.

By default the requests of the current branch are listed; on the default or
production branch (`--prod-branch`) requests are filtered by their target
branch instead. `--feedback` prints the comments and review feedback as
Markdown (`-u` hides resolved discussions, `-r` skips the terminal
rendering). `-n` acts on one request without the picker, `-p` prints the list.
```bash
git-mr [-c|--create] [-a|--approve] [-M|--merge] [-m|--copy-message] \
       [-i|--issue] [--feedback] [-u|--unresolved] [-r|--raw] \
       [-b|--branch <branch>] [-k|--checkout] [--prod-branch <branch>] \
       [-A|--all] [-n|--number <id>] [-q|--query <query>] [-l|--limit <n>] \
       [-p|--print] [-o txt|json] [<project>]
```

### git-package
List, inspect, filter, delete GitLab packages for current repo.
```bash
git-package <check|list|delete> [ID] [-n <name>] [-v <version>] [-o txt|json]
```

### git-pipe
Show GitLab CI or GitHub Actions pipeline status for a ref, or search pipelines by log content, source, or status. Defaults to the current branch; use `--all-refs` to search every ref. Variable search is GitLab-only.

Results open in an interactive picker with the pipeline's jobs in the preview: `enter` copies the URL, `ctrl-o` opens it in the browser, `ctrl-l` shows the job logs. The picker reloads once 3 seconds after it opened - a pipeline may have started in the meantime - and then keeps reloading every few seconds (`-w`, `-w 0` disables) as long as pipelines are still running, stopping once everything reached a final state. Use `-p` or `-o json` for non-interactive output.
```bash
git-pipe status [-r <project>] [--ref <ref>] [-q <query>] [-w <seconds>] [-p] [-o txt|json]
git-pipe search [-r <project>] [--ref <ref>|--all-refs] [--var <NAME[=VALUE]>] [--grep <pattern>] \
                [--source <source>] [-s <status>|--failed|--succeeded|--aborted|...] \
                [-n <limit>] [-a] [-q <query>] [-w <seconds>] [-p] [-o txt|json]
```

### git-pr
Symlink to [git-mr](#git-mr), which handles GitHub pull requests and GitLab
merge requests alike.
```bash
git-pr [OPTIONS] [<project>]
```

### git-push
Push current or named branch; optional push-only or force-with-lease.
```bash
git-push [-p|--push-only] [-F|--force-with-lease] [<branch>]
```

### git-reset-all
Reset and clean all tracked and untracked changes (with confirm).
```bash
git-reset-all
```

### git-rm-branches
Delete all local branches except the default branch.
```bash
git-rm-branches [-f|--force]
```

### git-search
Search GitLab and/or GitHub for a query.
```bash
git-search <query> [--gitlab|--github]
```

### git-tag
Create, delete, or recreate a git tag.
```bash
git-tag [<tag>] [-d] [-r] [-y]
```

### git-track-branches
Set up tracking for all remote branches; optionally prune locals.
```bash
git-track-branches [-C|--clear]
```

### git-worktree
Manage mirrored git worktrees under `$WORKSPACE_WORKTREE`.
```bash
git-worktree [add|list|delete|move-to-main] [-b <branch>] [-w <dir>]
```
