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
Interactive log picker with diff/patch/revert/query actions.
```bash
git-log [--print] [-d <commit>] [-p <commit>] [-r <commit>] [-q <query>] [<path>...]
```

### git-mr
Create or work with GitLab merge requests: copy message, create issue, or fetch review feedback.
```bash
git-mr [-c|--create] [-m|--copy-message] [-i|--issue] [--feedback] [-r|--raw] \
       [-b|--branch <branch>] [--prod-branch <branch>] [-A|--all] <project>
```

### git-package
List, inspect, filter, delete GitLab packages for current repo.
```bash
git-package <check|list|delete> [ID] [-n <name>] [-v <version>] [-o txt|json]
```

### git-pipe
Show CI pipeline status for a ref, or search pipelines by trigger variable, log content, or status.
```bash
git-pipe status [-r <project>] [--ref <ref>]
git-pipe search [-r <project>] [--ref <ref>] [--var <NAME[=VALUE]>] [--grep <pattern>] \
                [--source <source>] [-s <status>|--failed|--succeeded|--aborted|...] \
                [-n <limit>] [-a] [-o txt|json]
```

### git-pr
List open PRs, create new PR, or fetch unresolved review feedback.
```bash
git-pr [-b|--branch] [-c|--create] [--feedback]
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
